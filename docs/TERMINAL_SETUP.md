# 🚀 터미널 환경 최적화 가이드

> **목표**: oh-my-zsh 없이 빠르고 강력한 Zsh 환경 구축

---

## 📦 1. 필수 도구 설치

### 1.1 Zsh 플러그인
```bash
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting
brew install zsh-completions
```

### 1.2 히스토리 검색 강화
```bash
brew install atuin  # Ctrl+R 대체
```

---

## ⚙️ 2. 새 .zshrc 적용

프로젝트가 준비한 최적화된 `.zshrc`를 사용합니다:

```bash
# 1. 기존 설정 백업
cp ~/.zshrc ~/.zshrc.backup

# 2. 새 설정 적용
cp ~/.zshrc.new ~/.zshrc

# 3. oh-my-zsh 제거 (선택사항)
rm -rf ~/.oh-my-zsh

# 4. 설정 적용
source ~/.zshrc
```

---

## ✨ 3. 설치된 기능

### 자동완성 강화
- **zsh-autosuggestions**: 이전 명령어가 회색으로 표시됨 → `→` 키로 자동완성
- **zsh-syntax-highlighting**: 올바른 명령어는 녹색, 잘못된 명령어는 빨간색

### 히스토리 검색
- **atuin (Ctrl+R)**: 
  - 퍼지 검색
  - 디렉토리별 필터링
  - 시간대별 검색
  - 실행 시간 기록

### Modern Unix 도구
- `ls` → `eza --icons` (아이콘 + Git 상태)
- `cat` → `bat --style=plain` (Syntax highlighting)
- `cd` → `z` (`zoxide` 스마트 점프)

### Git 단축키
```bash
g      # git
gs     # git status
ga     # git add
gc     # git commit
gp     # git push
gl     # git pull
gd     # git diff
glog   # git log --oneline --graph
```

---

## 🎨 4. 프롬프트 (Starship)

이미 설치된 **Starship**이 다음 정보를 자동으로 표시합니다:
- 📁 현재 디렉토리
- 🔀 Git 브랜치 및 상태
- 🐍 Python 버전 (가상환경 활성화 시)
- 📦 Node.js 버전 (package.json 있는 경우)

---

## 🔧 5. 추가 설정 (선택사항)

### 5.1 fzf 키 바인딩 강화

fzf가 이미 설치되어 있다면:

```bash
# Ctrl+T: 파일 검색
# Ctrl+R: atuin이 처리 (이미 fzf보다 강력)
# Alt+C:  디렉토리 이동
```

### 5.2 Starship 설정 커스터마이징

```bash
# 설정 파일 생성
mkdir -p ~/.config
starship preset gruvbox-rainbow -o ~/.config/starship.toml
```

다른 테마:
- `starship preset pure-preset`
- `starship preset tokyo-night`
- `starship preset nerd-font-symbols`

---

## 🚀 6. 성능 비교

| 설정 | Shell 시작 시간 |
|:---|:---:|
| oh-my-zsh (기본) | ~500ms |
| **새 설정** | ~50ms |

**10배 빠른 시작 시간!**

---

## 🔥 7. 추천 워크플로우

### Git 작업
```bash
# 1. 변경사항 확인
gs  # 또는 그냥 git status

# 2. lazygit 실행 (TUI)
lazygit

# 3. 커밋, 푸시, 리베이스 모두 TUI에서 처리
```

### 파일 찾기
```bash
# Ctrl+T: 현재 디렉토리에서 파일 검색
# 검색 후 Enter: 파일 경로가 명령어에 삽입됨

# 예: bat <Ctrl+T로 파일 선택>
```

### 디렉토리 이동
```bash
# 자주 가는 곳은 zoxide가 기억
z vibe      # ~/Desktop/git/vibe-skills로 점프
z user      # ~/Users/username으로 점프

# 처음 가는 곳은 cd 사용
cd ~/new/path
# 다음부터는 z new만 쳐도 됨
```

---

## 🐛 문제 해결

### Q: 한글 입력 후 Ctrl+C가 안 먹혀요
**A**: 기본 Terminal.app을 사용하세요. WezTerm, Alacritty 등은 한글 입력 모드에서 단축키 문제가 있을 수 있습니다.

### Q: 명령어가 녹색/빨간색으로 안 보여요
**A**: zsh-syntax-highlighting이 제대로 로드되지 않았습니다:
```bash
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

### Q: z 명령어가 안 돼요
**A**: zoxide를 새로 설치했다면 데이터베이스가 비어있습니다. cd로 몇 번 이동한 후 z를 사용하세요.

### Q: Ctrl+R을 눌렀는데 atuin이 안 나와요
**A**: atuin 초기화 확인:
```bash
atuin import auto  # 기존 히스토리 import
eval "$(atuin init zsh)"
```

---

## 📚 더 알아보기

- [Starship 문서](https://starship.rs/)
- [atuin GitHub](https://github.com/atuinsh/atuin)
- [zoxide GitHub](https://github.com/ajeetdsouza/zoxide)
- [fzf GitHub](https://github.com/junegunn/fzf)
