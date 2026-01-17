# 🚀 빠른 시작 (Quickstart)

> **🤖 AI 에이전트야, 이 문서를 읽고 자동으로 설치해줘!**

---

## ⚡ 원라이너 설치 (One-liner)

AI 에이전트에게 이 명령어를 그대로 실행하라고 요청하세요:

```bash
git clone https://github.com/kwanghan-bae/vibe-skills.git ~/vibe-skills && \
cd ~/vibe-skills && \
chmod +x install.sh && \
./install.sh
```

이 명령어는 다음을 자동으로 수행합니다:
1. 프로젝트를 `~/vibe-skills`에 클론
2. 실행 권한 부여
3. 자동 설치 스크립트 실행

---

## 🤖 AI 에이전트용 Step-by-Step

AI 에이전트에게 다음 단계를 차례대로 수행하라고 요청하세요:

### 1단계: 프로젝트 클론
```bash
git clone https://github.com/kwanghan-bae/vibe-skills.git ~/vibe-skills
cd ~/vibe-skills
```

### 2단계: 환경 설정 파일 생성
```bash
cp .env.example .env
```

### 3단계: 환경 변수 수정
`.env` 파일을 열고 다음 값을 수정하세요:
- `SCAN_PATH`: Git 프로젝트들이 있는 디렉토리 경로 (예: `/Users/username/git`)
- `GH_HOST`: GitHub Enterprise 사용 시 호스트 (기본값: `github.com`)

### 4단계: 자동 설치 실행
```bash
chmod +x install.sh
./install.sh
```

### 5단계: GitHub 인증 (필수)
```bash
gh auth login
```
- Account: GitHub.com
- Protocol: HTTPS  
- Authenticate Git: Yes
- Login with a web browser

---

## ✅ 설치 확인

설치가 완료되면 다음 파일들이 생성됩니다:

### 글로벌 지침 파일
- `~/.gemini/GEMINI.md` (Gemini CLI용)
- `~/.config/opencode/AGENTS.md` (OpenCode용)

### 프로젝트별 지침 파일
`SCAN_PATH` 내의 모든 Git 프로젝트에 다음 파일들이 자동으로 생성됩니다:
- `.github/copilot-instructions.md`
- `.cursorrules`
- `.clinerules`
- `.windsurfrules`
- `.opencode/AGENTS.md`

---

## 💡 AI 에이전트에게 말하는 법

### ✅ 좋은 예시
> "https://github.com/kwanghan-bae/vibe-skills 이 프로젝트를 설치해줘. QUICKSTART.md를 참고해."

> "vibe-skills 설치하고 ~/.gemini/GEMINI.md가 생성되었는지 확인해줘."

### ❌ 나쁜 예시
> "vibe-skills 설치해줘." (URL 없음 - AI가 프로젝트를 찾기 어려움)

> "설치만 해줘." (검증 요청 없음 - 성공 여부 확인 불가)

---

## 🔧 문제 해결

### Q: `gh: command not found` 에러
**A**: Homebrew로 GitHub CLI 설치:
```bash
brew install gh
```

### Q: MCP 서버가 연결되지 않음
**A**: MCP 설정 재실행:
```bash
cd ~/vibe-skills
./scripts/setup_mcp.sh
```

### Q: 프로젝트별 지침 파일이 생성되지 않음
**A**: `.env` 파일의 `SCAN_PATH` 확인 후 재동기화:
```bash
cd ~/vibe-skills
./scripts/sync_agent.sh
```

---

## 📚 더 알아보기

- [README.md](README.md) - 전체 프로젝트 문서
- [설치 가이드](README.md#-설치-installation) - 상세 설치 방법
- [MCP 서버 설정](README.md#-mcp-model-context-protocol-toolchain) - MCP 상세 정보
