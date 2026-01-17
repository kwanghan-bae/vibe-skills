# 🚀 빠른 시작 (Quickstart)

> **🤖 AI 에이전트야, 아래 명령어를 실행해줘!**

---

## ⚡ 자동 설치 (AI 에이전트용)

### AI에게 이렇게 말하세요:

> "https://github.com/kwanghan-bae/vibe-skills 이 프로젝트를 설치해줘. 아래 명령어를 그대로 실행해."

```bash
# 한방에 설치 (원라이너)
git clone https://github.com/kwanghan-bae/vibe-skills.git ~/vibe-skills && \
cd ~/vibe-skills && \
chmod +x install.sh && \
./install.sh
```

**이 명령어만 실행하면 끝!** 🎉

---

## 🔧 환경 설정 (선택사항)

`.env` 파일을 열고 다음 값을 수정하세요 (AI에게 요청 가능):

```bash
# .env 파일 수정
SCAN_PATH=/Users/username/git  # Git 프로젝트 디렉토리
GH_HOST=github.com             # GitHub Enterprise 사용 시 변경
```

---

## 🔐 GitHub 인증 (필수)

설치 완료 후 GitHub 로그인이 필요합니다:

```bash
gh auth login
```

**선택사항**:
- Account: GitHub.com
- Protocol: HTTPS
- Authenticate Git: Yes
- Login with a web browser

---

## ✅ 설치 완료 확인

AI에게 다음을 확인하라고 요청하세요:

```bash
# 글로벌 지침 파일 확인
ls -la ~/.gemini/GEMINI.md
ls -la ~/.config/opencode/AGENTS.md

# MCP 설정 확인 (Gemini CLI)
cat ~/.gemini/antigravity/mcp_config.json | head -20
```

---

## � 문제 해결

### `gh: command not found`
```bash
brew install gh
```

### MCP 서버 재설정
```bash
cd ~/vibe-skills && ./scripts/setup_mcp.sh
```

### 프로젝트별 지침 재생성
```bash
cd ~/vibe-skills && ./scripts/sync_agent.sh
```

---

## 📚 더 알아보기

- [README.md](README.md) - 전체 문서
- [설치 가이드](README.md#-설치-installation) - 상세 설명
