#!/bin/bash

# ==== Colors ====
BOLD="\033[1m"
BRED="\033[0;91m"
BGREEN="\033[0;92m"
BYELLOW="\033[0;93m"
BBLUE="\033[0;94m"
BCYAN="\033[0;96m"
NC="\033[0m"

# ==== Colorful Log Tags ====
run()   { echo -e "[${BYELLOW}RUN${NC}] $*"; }
ok()    { echo -e "[${BGREEN}OK${NC}] $*"; }
info()  { echo -e "[${BBLUE}INFO${NC}] $*"; }
warn()  { echo -e "[${BYELLOW}WARN${NC}] $*"; }
err()   { echo -e "[${BRED}ERR${NC}] $*"; }

# ==== Constants ====
INSTALL_DIR="$HOME/mpushkarev-projects/crazycheck"
SCRIPT_PATH="$INSTALL_DIR/crazycheck.sh"

# ==== Determine shell config ====
if [ -n "$ZSH_VERSION" ] || [ "$(basename "$SHELL")" = "zsh" ]; then
    SHELL_RC="$HOME/.zshrc"
    SHELL_RC_NAME="~/.zshrc"
else
    SHELL_RC="$HOME/.bashrc"
    SHELL_RC_NAME="~/.bashrc"
fi

# ==== Functions ====
is_installed() { 
    [ -f "$SCRIPT_PATH" ] || grep -q "alias crazycheck=" "$SHELL_RC" 2>/dev/null
}

remove_files() {
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
    fi
}

remove_alias() {
    if grep -q "alias crazycheck=" "$SHELL_RC" 2>/dev/null; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "/^alias crazycheck=/d" "$SHELL_RC"
        else
            sed -i "/^alias crazycheck=/d" "$SHELL_RC"
        fi
    fi
}

print_header() {
    echo -e "${BRED}┌───────────────────────────────┐${NC}"
    echo -e "${BRED}│   ${BOLD}crazycheck.sh uninstaller${NC}${BRED}   │${NC}"
    echo -e "${BRED}└───────────────────────────────┘${NC}"
}

# ==== Main Uninstallation ====
main() {
    print_header

    if ! is_installed; then
        err "Utility is not installed"
        exit 0
    fi

    run "Uninstalling..."
    
    remove_files
    remove_alias

    ok "Uninstallation complete"
}

main "$@"
