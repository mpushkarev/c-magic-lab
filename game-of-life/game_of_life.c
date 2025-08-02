#include <stdio.h>
#include <unistd.h>

// === Константы ===
#define WIDTH 80
#define HEIGHT 25
// todo: потом в цифрах 1-9
#define BASE_SPEED 0.1
#define SYMBOL_LIVE "\033[0;32mo"  // note: green "o"
#define SYMBOL_DEATH "\033[90m*"   // note: gray "*"
#define NEW_LINE_ASCII_CODE 10
#define DOT_ASCII_CODE 46
#define LIVE_ASCII_CODE 111

// === Прототипы функций ===
int init_game(int field[HEIGHT][WIDTH]);
void print_field(int field[HEIGHT][WIDTH]);
void evolve_all_cells(int field[HEIGHT][WIDTH]);
int get_live_neighbors_count(int x, int y, int field[HEIGHT][WIDTH]);
int get_neighbor_status(int x, int y, int dx, int dy, int field[HEIGHT][WIDTH]);

// === Основной процесс игры ===
int main() {
    // note: создаем поле для игры
    int field[HEIGHT][WIDTH];

    if (init_game(field) != 1) return 1;

    // note: запускаем игровой цикл
    while (1) {
        evolve_all_cells(field);
        print_field(field);
        usleep(BASE_SPEED * 1000000);
        // todo: сделать выход
    }

    return 0;
}

// === Реализация функций ===
int init_game(int field[HEIGHT][WIDTH]) {
    // note: если это терминал, а не файл, то выход
    if (isatty(fileno(stdin))) {
        printf("Ошибка: это не перенаправленный ввод!");
        return 0;
    }

    int selected_symbol;
    int x_counter = 0;
    int y_counter = 0;

    while ((selected_symbol = getchar()) != EOF) {
        switch (selected_symbol) {
            case DOT_ASCII_CODE:
                field[y_counter][x_counter] = 0;
                x_counter++;
                break;
            case LIVE_ASCII_CODE:
                field[y_counter][x_counter] = 1;
                x_counter++;
                break;
            case NEW_LINE_ASCII_CODE:
                x_counter = 0;
                y_counter++;
                break;
        }
    }

    return 1;
}

void print_field(int field[HEIGHT][WIDTH]) {
    for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
            field[y][x] ? printf(SYMBOL_LIVE) : printf(SYMBOL_DEATH);
        }
        printf("\n");  // note: перенос в конце строки
    }
    printf("\n");  // note: пустая строка-разделитель при выводе
}

void evolve_all_cells(int field[HEIGHT][WIDTH]) {
    // note: временный буфер для нового поля
    int field_buffer[HEIGHT][WIDTH];

    // note: пробегаем и считаем статус в этом поколении
    for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
            int live_neighbors = get_live_neighbors_count(x, y, field);
            int current = field[y][x];
            // note: клетка живёт, если жива и 2-3 соседа, или мертва и 3 соседа
            if ((current == 1 && (live_neighbors == 2 || live_neighbors == 3)) ||
                (current == 0 && live_neighbors == 3)) {
                field_buffer[y][x] = 1;
            } else {
                field_buffer[y][x] = 0;
            }
        }
    }

    // note: обновим поле из буфера
    for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
            field[y][x] = field_buffer[y][x];
        }
    }
}

int get_live_neighbors_count(int x, int y, int field[HEIGHT][WIDTH]) {
    // note: счетчик кол-ва живых
    int counter = 0;

    for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
            int isCenter = (dx == 0 && dy == 0);
            if (!isCenter) {
                counter += get_neighbor_status(x, y, dx, dy, field);
            }
        }
    }

    return counter;
}

int get_neighbor_status(int x, int y, int dx, int dy, int field[HEIGHT][WIDTH]) {
    int nx = (x + dx + WIDTH) % WIDTH;
    int ny = (y + dy + HEIGHT) % HEIGHT;
    return field[ny][nx] == 1 ? 1 : 0;
}
