#!/bin/bash

BOLD="\033[1m"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

check_files_exist() {
    if ! find . -type f \( -name "*.c" -o -name "*.h" \) -print | grep -q .; then
        echo -e "[${RED}ERR${NC}] No ${BOLD}.c${NC} or ${BOLD}.h${NC} files found!"
        exit 1
    fi
}

check_clang_format() {
    local has_errors=0

    while IFS= read -r file; do
        if ! clang-format \
            --style="{BasedOnStyle: Google, IndentWidth: 4, ColumnLimit: 110}" \
            --dry-run --Werror "$file" >/dev/null 2>&1; then
            echo -e "[${RED}FAIL${NC}] clang-format failed in ${BOLD}$file${NC}!"
            has_errors=1
        fi
    done < <(find . -type f \( -name "*.c" -o -name "*.h" \))

    if [[ $has_errors -eq 0 ]]; then
        echo -e "[${GREEN}OK${NC}] clang-format ok"
    fi
}

check_cppcheck() {
    if cppcheck --enable=all --suppress=missingIncludeSystem --error-exitcode=1 . \
        1>/dev/null 2>&1; then
        echo -e "[${GREEN}OK${NC}] cppcheck ok"
    else
        echo -e "[${RED}FAIL${NC}] cppcheck found issues!"
    fi
}

check_gcc_compile() {
    local has_errors=0

    while IFS= read -r file; do
        if ! gcc -Wall -Werror -Wextra -c "$file" -o /dev/null 2>/dev/null; then
            echo -e "[${RED}FAIL${NC}] gcc failed in ${BOLD}$file${NC}!"
            has_errors=1
        fi
    done < <(find . -type f -name "*.c")

    if [[ $has_errors -eq 0 ]]; then
        echo -e "[${GREEN}OK${NC}] gcc ok"
    fi
}


echo -e "[${YELLOW}RUN${NC}] Working..."
check_files_exist
check_clang_format
check_cppcheck
check_gcc_compile
