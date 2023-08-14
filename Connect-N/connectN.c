/*
Name: Jaiden Angeles
Group: Assignment 2 21
Asgn#: 2
Asgn name: ConnectN
Date: July 10, 2023
*/

/*
Description:
This program is a console-based game of Connect N, like Connect 4 but with customizable board size and win condition. 
It prompts the players for their moves and makes sure they're legal (can't stack pieces too high, can't place them outside the board). 
The game keeps going until a player has N pieces in a line (horizontally, vertically, or diagonally), then declares them the winner.
*/

//Including required studios
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdbool.h>

//Define MAXSIZE, MINSIZE, and MINCONNECTNUM constants
#define MAXSIZE 25
#define MINSIZE 8
#define MINCONNECTNUM 4

//Declare the function prototypes: InitializeBoard, MakeMove, DisplayBoard, and CheckWinner
int InitializeBoard(int** connectNBoard, int numRowsInBoard);
int MakeMove(int** connectNBoard, int numRowsInBoard, int playerID, int columnChosen);
int DisplayBoard(int** connectNBoard, int numRowsInBoard);
int CheckWinner(int** connectNBoard, int numRowsInBoard, int numConnect, int columnChosen, int playerID);

//The main function which will run the game
int main() {
    int numRows, numToConnect;
    int currentPlayer = 1;
    int consecutiveInvalidMoves = 0;

    // Prompt for board size & read input
    while (1) {
        printf("Enter the number of squares along each edge of the board: ");
        char input[MAXSIZE];
        if (fgets(input, sizeof(input), stdin) == NULL) {
            printf("ERROR: Failed to read input\n");
            return 1;
        }

        if (sscanf(input, "%d", &numRows) != 1) {
            printf("ERROR: The value provided was not an number\n");
            continue;
        }

        // Validate board size and ensure it is within the min/max. E.g. handling errors
        if (numRows < MINSIZE) {
            printf("ERROR: Board size too small (<%d)\n", MINSIZE);
            continue;
        } else if (numRows > MAXSIZE) {
            printf("ERROR: Board size too large (>%d)\n", MAXSIZE);
            continue;
        }

        break;
    }

    // Prompt for the number of pieces needed to win
    while (1) {
        printf("Enter the number of pieces that must form a line to win: ");
        char input[MAXSIZE];
        if (fgets(input, sizeof(input), stdin) == NULL) {
            printf("ERROR: Failed to read input\n");
            return 1;
        }

        if (sscanf(input, "%d", &numToConnect) != 1) {
            printf("ERROR: The value provided was not a number\n");
            continue;
        }

        // Validate number of pieces to connect
        if (numToConnect < MINCONNECTNUM) {
            printf("ERROR: Number to connect is too small (<%d)\n", MINCONNECTNUM);
            continue;
        } else if (numToConnect > numRows - MINCONNECTNUM) {
            printf("ERROR: Number to connect is too large (>%d)\n", numRows - MINCONNECTNUM);
            continue;
        }

        break;
    }

    // Dynamically allocate the game board
    int** connectNBoard = (int**)malloc(numRows * sizeof(int*));
    for (int i = 0; i < numRows; i++) {
        connectNBoard[i] = (int*)malloc(numRows * sizeof(int));
    }

    // Initialize the game board
    if (!InitializeBoard(connectNBoard, numRows)) {
        printf("ERROR: Could not initialize the game board\n");
        return 1;
    }
        int boardChanged = 1;
        
    // Game loop
        while (1) {
       if (boardChanged) {
        printf("\n\n");
        DisplayBoard(connectNBoard, numRows);
        boardChanged = 0; // Reset the flag
        printf("%s moves\n", currentPlayer == 1 ? "Red" : "Black");
    }
    
        
        // Prompt for the column number where the player wants to put their piece
        int chosenColumn;
        char chosen[100];
        while (1) {
            printf("Enter the column number where you want to put your piece: ");
            scanf("%s", &chosen);
            char* ptr = chosen;
            if (isdigit(*ptr) || *ptr == '-') {
               chosenColumn = atoi(chosen);
               break;  // Exit the loop
            }
            while (*ptr && !isdigit(*ptr)) {
                ptr++;
            }
            printf("%s", ptr);
            chosenColumn = atoi(ptr);

            //If 'chosenColumn' is NULL, the input wasn't a number. Increase the counter for invalid moves and possibly forfeit a turn for the current player.
            if (chosenColumn == NULL) {
                printf("ERROR: The value provided was not a number\n");

                consecutiveInvalidMoves++;
                    if (consecutiveInvalidMoves == 3) {
                printf("TOO MANY ILLEGAL MOVES\n");
                printf("%s has forfeited a turn\n", currentPlayer == 1 ? "Red" : "Black");
                printf("\n\n");
                DisplayBoard(connectNBoard, numRows);
                boardChanged = 0; // Reset the flag
                printf("%s moves\n", currentPlayer == 2 ? "Red" : "Black");
                
                currentPlayer = currentPlayer == 1 ? 2 : 1;
                consecutiveInvalidMoves = 0;
                continue;
            }
                continue;
            }
        
            //If 'chosenColumn' is less than 0 or greater than or equal to 'numRows', the chosen column is out of board's bounds. Increase the counter for invalid moves
            if (chosenColumn < 0 || chosenColumn >= numRows) {
                printf("ERROR: Column %d is not on the board: try again\n",chosenColumn);
                printf("ERROR: Column number should be >= 0 and < %d\n", numRows);
                 
                
                consecutiveInvalidMoves++;
                if (consecutiveInvalidMoves == 3) {
                printf("TOO MANY ILLEGAL MOVES\n");
                printf("%s has forfeited a turn\n", currentPlayer == 1 ? "Red" : "Black");
                printf("\n\n");
                DisplayBoard(connectNBoard, numRows);
                boardChanged = 0; // Reset the flag
                printf("%s moves\n", currentPlayer == 2 ? "Red" : "Black");
                
                currentPlayer = currentPlayer == 1 ? 2 : 1;
                consecutiveInvalidMoves = 0;
                continue;
            }
                continue;
            }
            //If the chosen column is full, increase the counter for invalid moves and possibly forfeit a turn for the current player.       
            if (connectNBoard[0][chosenColumn] != 0) {
                printf("ERROR: Column %d is already full\n", chosenColumn);
                consecutiveInvalidMoves++;
                if (consecutiveInvalidMoves == 3) {
                printf("TOO MANY ILLEGAL MOVES\n");
                printf("%s has forfeited a turn\n", currentPlayer == 1 ? "Red" : "Black");
                printf("\n\n");
                DisplayBoard(connectNBoard, numRows);
                boardChanged = 0; // Reset the flag
                printf("%s moves\n", currentPlayer == 2 ? "Red" : "Black");
                
                currentPlayer = currentPlayer == 1 ? 2 : 1;
                consecutiveInvalidMoves = 0;
                continue;
            }
                continue;
            }
    
            break;
        }
    
        // Check for consecutive invalid moves
        if (consecutiveInvalidMoves == 3) {
            printf("TOO MANY ILLEGAL MOVES\n");
            printf("%s has forfeited a turn\n", currentPlayer == 1 ? "Red" : "Black");
            printf("\n\n");
            DisplayBoard(connectNBoard, numRows);
            boardChanged = 0; // Reset the flag
            printf("%s moves\n", currentPlayer == 2 ? "Red" : "Black");
            currentPlayer = currentPlayer == 1 ? 2 : 1;
            consecutiveInvalidMoves = 0;                    // Reset consecutiveInvalidMoves to 0 after a valid move is made
            continue;
        }

    
        // Make a move on the game board
        int moveResult = MakeMove(connectNBoard, numRows, currentPlayer, chosenColumn);
        //  Handle case where the selected column is already full
        if (moveResult == -1) {     //
            printf("ERROR: Column %d is already full\n", chosenColumn);
            consecutiveInvalidMoves++;
            if (consecutiveInvalidMoves == 3) {
             printf("TOO MANY ILLEGAL MOVES\n");
             printf("%s has forfeited a turn\n", currentPlayer == 1 ? "Red" : "Black");
             printf("\n\n");
             DisplayBoard(connectNBoard, numRows);
                boardChanged = 0; // Reset the flag
                printf("%s moves\n", currentPlayer == 2 ? "Red" : "Black");
             currentPlayer = currentPlayer == 1 ? 2 : 1;
             consecutiveInvalidMoves = 0;
             continue;
            }
            continue;
        } else if (moveResult == 0) {       // Handle case where the selected column is out of board range
                printf("ERROR: Column %d is not on the board: try again\n",chosenColumn);
                printf("ERROR: Column number should be >= 0 and < %d\n", numRows);

                consecutiveInvalidMoves++;
                    if (consecutiveInvalidMoves == 3) {
                printf("TOO MANY ILLEGAL MOVES\n");
                printf("%s has forfeited a turn\n", currentPlayer == 1 ? "Red" : "Black");
                printf("\n\n");
                DisplayBoard(connectNBoard, numRows);
                boardChanged = 0; // Reset the flag
                printf("%s moves\n", currentPlayer == 2 ? "Red" : "Black");
                
                currentPlayer = currentPlayer == 1 ? 2 : 1;
                consecutiveInvalidMoves = 0;
                continue;
            }
                
                continue;
                
            }
           
            if (moveResult == 1) {
                boardChanged = 1; // Set the flag to indicate board change
            }
        consecutiveInvalidMoves = 0;
        // Display the move message
        printf("%s has moved\n", currentPlayer == 1 ? "Red" : "Black");
    
        // Check for a winner
        int winner = CheckWinner(connectNBoard, numRows, numToConnect, chosenColumn, currentPlayer);
        if (winner) {
            printf("\n\n");
            DisplayBoard(connectNBoard, numRows);
            printf("\n%s WON!\n", currentPlayer == 1 ? "RED" : "BLACK");
            break;
        }


        // Switch to the next player
        currentPlayer = currentPlayer == 1 ? 2 : 1;
        consecutiveInvalidMoves = 0;
    }
    
    // Free memory allocated for the game board
    for (int i = 0; i < numRows; i++) {
        free(connectNBoard[i]);
    }
    free(connectNBoard);

    return 0;
}

// Function definitions
// Initialize the board to empty spaces
int InitializeBoard(int** connectNBoard, int numRowsInBoard) {
    for (int i = 0; i < numRowsInBoard; i++) {
        for (int j = 0; j < numRowsInBoard; j++) {
            connectNBoard[i][j] = 0;
        }
    }
    return 1;
}

// Function to attempt to make a move for a player at a chosen column in the board
int MakeMove(int** connectNBoard, int numRowsInBoard, int playerID, int columnChosen) {
    if (columnChosen < 0 || columnChosen >= numRowsInBoard) {
        return 0;
    }

    for (int i = numRowsInBoard - 1; i >= 0; i--) {
        if (connectNBoard[i][columnChosen] == 0) {
            connectNBoard[i][columnChosen] = playerID;
            return 1;
        }
    }

    return -1;
}

// Function to display the current state of the game board with appropriate markings
int DisplayBoard(int** connectNBoard, int numRowsInBoard) {
    // Print the column numbers
    printf("---");

    for (int i = 0; i < numRowsInBoard; i++) {
        printf("%2d ", i);
    }
    printf("\n");

    // Print the board
    for (int i = 0; i < numRowsInBoard; i++) {
        printf("%2d ", i);
        for (int j = 0; j < numRowsInBoard; j++) {
            if (connectNBoard[i][j] == 0) {
                printf(" o ");
            } else if (connectNBoard[i][j] == 1) {
                printf(" R ");
            } else if (connectNBoard[i][j] == 2) {
                printf(" B ");
            }
        }
        printf("\n");
    }

    return 1;
}

// Check for a winner
int CheckWinner(int** connectNBoard, int numRowsInBoard, int numConnect, int columnChosen, int playerID) {
    int i, j;
    int count;

    // Check for horizontal win
    for (i = 0; i < numRowsInBoard; i++) {
        count = 0;
        for (j = 0; j < numRowsInBoard; j++) {
            if (connectNBoard[i][j] == playerID) {
                count++;
                if (count == numConnect)
                    return 1;  // Horizontal win
            } else {
                count = 0;
            }
        }
    }

    // Check for vertical win
    for (j = 0; j < numRowsInBoard; j++) {
        count = 0;
        for (i = 0; i < numRowsInBoard; i++) {
            if (connectNBoard[i][j] == playerID) {
                count++;
                if (count == numConnect)
                    return 1;  // Vertical win
            } else {
                count = 0;
            }
        }
    }

    // Check for diagonal win (top-left to bottom-right)
    for (i = 0; i < numRowsInBoard - numConnect + 1; i++) {
        for (j = 0; j < numRowsInBoard - numConnect + 1; j++) {
            count = 0;
            for (int k = 0; k < numConnect; k++) {
                if (connectNBoard[i + k][j + k] == playerID) {
                    count++;
                    if (count == numConnect)
                        return 1;  // Diagonal win
                } else {
                    count = 0;
                }
            }
        }
    }

    // Check for diagonal win (top-right to bottom-left)
    for (i = 0; i < numRowsInBoard - numConnect + 1; i++) {
        for (j = numConnect - 1; j < numRowsInBoard; j++) {
            count = 0;
            for (int k = 0; k < numConnect; k++) {
                if (connectNBoard[i + k][j - k] == playerID) {
                    count++;
                    if (count == numConnect)
                        return 1;  // Diagonal win
                } else {
                    count = 0;
                }
            }
        }
    }

    return 0;  // No winner (false)
}