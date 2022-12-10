[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
[ -f "/opt/cargo/env" ] && source "/opt/cargo/env"

# Test out double-spawn functionality
export NEXTEST_EXPERIMENTAL_DOUBLE_SPAWN=1
