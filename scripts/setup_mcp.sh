#!/bin/bash

# ==============================================================================
# 🔌 MCP 자동 설정 주입기 (다국어 지원 에디션 v3)
# ==============================================================================
# "제대로 처리합니다" - Node.js 및 Python 서버를 처리합니다.
# - 참조 서버를 복제(Clone)합니다.
# - npm을 통해 Node.js 서버를 빌드합니다.
# - uv를 통해 Python 서버를 실행합니다 (자동 설치됨).
# - 소스가 없는 경우 npx로 대체(Fallback)합니다.
# - "연결 종료(Connection closed)" 방지를 위해 모든 경로에 **절대 경로**를 사용합니다.
# ==============================================================================

# 색상 설정
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 필수 경로가 PATH에 포함되어 있는지 확인
export PATH="/bin:/usr/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/usr/local/bin:$PATH"

echo -e "\n${BLUE}=== 🔌 MCP 설정 및 구성 ===${NC}"

# 0. 환경 확인 및 도구 설치
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MCP_ROOT="$HOME/.agent_store/mcp-servers"

# Bun/Node 확인
if ! command -v bun &> /dev/null && ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js 또는 Bun이 필요합니다.${NC}"
    exit 1
fi

# UV 감지/설치 (Python 서버용)
if ! command -v uv &> /dev/null; then
    echo -e "${YELLOW}📦 도구 설치 중: uv (Python MCP 서버 구동에 필요)...${NC}"
    if command -v brew &> /dev/null; then
        brew install uv
    else
        echo -e "${RED}❌ 'uv'를 찾을 수 없으며 'brew'도 없습니다. uv를 수동으로 설치해주세요: curl -LsSf https://astral.sh/uv/install.sh | sh${NC}"
        exit 1
    fi
fi

# GUI 앱(NVM 등)에서 자주 누락되는 경로 확보
export PATH="$HOME/.nvm/versions/node/$(nvm current 2>/dev/null)/bin:$HOME/.bun/bin:$PATH"

# Node/Npx 절대 경로 감지 (에이전트/GUI 환경에서 필수)
NODE_BIN=$(which node)
if [[ -z "$NODE_BIN" ]]; then NODE_BIN=$(which bun); fi

NPX_BIN=$(which npx)
if [[ -z "$NPX_BIN" ]]; then NPX_BIN=$(which bunx); fi

# Python 도구(uv, uvx) 절대 경로 감지
UV_BIN=$(which uv)
UVX_BIN=$(which uvx)

echo "실행 환경 - Node: $NODE_BIN"
echo "실행 환경 - Npx:  $NPX_BIN"
echo "실행 환경 - UV:   $UV_BIN"
echo "실행 환경 - UVX:  $UVX_BIN"

# Git 확인
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git이 필요합니다.${NC}"
    exit 1
fi

# JQ/MV 절대 경로 확인
JQ="/usr/bin/jq"
if [[ ! -x "$JQ" ]]; then JQ=$(which jq); fi
# 필요 시 로컬 jq로 대체
if [[ -z "$JQ" ]]; then JQ=$(which jq); fi
MV="/bin/mv"

# 1. 클론 및 빌드
echo -e "\n${YELLOW}1. 참조 서버 가져오는 중...${NC}"

if [[ ! -d "$MCP_ROOT" ]]; then
    git clone https://github.com/modelcontextprotocol/servers.git "$MCP_ROOT"
else
    echo "   - 기존 저장소 업데이트 중..."
    cd "$MCP_ROOT" && git pull --rebase
fi

echo -e "\n${YELLOW}2. Node.js 서버 빌드 중...${NC}"
cd "$MCP_ROOT"

# NPM 환경 정리
unset NPM_TOKEN
unset NODE_AUTH_TOKEN
export NPM_CONFIG_REGISTRY=https://registry.npmjs.org/

# 설치 및 빌드 (Node 워크스페이스만 빌드하며 Python은 무시)
npm install
npm run build


# 3. 래퍼(Wrapper) 정의 (설정 정의 전에 반드시 수행해야 함)
mkdir -p "$HOME/.agent_store/bin"

# NPX 래퍼 (대체 실행용)
NPX_WRAPPER="$HOME/.agent_store/npx_clean.sh"
cat > "$NPX_WRAPPER" <<EOF
#!/bin/bash
export NPM_CONFIG_USERCONFIG=/dev/null
export NPM_CONFIG_GLOBALCONFIG=/dev/null
export NPM_CONFIG_REGISTRY=https://registry.npmjs.org/
EMPTY_RC_USER=\$(mktemp)
EMPTY_RC_GLOBAL=\$(mktemp)
exec "$NPX_BIN" "\$@"
EOF
chmod +x "$NPX_WRAPPER"

# 4. 서버 정의 (JSON 문자열)
# 시스템 PATH에 의존하는 단순 명령어 이름을 사용하여 설정을 이식성 있게 만듭니다.

# Fetch (Python / 웹 데이터 가져오기)
SERVER_FETCH='{
    "command": "uvx",
    "args": ["mcp-server-fetch"]
}'

# Time (Python / 시간 정보)
SERVER_TIME='{
    "command": "uvx",
    "args": ["mcp-server-time"]
}'

# Filesystem (Node / 파일 시스템 접근)
SERVER_FILESYSTEM='{
    "command": "node",
    "args": ["'$MCP_ROOT'/src/filesystem/dist/index.js", "'$HOME'/Desktop", "'$HOME'/Documents"]
}'

# Sequential Thinking (Node / 사고 과정)
SERVER_SEQUENTIAL='{
    "command": "node",
    "args": ["'$MCP_ROOT'/src/sequentialthinking/dist/index.js"]
}'

# Memory (Node / 기억 저장소)
# 참고: MEMORY_FILE_PATH 환경변수는 OpenCode용 inject_config에서 동적으로 처리됨
SERVER_MEMORY='{
    "command": "node",
    "args": ["'$MCP_ROOT'/src/memory/dist/index.js"],
    "env": {
        "MEMORY_FILE_PATH": "'$HOME'/.agent_store/memory_'"$(date +%F)"'.jsonl"
    }
}'

# Sqlite (Python / 정형 데이터)
SERVER_SQLITE='{
    "command": "uvx",
    "args": ["mcp-server-sqlite", "--db-path", "'$HOME'/.agent_store/memory.db"]
}'

# Playwright (Npx / 브라우저 제어)
SERVER_PLAYWRIGHT='{
  "command": "npx",
  "args": ["-y", "@playwright/mcp"]
}'

# Playwright Test (Npx / 테스팅)
SERVER_PLAYWRIGHT_TEST='{
  "command": "npx",
  "args": ["-y", "@executeautomation/playwright-mcp-server"]
}'

# Context7 (Npx / 문서 검색)
SERVER_CONTEXT7='{
    "command": "npx",
    "args": ["-y", "@upstash/context7-mcp"]
}'


# 5. 주입 로직
# 참고: 디렉토리가 존재하지 않는 타겟은 스크립트가 건너뜁니다
TARGETS=(
    "$HOME/.gemini/antigravity/mcp_config.json|Antigravity Agent"
    "$HOME/.copilot/mcp-config.json|GitHub Copilot"
    "$HOME/.gemini/settings.json|Gemini Code Assist"
    "$HOME/Library/Application Support/Claude/claude_desktop_config.json|Claude Desktop"
    "$HOME/Library/Application Support/Cursor/User/globalStorage/mcp.json|Cursor Editor"
    "$HOME/.codeium/windsurf/mcp_config.json|Windsurf Editor"
    "$HOME/.config/opencode/opencode.json|OpenCode Config"
)

inject_config() {
    local file=$1
    local name=$2
    local dir="${file%/*}"
    
    [[ ! -d "$dir" ]] && return
    
    echo -n "   - 설정 중: ${name}... "
    if [[ ! -f "$file" ]]; then
        # OpenCode의 경우 파일이 없으면 초기화 방식이 다르지만, 보통은 이미 존재합니다.
        # 다른 도구들을 위해 간단한 초기화로 대체합니다.
        mkdir -p "$dir"
        echo '{"mcpServers":{}}' > "$file"
    fi
    
    local tmp_file="${file}.tmp"
    
    # JQ 확인
    if [[ ! -x "$JQ" ]]; then echo "jq 누락됨 ($JQ)"; return; fi

    # OpenCode 특별 처리
    if [[ "$file" == *"opencode"* ]]; then
        # 루트 'mcp' 객체가 존재하는지 확인
        "$JQ" '.mcp = (.mcp // {})' "$file" > "$tmp_file" && "$MV" "$tmp_file" "$file"
        
        # 포맷 변환과 함께 서버 주입
        for srv_key in "fetch=$SERVER_FETCH" "time=$SERVER_TIME" "sequential-thinking=$SERVER_SEQUENTIAL" "memory=$SERVER_MEMORY" "sqlite=$SERVER_SQLITE" "playwright=$SERVER_PLAYWRIGHT" "playwright-test=$SERVER_PLAYWRIGHT_TEST" "context7=$SERVER_CONTEXT7"; do
            key="${srv_key%%=*}"
            json="${srv_key#*=}"
            
            # 표준 설정을 OpenCode 포맷으로 변환:
            # { command: "cmd", args: ["arg1"], env: {"K":"V"} } 
            # -> { type: "local", command: ["/usr/bin/env", "K=V", "cmd", "arg1"], enabled: true }
            "$JQ" --arg name "$key" --argjson config "$json" \
            '.mcp[$name] = {
                type: "local",
                command: (
                    if $config.env then
                        ["/usr/bin/env"] + ($config.env | to_entries | map("\(.key)=\(.value)")) + [$config.command] + $config.args
                    else
                        [$config.command] + $config.args
                    end
                ),
                enabled: true
            }' \
            "$file" > "$tmp_file" && "$MV" "$tmp_file" "$file"
             
             echo -n "$key "
        done

    else
        # 표준 MCP 설정 처리
        "$JQ" '.mcpServers = (.mcpServers // {})' "$file" > "$tmp_file" && "$MV" "$tmp_file" "$file"
        "$JQ" 'del(.mcpServers.git, .mcpServers.filesystem)' "$file" > "$tmp_file" && "$MV" "$tmp_file" "$file"

        for srv_key in "fetch=$SERVER_FETCH" "time=$SERVER_TIME" "sequential-thinking=$SERVER_SEQUENTIAL" "memory=$SERVER_MEMORY" "sqlite=$SERVER_SQLITE" "playwright=$SERVER_PLAYWRIGHT" "playwright-test=$SERVER_PLAYWRIGHT_TEST" "context7=$SERVER_CONTEXT7"; do
            key="${srv_key%%=*}"
            json="${srv_key#*=}"
            
            # GitHub Copilot CLI는 'tools' 필드가 필요하지만, Gemini CLI는 필요하지 않음
            if [[ "$file" == *"copilot"* ]]; then
                "$JQ" --arg name "$key" --argjson config "$json" \
                '.mcpServers[$name] = ($config + {"tools": ["*"]})' \
                "$file" > "$tmp_file" && "$MV" "$tmp_file" "$file"
            else
                "$JQ" --arg name "$key" --argjson config "$json" \
                '.mcpServers[$name] = $config' \
                "$file" > "$tmp_file" && "$MV" "$tmp_file" "$file"
            fi
            echo -n "$key "
        done
    fi
    
    echo -e "${GREEN}✅ 완료.${NC}"
}

echo -e "\n${YELLOW}3. 설정 주입 중...${NC}"
for item in "${TARGETS[@]}"; do
    path="${item%%|*}"
    desc="${item##*|}"
    inject_config "$path" "$desc"
done

echo -e "\n${BLUE}=== MCP 설정 완료 ===${NC}"
