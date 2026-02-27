#!/bin/bash

# =============================================================================
# OpenCode Agents Installation - Developer
# =============================================================================

set -e

# Get script directory in a way that works with both bash and sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Use dot sourcing which works with both bash and sh
. "${SCRIPT_DIR}/common.sh"

# =============================================================================
# Detect OS
# =============================================================================
detect_os() {
    if grep -qi "microsoft" /proc/version 2>/dev/null; then
        echo "wsl"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)

# =============================================================================
# Main
# =============================================================================
print_title "Developer Installation"

check_platform
install_dependencies
setup_config

echo "◇  Agents"
copy_agent laravel.md
copy_agent nextjs.md
copy_agent fullstack.md
print_section_end

install_skills

print_final "Done"
print_next_steps