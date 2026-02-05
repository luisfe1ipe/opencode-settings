
#!/bin/bash

# =============================================================================
# OpenCode Agents Installation - Developer
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
print_title "Developer Installation"
check_macos

install_dependencies
setup_config

echo "◇  Agents"
copy_agent "developer.md"
copy_agent "arquitect.md"
print_section_end

echo "◇  Subagents"
copy_subagent "doc-writer.md"
print_section_end

echo "◇  Commands"
copy_command "dev-plan.md"
copy_command "tasks.md"
copy_command "dev.md"
copy_command "review.md"
copy_command "commit.md"
copy_command "pr.md"
copy_command "doc-feature.md"
print_section_end

print_final "Done"
print_next_steps