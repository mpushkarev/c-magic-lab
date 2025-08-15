#include <stdio.h>

// === Константы игрового поля ===
#define FIELD_WIDTH 80
#define FIELD_HEIGHT 25
#define PADDLE_SIZE 3
#define WINNING_SCORE 21

// === Позиции элементов ===
#define BALL_START_X (FIELD_WIDTH / 2)
#define BALL_START_Y (FIELD_HEIGHT / 2)
#define PADDLE_START_Y (FIELD_HEIGHT / 2)
#define PADDLE_LEFT_X 1
#define PADDLE_RIGHT_X (FIELD_WIDTH - 2)

// === Символы отображения ===
#define SYMBOL_BORDER_HORIZONTAL '-'
#define SYMBOL_BORDER_VERTICAL '|'
#define SYMBOL_PADDLE 'H'
#define SYMBOL_BALL '*'
#define SYMBOL_EMPTY ' '

// === Клавиши управления ===
#define KEY_P1_UP 'A'
#define KEY_P1_DOWN 'Z'
#define KEY_P2_UP 'K'
#define KEY_P2_DOWN 'M'
#define KEY_QUIT 'Q'

// === Прототипы функций ===
void display_score(int score1, int score2);
void display_field(int ball_x, int ball_y, int paddle1_y, int paddle2_y);
void display_controls(void);
int update_paddle_p1(int paddle_y, char key);
int update_paddle_p2(int paddle_y, char key);
int handle_ball_collision_x(int ball_x, int ball_y, int dx, int paddle1_y, int paddle2_y);
int handle_ball_collision_y(int ball_y, int dy);
int check_goal(int ball_x);
int abs_value(int x);

int main() {
    char input;
    int ball_x = BALL_START_X, ball_y = BALL_START_Y;
    int paddle1_y = PADDLE_START_Y, paddle2_y = PADDLE_START_Y;
    int dx = 1, dy = 1;
    int score1 = 0, score2 = 0;

    display_controls();

    while ((input = getchar()) != KEY_QUIT && score1 != WINNING_SCORE && score2 != WINNING_SCORE) {
        if (input != '\n' && (input == KEY_P1_UP || input == KEY_P1_DOWN || input == KEY_P2_UP ||
                              input == KEY_P2_DOWN || input == ' ')) {
            // Обновляем позиции ракеток
            paddle1_y = update_paddle_p1(paddle1_y, input);
            paddle2_y = update_paddle_p2(paddle2_y, input);

            // Обрабатываем столкновения мяча
            dx = handle_ball_collision_x(ball_x, ball_y, dx, paddle1_y, paddle2_y);
            dy = handle_ball_collision_y(ball_y, dy);

            // Проверяем голы
            int goal_result = check_goal(ball_x);
            if (goal_result == 1) {
                score1++;
                ball_x = BALL_START_X;
                ball_y = BALL_START_Y;
            } else if (goal_result == -1) {
                score2++;
                ball_x = BALL_START_X;
                ball_y = BALL_START_Y;
            }

            // Обновляем позицию мяча
            ball_x += dx;
            ball_y += dy;

            // Отображаем игру
            display_score(score1, score2);
            display_field(ball_x, ball_y, paddle1_y, paddle2_y);
            display_controls();
        }
    }

    // Объявляем победителя
    if (score1 == WINNING_SCORE) {
        printf("Поздравляем! Игрок 1 победил!\n");
    }

    if (score2 == WINNING_SCORE) {
        printf("Поздравляем! Игрок 2 победил!\n");
    }

    return 0;
}

void display_score(int score1, int score2) {
    // Центрируем счет
    for (int i = 0; i < FIELD_WIDTH / 2 - 12; i++) {
        printf(" ");
    }
    printf("Player 1 score = %d | Player 2 score = %d\n", score1, score2);
}

void display_field(int ball_x, int ball_y, int paddle1_y, int paddle2_y) {
    for (int y = 0; y < FIELD_HEIGHT; y++) {
        for (int x = 0; x < FIELD_WIDTH; x++) {
            // Верхняя и нижняя границы
            if (y == 0 || y == FIELD_HEIGHT - 1) {
                printf("%c", SYMBOL_BORDER_HORIZONTAL);
            }
            // Левая ракетка (центр и соседние позиции)
            else if (x == PADDLE_LEFT_X && (y == paddle1_y || y == paddle1_y - 1 || y == paddle1_y + 1)) {
                printf("%c", SYMBOL_PADDLE);
            }
            // Правая ракетка
            else if (x == PADDLE_RIGHT_X && (y == paddle2_y || y == paddle2_y - 1 || y == paddle2_y + 1)) {
                printf("%c", SYMBOL_PADDLE);
            }
            // Левая и правая стенки
            else if (x == 0 || x == FIELD_WIDTH - 1) {
                printf("%c", SYMBOL_BORDER_VERTICAL);
            }
            // Мяч
            else if (ball_y == y && ball_x == x) {
                printf("%c", SYMBOL_BALL);
            }
            // Пустое пространство
            else {
                printf("%c", SYMBOL_EMPTY);
            }
        }
        printf("\n");
    }
}

void display_controls(void) {
    printf("Press %c, %c, %c, %c or space\n", KEY_P2_UP, KEY_P2_DOWN, KEY_P1_UP, KEY_P1_DOWN);
}

int update_paddle_p1(int paddle_y, char key) {
    if (key == KEY_P1_UP && paddle_y > 2) {
        paddle_y--;
    }
    if (key == KEY_P1_DOWN && paddle_y <= FIELD_HEIGHT - 4) {
        paddle_y++;
    }
    return paddle_y;
}

int update_paddle_p2(int paddle_y, char key) {
    if (key == KEY_P2_UP && paddle_y > 2) {
        paddle_y--;
    }
    if (key == KEY_P2_DOWN && paddle_y <= FIELD_HEIGHT - 4) {
        paddle_y++;
    }
    return paddle_y;
}

int handle_ball_collision_x(int ball_x, int ball_y, int dx, int paddle1_y, int paddle2_y) {
    // Столкновение с правой ракеткой
    if ((ball_x == PADDLE_RIGHT_X) && (abs_value(ball_y - paddle2_y) <= 1)) {
        dx = -dx;
    } else if ((ball_x == PADDLE_RIGHT_X - 1) && (abs_value(ball_y - paddle2_y) <= 1)) {
        dx = -dx;
    }
    // Столкновение с левой ракеткой
    else if ((ball_x == PADDLE_LEFT_X) && (abs_value(ball_y - paddle1_y) <= 1)) {
        dx = -dx;
    } else if ((ball_x == PADDLE_LEFT_X + 1) && (abs_value(ball_y - paddle1_y) <= 1)) {
        dx = -dx;
    }

    return dx;
}

int handle_ball_collision_y(int ball_y, int dy) {
    // Столкновение с верхней и нижней стенками
    if (ball_y >= FIELD_HEIGHT - 2 && dy > 0) {
        dy = -dy;
    }
    if (ball_y <= 1 && dy < 0) {
        dy = -dy;
    }
    return dy;
}

int check_goal(int ball_x) {
    if (ball_x <= 0) {
        return -1;  // Гол в ворота игрока 1 (очко игроку 2)
    }
    if (ball_x >= FIELD_WIDTH - 1) {
        return 1;  // Гол в ворота игрока 2 (очко игроку 1)
    }
    return 0;  // Гола нет
}

int abs_value(int x) { return x < 0 ? -x : x; }
