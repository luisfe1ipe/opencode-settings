# check_macos function to support both Darwin and WSL
check_macos() {
    if [[ "$(uname)" == "Darwin" || "$(uname)" == "Linux" ]]; then
        echo "Running on macOS or WSL"
    else
        echo "Not running on supported OS"
    fi
}