#include "state.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "snake_utils.h"


/* Helper function definitions */
static void set_board_at(game_state_t *state, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_state_t *state, unsigned int snum);
static char next_square(game_state_t *state, unsigned int snum);
static void update_tail(game_state_t *state, unsigned int snum);
static void update_head(game_state_t *state, unsigned int snum);

/* Task 1 */
game_state_t *create_default_state() {
  game_state_t *default_state = (game_state_t *) malloc(sizeof(game_state_t));
  if (default_state == NULL) {
    perror("Failed to allocate memory for default_state");
    return NULL;
  }

  default_state->board = (char **) malloc(18 * sizeof(char *));
  if (default_state->board == NULL) {
    perror("Failed to allocate memory for default_state");
    return NULL;
  }
  
  for (int i = 0; i < 18; i++) {
    default_state->board[i] = (char *) malloc(21 * sizeof(char));
    if (default_state->board[i] == NULL) {
      perror("Failed to allocate memory for default_state");
      return NULL;
    }
  }

  default_state->snakes = (snake_t *) malloc(sizeof(snake_t));
  if (default_state->snakes == NULL) {
    perror("Failed to allocate memory for default_state");
      return NULL;
  }

  default_state->num_rows = 18;
  default_state->num_snakes = 1;
  default_state->snakes[0] = (snake_t){.tail_col = 2, .tail_row = 2, 
                                        .head_row = 2, .head_col = 4, .live = true};

  strcpy(default_state->board[0], "####################\n");
  for (int i = 1; i <= 16; i++) {
    if (i == 2) {
      continue;
    }
    strcpy(default_state->board[i], "#                  #\n");
  }
  strcpy(default_state->board[2], "# d>D    *         #\n");
  strcpy(default_state->board[17], "####################\n");

  return default_state;  
}

/* Task 2 */
void free_state(game_state_t *state) {
  free(state->snakes);
  for (int i = 0; i < state->num_rows; i++) {
    free(state->board[i]);
  }
  free(state->board);
  free(state);
  return;
}

/* Task 3 */
void print_board(game_state_t *state, FILE *fp) {
  for (int row = 0; row < state->num_rows; row++) {
    fprintf(fp, "%s", state->board[row]);
  }
  return;
}

/*
  Saves the current state into filename. Does not modify the state object.
  (already implemented for you).
*/
void save_board(game_state_t *state, char *filename) {
  FILE *f = fopen(filename, "w");
  print_board(state, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_state_t *state, unsigned int row, unsigned int col) { return state->board[row][col]; }

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_state_t *state, unsigned int row, unsigned int col, char ch) {
  state->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
  return c == 'w' || c == 'a' || c == 's' || c == 'd';
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
  return c == 'W' || c == 'A' || c == 'S' || c == 'D' || c == 'x';
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
  bool is_body = c == '^' || c == '<' || c == '>' || c == 'v';
  return is_body || is_head(c) || is_tail(c);
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
  switch (c) {
  case '^':
    return 'w';
    break;
  case 'v':
    return 's';
    break;
  case '<':
    return 'a';
    break;
  case '>':
    return 'd';
    break;
  default:
    return '\0';
  }
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
  switch (c) {
  case 'W':
    return '^';
    break;
  case 'A':
    return '<';
    break;
  case 'S':
    return 'v';
    break;
  case 'D':
    return '>';
    break;
  default:
    return '\0';
  }
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
  if (c == 'v' || c == 'S' || c == 's') {
    return cur_row + 1;
  } else if (c == '^' || c == 'W' || c == 'w') {
    return cur_row - 1;
  } else {
    return cur_row;
  }
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
  if (c == '>' || c == 'd' || c == 'D') {
    return cur_col + 1;
  } else if (c == '<' || c == 'a' || c == 'A') {
    return cur_col - 1;
  } else {
    return cur_col;
  }
}

/*
  Task 4.2

  Helper function for update_state. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_state_t *state, unsigned int snum) {
  unsigned int head_row = state->snakes[snum].head_row;
  unsigned int head_col = state->snakes[snum].head_col;
  char head = get_board_at(state, head_row, head_col);
  
  unsigned int next_row = get_next_row(head_row, head);
  unsigned int next_col = get_next_col(head_col, head);
  
  return get_board_at(state, next_row, next_col);
}

/*
  Task 4.3

  Helper function for update_state. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_state_t *state, unsigned int snum) {
  unsigned int head_row = state->snakes[snum].head_row;
  unsigned int head_col = state->snakes[snum].head_col;
  char head = get_board_at(state, head_row, head_col);
  
  unsigned int next_row = get_next_row(head_row, head);
  unsigned int next_col = get_next_col(head_col, head);
  set_board_at(state, next_row, next_col, head);
  set_board_at(state, head_row, head_col, head_to_body(head));

  state->snakes[snum].head_col = next_col;
  state->snakes[snum].head_row = next_row;
  return;
}

/*
  Task 4.4

  Helper function for update_state. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_state_t *state, unsigned int snum) {
  unsigned int tail_row = state->snakes[snum].tail_row;
  unsigned int tail_col = state->snakes[snum].tail_col;
  char tail = get_board_at(state, tail_row, tail_col);
  
  unsigned int next_row = get_next_row(tail_row, tail);
  unsigned int next_col = get_next_col(tail_col, tail);
  set_board_at(state, next_row, next_col, body_to_tail(get_board_at(state, next_row, next_col)));
  set_board_at(state, tail_row, tail_col, ' ');

  state->snakes[snum].tail_col = next_col;
  state->snakes[snum].tail_row = next_row;
  return;
}

/* Task 4.5 */
void update_state(game_state_t *state, int (*add_food)(game_state_t *state)) {
  for (unsigned int i = 0; i < state->num_snakes; i++) {
    snake_t snake = state->snakes[i];
    unsigned int head_row = snake.head_row;
    unsigned int head_col = snake.head_col;
    char head = get_board_at(state, head_row, head_col);
    unsigned int next_row = get_next_row(head_row, head);
    unsigned int next_col = get_next_col(head_col, head);
    
    char next_head = get_board_at(state, next_row, next_col);
    
    if (next_head == '#' || is_snake(next_head)) {
      state->snakes[i].live = false;
      set_board_at(state, head_row, head_col, 'x');
    } else if (next_head == '*') {
      update_head(state, i);
      (*add_food)(state);
    } else {
      update_head(state, i);
      update_tail(state, i);
    }
  }
  return;
}

/* Task 5.1 */
char *read_line(FILE *fp) {
  int length = 0;
  unsigned int buff_size = 10;
  char *buff = (char * ) malloc(sizeof(char) * buff_size);
  if (buff == NULL) {
    free(buff);
    return NULL;
  }

  while (fgets(buff + length, buff_size, fp)) {
    if (strchr(buff + length, '\n')) {
      return buff;
    }

    length += buff_size - 1;
    buff_size *= 2;
    buff = realloc(buff, buff_size);
  }
  
  return NULL;
}

/* Task 5.2 */
game_state_t *load_board(FILE *fp) {
  // TODO: Implement this function.
  game_state_t *state = (game_state_t *) malloc(sizeof(game_state_t));
  state->num_rows = 0;
  state->snakes = NULL;
  state->num_snakes = 0;
  state->board = NULL;

  char *line = NULL;
  while (line = read_line(fp)) {
    char **temp = (char **) realloc(state->board, (state->num_rows + 1) * sizeof(char *));
    
    if (temp == NULL) {
      free(temp);
      free(state->board);
      free(state);
      return NULL;
    }

    temp[state->num_rows] = line;
    state->board = temp;
    (state->num_rows)++;
  }

  return state;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_state_t *state, unsigned int snum) {
  // TODO: Implement this function.
  return;
}

/* Task 6.2 */
game_state_t *initialize_snakes(game_state_t *state) {
  // TODO: Implement this function.
  return NULL;
}
