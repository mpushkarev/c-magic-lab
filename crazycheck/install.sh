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
fail()  { echo -e "[${BRED}FAIL${NC}] $*"; }

# ==== Constants ====
INSTALL_DIR="$HOME/mpushkarev-projects/crazycheck"
SCRIPT_PATH="$INSTALL_DIR/crazycheck.sh"
RAW_URL="https://raw.githubusercontent.com/mpushkarev/c-magic-lab/main/crazycheck/crazycheck.sh"

# ==== Determine shell config ====
if [ -n "$ZSH_VERSION" ] || [ "$(basename "$SHELL")" = "zsh" ]; then
    SHELL_RC="$HOME/.zshrc"
    SHELL_RC_NAME="~/.zshrc"
else
    SHELL_RC="$HOME/.bashrc"
    SHELL_RC_NAME="~/.bashrc"
fi

# ==== Functions to check installation status ====
is_script_installed() { [ -f "$SCRIPT_PATH" ]; }
is_alias_present()    { grep -q "alias crazycheck=" "$SHELL_RC" 2>/dev/null; }

# ==== Actions ====
download_script() {
    curl -fsSL "$RAW_URL" -o "$SCRIPT_PATH" 2>/dev/null
}

make_executable() {
    chmod +x "$SCRIPT_PATH"
}

add_alias() {
    local red_err="[\033[0;91mERR\033[0m]"
    echo "alias crazycheck='[ -f \"$SCRIPT_PATH\" ] || printf \"$red_err Utility missing. Maybe you deleted it? Try reinstalling.\n\"; [ -f \"$SCRIPT_PATH\" ] && \"$SCRIPT_PATH\"'" >> "$SHELL_RC"
}

remove_alias() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/^alias crazycheck=/d" "$SHELL_RC"
    else
        sed -i "/^alias crazycheck=/d" "$SHELL_RC"
    fi
}

print_header() {
    echo -e "${BCYAN}┌───────────────────────────────┐${NC}"
    echo -e "${BCYAN}│    ${BOLD}crazycheck.sh installer${NC}${BCYAN}    │${NC}"
    echo -e "${BCYAN}└───────────────────────────────┘${NC}"
}

# ==== Main Installation ====
main() {
    print_header

    if is_script_installed && is_alias_present; then
        warn "Already installed"
        read -rp "[?] Reinstall anyway? (Y/n): " answer
        answer="${answer:-y}"
        if [[ "${answer,,}" != "y" ]]; then
            info "Aborted."
            exit 0
        fi
        WAS_INSTALLED=1
    fi

    mkdir -p "$INSTALL_DIR"

    run "Downloading..."

    if download_script; then
        ok "Downloaded"
        make_executable
    else
        err "Download failed"
        exit 1
    fi

    run "Installing..."

    if ! is_alias_present; then
        add_alias
    else
        remove_alias && add_alias
    fi

    ok "Installation complete"
    if [ "$WAS_INSTALLED" != 1 ]; then
        info "Reload shell or run: ${BOLD}source $SHELL_RC_NAME${NC}"
    fi
}

main "$@"
