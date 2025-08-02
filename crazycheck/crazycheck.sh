#!/bin/bash

# Цвета
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # Сброс цвета

# Получаем файл из аргумента или используем по умолчанию *.c
FILE="${1:-*.c}"

check() {
    CMD="$1"
    DESC="$2"
    HOW="$3"

    if eval "$CMD" &>/dev/null; then
        echo -e "${GREEN}[ok] $DESC OK!${NC}"
    else
        echo -e "${RED}[fail] $DESC FAIL!${NC}"
        echo -e "${YELLOW}[info] How to check: $HOW${NC}"
    fi
}

# Проверки
check "clang-format --dry-run -Werror $FILE" "clang-format" "clang-format -n $FILE"
check "cppcheck --enable=all --suppress=missingIncludeSystem --error-exitcode=1 $FILE" "cppcheck" "cppcheck --enable=all --suppress=missingIncludeSystem $FILE"
check "gcc -Wall -Werror -Wextra -fsyntax-only $FILE" "gcc" "gcc -Wall -Werror -Wextra $FILE"
