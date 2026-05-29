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
COMMAND_SRC="${REPO_DIR}/commands"
SKILL_SRC="${REPO_DIR}/skills"

CONFIG_DIR="${HOME}/.config/opencode"
AGENT_DIR="${CONFIG_DIR}/agent"
SUBAGENT_DIR="${AGENT_DIR}/subagents"
COMMAND_DIR="${CONFIG_DIR}/command"
SKILL_DIR="${CONFIG_DIR}/skills"

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
	while kill -0 "$pid" 2>/dev/null; do
		local char="${spinchars:$i:1}"
		printf "\r│  %s %s" "$char" "$message"
		i=$(((i + 1) % ${#spinchars}))
		sleep 0.1
	done
	tput cnorm
	printf "\r\033[K"
}

run_with_spinner() {
	local message=$1
	shift
	local command="$@"

	eval "$command" &>/dev/null &
	local pid=$!

	spinner "$pid" "$message"

	wait "$pid"
	local result=$?
	echo ""
	return $result
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

print_section_start() { echo "┌  $1"; }
print_item() { echo "│  $1"; }
print_done() { echo "│  ✓ $1"; }
print_update() { echo "│  ↑ $1"; }
print_new() { echo "│  + $1"; }

print_skip() {
	echo -e "│  ${YELLOW}○${NC} $1 ${DIM}(user customized)${NC}"
}

print_error() { echo "│  ✗ $1"; }
print_section_end() { echo "│"; }
print_final() { echo "└  $1"; }

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

# ---------------------------------------------------------------------------
# Platform Check — Supported Platforms
# ---------------------------------------------------------------------------
check_platform() {
	local is_wsl=false
	local is_linux=false

	if grep -qi microsoft /proc/version 2>/dev/null; then
		is_wsl=true
	fi

	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		is_linux=true
	fi

	if ! ($is_wsl || $is_linux); then
		print_error "This installer only supports WSL, PopOS, Ubuntu, and other Linux distributions"
		exit 1
	fi
}

# ---------------------------------------------------------------------------
# Installation — OpenCode CLI
# ---------------------------------------------------------------------------
install_opencode_cli() {
	if command -v opencode &>/dev/null; then
		print_done "OpenCode CLI"
		return
	fi

	print_item "Installing OpenCode CLI (curl installer)"

	run_with_spinner "Installing OpenCode CLI" \
		"curl -fsSL https://opencode.ai/install | bash"

	# Reload PATH after installation
	if [ -f "${HOME}/.profile" ]; then
		. "${HOME}/.profile"
	fi
	if [ -f "${HOME}/.bashrc" ]; then
		. "${HOME}/.bashrc"
	fi

	# Check common installation locations
	if [ -f "${HOME}/.local/bin/opencode" ]; then
		export PATH="${HOME}/.local/bin:${PATH}"
	elif [ -f "${HOME}/.local/bin/opencode-ai" ]; then
		export PATH="${HOME}/.local/bin:${PATH}"
	fi

	if command -v opencode &>/dev/null; then
		print_done "OpenCode CLI"
		return
	fi

	if command -v npm &>/dev/null; then
		print_item "Fallback: Installing OpenCode CLI via npm"

		run_with_spinner "Installing via npm" \
			"npm install -g opencode-ai"

		# Reload PATH after npm installation
		if [ -f "${HOME}/.profile" ]; then
			. "${HOME}/.profile"
		fi
		if [ -f "${HOME}/.bashrc" ]; then
			. "${HOME}/.bashrc"
		fi

		if command -v opencode &>/dev/null; then
			print_done "OpenCode CLI (npm fallback)"
			return
		fi
	fi

	print_error "Failed to install OpenCode CLI"
	print_item "Install manually: https://opencode.ai/docs"
	exit 1
}

# -----------------------------------------------------------------------------
# Dependencies Entry
# -----------------------------------------------------------------------------
install_dependencies() {
	print_section_start "Dependencies"
	install_opencode_cli
	print_section_end
}

# -----------------------------------------------------------------------------
# Config Functions
# -----------------------------------------------------------------------------
create_directories() {
	mkdir -p "$SUBAGENT_DIR"
	mkdir -p "$COMMAND_DIR"
	mkdir -p "$SKILL_DIR"
}

create_opencode_json() {
	local config_file="${CONFIG_DIR}/opencode.json"

	if [[ -f "$config_file" ]]; then
		if grep -q "opencode.ai/config.json" "$config_file" 2>/dev/null; then
			:
		else
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
is_managed_file() {
	local file="$1"
	if [[ -f "$file" ]]; then
		grep -q "$MARKER" "$file" 2>/dev/null
		return $?
	fi
	return 1
}

prompt_update() {
	local name="$1"

	if [[ "$UPDATE_ALL" == true ]]; then return 0; fi
	if [[ "$SKIP_ALL" == true ]]; then return 1; fi

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

smart_copy() {
	local src_file="$1"
	local target_file="$2"
	local name="$3"

	if [[ ! -f "$src_file" ]]; then
		print_error "Source not found: ${name}"
		exit 1
	fi

	if [[ ! -f "$target_file" ]]; then
		cp "$src_file" "$target_file"
		print_new "$name"
	elif is_managed_file "$target_file"; then
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
		print_skip "$name"
	fi
}

# -----------------------------------------------------------------------------
# Copy Agents / Commands
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# Commands Installation
# -----------------------------------------------------------------------------
install_commands() {
	print_section_start "Commands"

	if [[ -d "$COMMAND_SRC" ]]; then
		for file in "$COMMAND_SRC"/*.md; do
			[[ -f "$file" ]] || continue
			copy_command "$(basename "$file")"
		done
	fi

	print_section_end
}

# -----------------------------------------------------------------------------
# Skills Installation (GLOBAL)
# -----------------------------------------------------------------------------
copy_skill() {
	local skill="$1"
	local src_dir="${SKILL_SRC}/${skill}"
	local target_dir="${SKILL_DIR}/${skill}"

	if [[ ! -d "$src_dir" ]]; then
		print_error "Skill source not found: ${skill}"
		exit 1
	fi

	if [[ ! -d "$target_dir" ]]; then
		cp -r "$src_dir" "$target_dir"
		print_new "skill:${skill}"
		return
	fi

	local src_file="${src_dir}/SKILL.md"
	local target_file="${target_dir}/SKILL.md"

	if is_managed_file "$target_file"; then
		if ! diff -q "$src_file" "$target_file" &>/dev/null; then
			if prompt_update "skill:${skill}"; then
				cp "$src_file" "$target_file"
				print_update "skill:${skill}"
			else
				print_skip "skill:${skill}"
			fi
		else
			print_done "skill:${skill}"
		fi
	else
		print_skip "skill:${skill}"
	fi
}

install_skills() {
	print_section_start "Skills"

	if [[ -d "$SKILL_SRC" ]]; then
		for dir in "$SKILL_SRC"/*; do
			[[ -d "$dir" ]] || continue
			copy_skill "$(basename "$dir")"
		done
	fi

	print_section_end
}

# ---------------------------------------------------------------------------
# Entry Point (only execute if sourced as main script, not when included)
# ---------------------------------------------------------------------------
# This section is left empty since common.sh is meant to be sourced by other scripts
# The calling script (dev.sh) will control the execution flow
