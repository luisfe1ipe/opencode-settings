
#!/bin/bash

# =============================================================================
# OpenCode Agents Installation - Common Functions
# =============================================================================

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
AGENT_SRC="${REPO_DIR}/agent"
COMMAND_SRC="${REPO_DIR}/command"

CONFIG_DIR="${HOME}/.config/opencode"
AGENT_DIR="${CONFIG_DIR}/agent"
SUBAGENT_DIR="${AGENT_DIR}/subagents"
COMMAND_DIR="${CONFIG_DIR}/command"

# Marker to identify managed files
MARKER="@dev"

# -----------------------------------------------------------------------------
# Colors
# -----------------------------------------------------------------------------
DIM='\033[2m'
YELLOW='\033[33m'
NC='\033[0m'

# -----------------------------------------------------------------------------
# Spinner
# -----------------------------------------------------------------------------
spinner() {
	local pid=$1
	local message=$2
	local spinchars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
	local i=0

	tput civis
	while kill -0 $pid 2>/dev/null; do
		local char="${spinchars:$i:1}"
		printf "\r│  %s %s" "$char" "$message"
		i=$(((i + 1) % ${#spinchars}))
		sleep 0.1
	done
	tput cnorm
	printf "\r"
}

run_with_spinner() {
	local message=$1
	shift
	local command="$@"

	eval "$command" &>/dev/null &
	local pid=$!

	spinner $pid "$message"

	wait $pid
	return $?
}

# -----------------------------------------------------------------------------
# Print Functions
# -----------------------------------------------------------------------------
print_title() {
	local subtitle=$1
	echo ""
	echo "  OpenCode Agents"
	echo -e "  ${DIM}${subtitle}${NC}"
	echo ""
}

print_section_start() {
	echo "┌  $1"
}

print_item() {
	echo "│  $1"
}

print_done() {
	echo "│  ✓ $1"
}

print_skip() {
	echo -e "│  ${YELLOW}○${NC} $1 ${DIM}(user customized)${NC}"
}

print_update() {
	echo "│  ↑ $1"
}

print_new() {
	echo "│  + $1"
}

print_error() {
	echo "│  ✗ $1"
}

print_section_end() {
	echo "│"
}

print_final() {
	echo "└  $1"
}

print_next_steps() {
	echo ""
	echo -e "   ${DIM}Next steps:${NC}"
	echo -e "   ${DIM}1. opencode auth login        # Login with GitHub Copilot${NC}"
	echo -e "   ${DIM}2. opencode mcp auth jira     # Authenticate Jira (optional)${NC}"
	echo -e "   ${DIM}3. opencode mcp auth notion   # Authenticate Notion (optional)${NC}"
	echo -e "   ${DIM}4. Start Figma MCP if needed${NC}"
	echo -e "   ${DIM}5. opencode                   # Start OpenCode${NC}"
	echo ""
}

# -----------------------------------------------------------------------------
# System Checks
# -----------------------------------------------------------------------------
check_macos() {
	if [[ "$(uname)" != "Darwin" ]]; then
		print_error "This script is only supported on macOS"
		exit 1
	fi
}

# -----------------------------------------------------------------------------
# Installation Functions
# -----------------------------------------------------------------------------
install_homebrew() {
	if command -v brew &>/dev/null; then
		print_done "Homebrew"
	else
		run_with_spinner "Installing Homebrew" '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
		if [[ $? -ne 0 ]]; then
			print_error "Failed to install Homebrew"
			exit 1
		fi
		print_done "Homebrew"
	fi
}

install_opencode_cli() {
	if command -v opencode &>/dev/null; then
		print_done "OpenCode CLI"
	else
		run_with_spinner "Installing OpenCode CLI" "brew install opencode"
		if [[ $? -ne 0 ]]; then
			print_error "Failed to install OpenCode CLI"
			exit 1
		fi
		print_done "OpenCode CLI"
	fi
}

install_opencode_desktop() {
	if [[ -d "/Applications/OpenCode.app" ]]; then
		print_done "OpenCode Desktop"
	else
		run_with_spinner "Installing OpenCode Desktop" "brew install --cask opencode-desktop"
		if [[ $? -ne 0 ]]; then
			print_error "Failed to install OpenCode Desktop"
			exit 1
		fi
		print_done "OpenCode Desktop"
	fi
}

install_dependencies() {
	print_section_start "Dependencies"
	install_homebrew
	install_opencode_cli
	install_opencode_desktop
	print_section_end
}

# -----------------------------------------------------------------------------
# Config Functions
# -----------------------------------------------------------------------------
create_directories() {
	mkdir -p "$SUBAGENT_DIR"
	mkdir -p "$COMMAND_DIR"
}

create_opencode_json() {
	local config_file="${CONFIG_DIR}/opencode.json"

	# Check if file exists and has our marker (in a comment-safe way for JSON)
	if [[ -f "$config_file" ]]; then
		# For JSON, we check if it contains our schema URL as identifier
		if grep -q "opencode.ai/config.json" "$config_file" 2>/dev/null; then
			# It's our file, update it
			:
		else
			# User's custom file, skip
			print_skip "opencode.json"
			return
		fi
	fi

	cat >"$config_file" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "figma": {
      "type": "remote",
      "url": "http://127.0.0.1:3845/mcp",
      "enabled": true
    },
    "jira": {
      "type": "remote",
      "url": "https://mcp.atlassian.com/v1/sse",
      "enabled": true,
      "oauth": {}
    },
    "notion": {
      "type": "remote",
      "url": "https://mcp.notion.com/sse",
      "enabled": true,
      "oauth": {}
    },
    "playwright": {
      "type": "local",
      "command": [
        "npx",
        "@playwright/mcp@latest"
      ],
      "enabled": true
    }
  }
}
EOF
}

setup_config() {
	create_directories
	create_opencode_json

	echo "◇  Configuration"
	print_item "opencode.json"
	print_section_end
}

# -----------------------------------------------------------------------------
# Smart Copy Functions
# -----------------------------------------------------------------------------

# Check if a file is managed by (has our marker)
is_managed_file() {
	local file="$1"
	if [[ -f "$file" ]]; then
		grep -q "$MARKER" "$file" 2>/dev/null
		return $?
	fi
	return 1
}

# Prompt user for file update
prompt_update() {
	local name="$1"

	if [[ "$UPDATE_ALL" == true ]]; then
		return 0
	fi

	if [[ "$SKIP_ALL" == true ]]; then
		return 1
	fi

	echo -e "│  ${YELLOW}?${NC} ${name} has a new version"
	read -p "│    Update? [y]es / [n]o / [A]ll / [S]kip all: " choice

	case "$choice" in
		y|Y) return 0 ;;
		n|N) return 1 ;;
		A) UPDATE_ALL=true; return 0 ;;
		S) SKIP_ALL=true; return 1 ;;
		*) return 1 ;;
	esac
}

# Smart copy that preserves user customizations
# - New file: copy it
# - Existing with marker: ask to update (it's ours)
# - Existing without marker: skip it (user's custom file)
smart_copy() {
	local src_file="$1"
	local target_file="$2"
	local name="$3"

	if [[ ! -f "$src_file" ]]; then
		print_error "Source not found: ${name}"
		exit 1
	fi

	if [[ ! -f "$target_file" ]]; then
		# New file, just copy
		cp "$src_file" "$target_file"
		print_new "$name"
	elif is_managed_file "$target_file"; then
		# Our file, check if different and ask to update
		if ! diff -q "$src_file" "$target_file" &>/dev/null; then
			if prompt_update "$name"; then
				cp "$src_file" "$target_file"
				print_update "$name"
			else
				print_skip "$name"
			fi
		else
			print_done "$name"
		fi
	else
		# User's custom file, preserve it
		print_skip "$name"
	fi
}

copy_agent() {
	local agent="$1"
	local src_file="${AGENT_SRC}/${agent}"
	local target_file="${AGENT_DIR}/${agent}"

	smart_copy "$src_file" "$target_file" "$agent"
}

copy_subagent() {
	local subagent="$1"
	local src_file="${AGENT_SRC}/subagents/${subagent}"
	local target_file="${SUBAGENT_DIR}/${subagent}"

	smart_copy "$src_file" "$target_file" "$subagent"
}

copy_command() {
	local command="$1"
	local src_file="${COMMAND_SRC}/${command}"
	local target_file="${COMMAND_DIR}/${command}"

	smart_copy "$src_file" "$target_file" "$command"
}