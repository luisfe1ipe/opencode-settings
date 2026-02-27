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
# Main
# =============================================================================
print_title "Developer Installation"

install_dependencies
setup_config

echo "◇  Agents"
copy_agent laravel.md
copy_agent nextjs.md
copy_agent fullstack.md
print_section_end



print_final "Done"
print_next_steps