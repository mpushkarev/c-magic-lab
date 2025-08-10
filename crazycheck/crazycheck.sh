#!/bin/bash

BOLD="\033[1m"
BRED="\033[0;91m"
BGREEN="\033[0;92m"
BYELLOW="\033[0;93m"
BBLUE="\033[0;94m"
BCYAN="\033[0;96m"
NC="\033[0m"

print_run() {
    local text="$1"
    echo -e "[${BYELLOW}RUN${NC}] ${text}"
}

print_success() {
    local message="$1"
    echo -e "[${BGREEN}OK${NC}] ${message}"
}

print_error() {
    local message="$1"
    echo -e "[${BRED}FAIL${NC}] ${message}"
}

check_files_exist() {
    if ! find . -type f \( -name "*.c" -o -name "*.h" \) -print | grep -q .; then
        print_error "No ${BOLD}.c${NC} or ${BOLD}.h${NC} files found!"
        exit 1
    fi
}

check_clang_format() {
    local has_errors=0

    while IFS= read -r file; do
        if ! clang-format \
            --style="{BasedOnStyle: Google, IndentWidth: 4, ColumnLimit: 110}" \
            --dry-run --Werror "$file" >/dev/null 2>&1; then
            print_error "clang-format failed in ${BOLD}$file${NC}!"
            has_errors=1
        fi
    done < <(find . -type f \( -name "*.c" -o -name "*.h" \))

    if [[ $has_errors -eq 0 ]]; then
        print_success "clang-format ok"
    fi
}

check_cppcheck() {
    if cppcheck --enable=all --suppress=missingIncludeSystem --error-exitcode=1 . \
        1>/dev/null 2>&1; then
        print_success "cppcheck ok"
    else
        print_error "cppcheck found issues!"
    fi
}

check_gcc_compile() {
    local has_errors=0

    while IFS= read -r file; do
        if ! gcc -Wall -Werror -Wextra -c "$file" -o /dev/null 2>/dev/null; then
            print_error "gcc failed in ${BOLD}$file${NC}!"
            has_errors=1
        fi
    done < <(find . -type f -name "*.c")

    if [[ $has_errors -eq 0 ]]; then
        print_success "gcc ok"
    fi
}

print_run "Working..."
check_files_exist
check_clang_format
check_cppcheck
check_gcc_compile
