# 🚫 안티 패턴 (Anti-Patterns)

> 아래 패턴들은 절대 사용하지 않는다. 발견 시 즉시 수정한다.

---

## 1. 금지되는 응답 패턴

### 1.1 게으른 응답 (Lazy Response)

#### ❌ BAD: 생략 표현
```
"나머지는 비슷하게 구현하면 됩니다."
"위와 같은 방식으로 처리합니다."
"등등..."
"기타 등등"
```

#### ✅ GOOD: 완전한 설명
```
"OrderService 클래스에 다음 3개 메서드를 추가합니다:
1. createOrder() - 주문 생성
2. updateOrder() - 주문 수정
3. deleteOrder() - 주문 삭제

각 메서드의 구현은 아래와 같습니다..."
```

### 1.2 불확실한 주장 (Uncertain Claims)

#### ❌ BAD: 확인 없이 단정
```
"이 API는 Spring 5.0에서 deprecated 되었습니다."
"Kotlin 2.0부터는 이 문법이 지원됩니다."
"이 라이브러리가 가장 인기 있습니다."
```

#### ✅ GOOD: 검증 후 답변
```
"공식 문서를 확인하겠습니다." 
→ `context7` (`query-docs`) 또는 `google_web_search` 실행
→ "확인 결과, 이 API는 Spring 5.3에서 deprecated 되었습니다. (출처: Spring 공식 문서)"
```

### 1.3 추측성 파일 경로 (Guessed Paths)

#### ❌ BAD: 확인 없이 경로 언급
```
"src/main/config/application.yml 파일을 수정하세요."
"com.example.service.OrderService 클래스에..."
```

#### ✅ GOOD: 확인 후 경로 제시
```
→ fd "application" 실행
→ "src/main/resources/application.yml 파일을 수정하겠습니다."

→ rg "class OrderService" 실행
→ "com.example.order.service.OrderService 클래스를 수정하겠습니다."
```

### 1.4 가짜 확신 (Fake Confidence)

#### ❌ BAD: 모르면서 아는 척
```
"네, 이 방법이 확실히 동작합니다."
"100% 이게 맞습니다."
"틀림없이 이렇게 하면 됩니다."
```

#### ✅ GOOD: 솔직한 불확실성 표현
```
"이 방법이 동작할 것으로 예상되지만, 실제 테스트로 확인이 필요합니다."
"공식 문서에서 확인한 바로는 이렇게 동작합니다."
"이 부분은 확신이 없어서 검색으로 확인하겠습니다."
```

---

## 2. 금지되는 코드 패턴

### 2.1 플레이스홀더 (Placeholders)

#### ❌ BAD
```kotlin
fun processOrder(order: Order) {
    // TODO: 구현 필요
}

fun validateInput(input: String): Boolean {
    // 나중에 구현
    return true
}

class PaymentService {
    // ... 생략 ...
}
```

#### ✅ GOOD
```kotlin
fun processOrder(order: Order) {
    // 주문 유효성 검사
    validateOrder(order)
    
    // 재고 확인
    checkInventory(order.items)
    
    // 결제 처리
    processPayment(order.payment)
    
    // 주문 저장
    orderRepository.save(order)
}
```

### 2.2 존재하지 않는 API 호출 (Fabricated API)

#### ❌ BAD: 날조된 API
```kotlin
// @AutoValidate는 존재하지 않는 어노테이션
@AutoValidate 
data class OrderRequest(
    val productId: String,
    val quantity: Int
)

// StringUtils.isValidEmail()은 존재하지 않는 메서드
if (StringUtils.isValidEmail(email)) { ... }
```

#### ✅ GOOD: 실제 존재하는 API
```kotlin
// javax.validation의 실제 어노테이션 사용
data class OrderRequest(
    @field:NotBlank
    val productId: String,

    @field:Min(1)
    val quantity: Int
)

// 정규식 또는 Apache Commons 사용
if (email.matches(Regex("^[A-Za-z0-9+_.-]+@(.+)$"))) { ... }
// 또는
if (EmailValidator.getInstance().isValid(email)) { ... }
```

### 2.3 불완전한 에러 처리 (Incomplete Error Handling)

#### ❌ BAD
```kotlin
fun fetchUser(id: String): User {
    return userRepository.findById(id)  // null이면?
}

fun parseJson(json: String): Data {
    return objectMapper.readValue(json, Data::class.java) // 파싱 실패하면?
}
```

#### ✅ GOOD
```kotlin
fun fetchUser(id: String): User {
    return userRepository.findById(id)
        ?: throw UserNotFoundException("사용자를 찾을 수 없습니다: $id")
}

fun parseJson(json: String): Data {
    return try {
        objectMapper.readValue(json, Data::class.java)
    } catch (e: JsonProcessingException) {
        throw InvalidJsonException("JSON 파싱 실패: ${e.message}")
    }
}
```

### 2.4 하드코딩된 값 (Hardcoded Values)

#### ❌ BAD
```kotlin
fun connectToDatabase() {
    val url = "jdbc:mysql://localhost:3306/mydb"
    val username = "admin"
    val password = "password123"  // 보안 위반!
}

fun getApiUrl(): String {
    return "https://api.example.com/v1" // 환경별 분리 불가
}
```

#### ✅ GOOD
```kotlin
@Value("\${spring.datasource.url}")
lateinit var dbUrl: String

@Value("\${spring.datasource.username}")
lateinit var dbUsername: String

@Value("\${api.base-url}")
lateinit var apiBaseUrl: String
```

### 2.5 테스트 없는 구현 (Implementation Without Tests)

#### ❌ BAD: 테스트 없이 바로 구현
```
"OrderCalculator 클래스를 구현하겠습니다."
→ 바로 구현 코드 작성
```

#### ✅ GOOD: TDD 사이클 준수
```
"먼저 테스트 코드를 작성하겠습니다."
→ 테스트 코드 작성 (Red)
→ 구현 코드 작성 (Green)
→ 리팩토링 (Refactor)
```

---

## 3. 안티 패턴 탐지 자가 점검

응답을 제출하기 전에 다음을 확인:

| # | 점검 항목 | 확인 |
|:---|:---|:---|
| 1 | "생략", "등등", "나머지는" 표현이 있는가? | ❌ 없어야 함 |
| 2 | TODO, FIXME, 플레이스홀더가 있는가? | ❌ 없어야 함 |
| 3 | 검증 없이 파일 경로를 언급했는가? | ❌ 없어야 함 |
| 4 | 존재 확인 없이 API를 사용했는가? | ❌ 없어야 함 |
| 5 | 불확실한 정보를 단정적으로 말했는가? | ❌ 없어야 함 |
| 6 | 테스트 없이 구현 코드만 제공했는가? | ❌ 없어야 함 |

---

## ⚠️ REMINDER

안티 패턴을 발견하면:
1. 즉시 수정
2. `failure_patterns` 테이블에 기록
3. 같은 실수 반복하지 않도록 학습

---

## ⚠️ IMPORTANT REMINDER

**위 안티 패턴은 절대 범하지 않는다:**
1. 게으름 (Lazy Response) - TODO, 생략 표현 금지  
2. 불확실한 주장 (Uncertain Claims) - 검증 없이 단정 금지
3. 추측 (Guessed Paths) - 파일/API 존재 확인 필수
4. 날조 (Fabricated API) - 존재하지 않는 API 호출 금지

사용자가 아무리 급해도, 이 원칙은 지킨다.
