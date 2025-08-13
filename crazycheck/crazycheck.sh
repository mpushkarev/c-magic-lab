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

# ==== Actions ====
check_files_exist() {
    if ! find . -type f \( -name "*.c" -o -name "*.h" \) -print | grep -q .; then
        err "No ${BOLD}.c${NC} or ${BOLD}.h${NC} files found!"
        exit 1
    fi
}

check_clang_format() {
    local has_errors=0

    while IFS= read -r file; do
        if ! clang-format \
            --style="{BasedOnStyle: Google, IndentWidth: 4, ColumnLimit: 110}" \
            --dry-run --Werror "$file" >/dev/null 2>&1; then
            err "clang-format failed in ${BOLD}$file${NC}!"
            has_errors=1
        fi
    done < <(find . -type f \( -name "*.c" -o -name "*.h" \))

    if [[ $has_errors -eq 0 ]]; then
        ok "clang-format ok"
    fi
}

check_cppcheck() {
    if cppcheck --enable=all --suppress=missingIncludeSystem --error-exitcode=1 . 1>/dev/null 2>&1; then
        ok "cppcheck ok"
    else
        err "cppcheck found issues!"
    fi
}

check_gcc_compile() {
    local has_errors=0

    while IFS= read -r file; do
        if ! gcc -Wall -Werror -Wextra -c "$file" -o /dev/null 2>/dev/null; then
            err "gcc failed in ${BOLD}$file${NC}!"
            has_errors=1
        fi
    done < <(find . -type f -name "*.c")

    if [[ $has_errors -eq 0 ]]; then
        ok "gcc ok"
    fi
}

run "Working..."
check_files_exist
check_clang_format
check_cppcheck
check_gcc_compile
