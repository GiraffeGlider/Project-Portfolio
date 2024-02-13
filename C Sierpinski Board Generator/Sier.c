/*Jaiden Angeles
Asgn: Assignment 1 Problem 1 - SIER
Date: June 16, 2023 
*/


//Including the libraries for the program including stdio.h, stdlib.h, ctype.h
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

//Defining the constants for the program
void FillZero(int **my2DArray, int M, int N) {
    for (int i = 0; i < M; ++i) {
        for (int j = 0; j < N; ++j) {
            my2DArray[i][j] = 0;
        }
    }
}

//Fills the array with the values from the file
void CopyArray(int **my2DArray, int **myNextGenArray, int M, int N) {
    for (int i = 0; i < M; ++i) {
        int *destRow = *(my2DArray + i);
        int *srcRow = *(myNextGenArray + i);
        for (int j = 0; j < N; ++j) {
            *(destRow + j) = *(srcRow + j);
        }
    }
}
void NextGen(int **board, int M, int N) {   //M is the number of rows, N is the number of columns
    int **nextGenBoard = (int **)malloc(M * sizeof(int *));
    if (nextGenBoard == NULL) {
        printf("ERROR: Memory not allocated for nextGenBoard.\n");
        exit(0);
    }
    for (int i = 0; i < M; ++i) {           //Allocating memory for the columns
        nextGenBoard[i] = (int *)malloc(N * sizeof(int));
        if (nextGenBoard[i] == NULL) {
            printf("ERROR: Memory not allocated for nextGenBoard[%d].\n", i);
            exit(0);
        }
    }
    FillZero(nextGenBoard, M, N);           //Filling the array with 0s
    //Filling the array with the values from the file
    for (int k = 0; k < M; ++k) {
        for (int j = 0; j < N; ++j) {
            if (k == 0 || j == 0) {
                nextGenBoard[k][j] = 0;
            } else {
 /*
                nextGenBoard[k][j] = (board[k][j] + board[k-1][j] + board[k][j-1]) % 2;
*/
                nextGenBoard[k][j] = (board[k][j] + board[k-1][j] + board[k][j-1]) % 2;
            }
        }
    }
    //Copying the array to the nextGenBoard
    CopyArray(board, nextGenBoard, M, N);
    //Freeing the memory allocated for the nextGenBoard
    for (int i = 0; i < M; ++i) {
        free(nextGenBoard[i]);
    }
    free(nextGenBoard);
}

//Prints the board to the output file
void printBoard(int **board, int M, int N, FILE *outputFile, int generation) {
    fprintf(outputFile, "Sierpinski gameboard: generation %d\n\n", generation);
    printf("Sierpinski gameboard: generation %d\n\n", generation);
    //Printing the board to the output file
    for (int i = 0; i < M; ++i) {
        for (int j = 0; j < N; ++j) {
            char ch = (board[i][j] == 1) ? '1' : ' ';
            fprintf(outputFile, "%c", ch);
            printf("%c", ch);
        }
        fprintf(outputFile, "\n");
        printf("\n");
    }
    fprintf(outputFile, "\n\n");
    printf("\n\n");
}
//Main function which runs the program
int main() {
    char outputFileName[50];
    char inputFileName[50];
    FILE *outputFile;
    FILE *inputFile;
    int M, N, numRows, numCols, generations, generationIncrement;
    //Getting the name of the output file
    printf("Enter the name of the output file: ");
    scanf("%s", outputFileName);

    // Open output file
    outputFile = fopen(outputFileName, "w");
    if (outputFile == NULL) {
        printf("ERROR: Output file not opened correctly.\n");
        return 1;
    }
    //Getting the name of the input file
    printf("Enter the name of the input file: ");
    scanf("%s", inputFileName);

    // Open input file
    inputFile = fopen(inputFileName, "r");
    if (inputFile == NULL) {
        printf("ERROR: Input file not opened correctly.\n");
        fclose(outputFile); // Close the output file
        return 1;
    }
    //Getting the number of rows and columns from the input file
    printf("Enter the number of rows in the board (0<number<40) ");
    do {
        // Read the number of rows
        if (scanf("%d", &numRows) != 1) {
            printf("ERROR: The value of numRows is not an integer\n");
            fclose(inputFile);
            fclose(outputFile);
            return 1;
        }
        if (numRows <= 0 || numRows >= 40) {        //Checking if the number of rows is valid
            printf("ERROR: Read an illegal number of rows for board\nTRY AGAIN, 0 < number of rows < 40 ");
        }
    } while (numRows <= 0 || numRows >= 40);        //Looping until the number of rows is valid
    printf("Enter the number of columns in the board (0<number<80) ");
    do {
 
        if (scanf("%d", &numCols) != 1) {           //Checking if the number of columns is an integer
            printf("ERROR: The value of numCols is not an integer\n");
            fclose(inputFile);
            fclose(outputFile);
            return 1;
        }
        if (numCols <= 0 || numCols >= 80) {        //Checking if the number of columns is valid
            printf("ERROR: Read an illegal number of columns for board\nTRY AGAIN, 0 < number of columns < 80 ");
        }
    } while (numCols <= 0 || numCols >= 80);

    if (fscanf(inputFile, "%d", &generations) != 1) {   //Checking the number of generations
        printf("ERROR: Could not read the number of generations\n");     
        fclose(inputFile);
        fclose(outputFile);
        return 1;
    }

    if (generations < 0) {                              //Checking if the number of generations is valid
        printf("ERROR: Read an illegal number of generations\n");
        fclose(inputFile);
        fclose(outputFile);
        return 1;
    }
  
    if (fscanf(inputFile, "%d", &generationIncrement) != 1) {          //Checking the generation increment
        printf("ERROR: Could not read the generation increment\n"); 
        fclose(inputFile);
        fclose(outputFile);
        return 1;
    }

    if (generationIncrement < 1 || generationIncrement > generations) { //Checking if the generation increment is valid
        printf("ERROR: Read an illegal generation increment\n");        
        fclose(inputFile);
        fclose(outputFile);
        return 1;
    }

    char nextChar;                                                      //Checking if there is any extra input
    if (fscanf(inputFile, " %c", &nextChar) != EOF && !isspace(nextChar)) {
        printf("ERROR: generation increment is not an integer\n");
        fclose(inputFile);
        fclose(outputFile);
        return 1;
    }
    //Setting the number of rows and columns
    M = numRows;
    N = numCols;

    //Creating the board
    int **board = (int **)malloc(M * sizeof(int *));
    for (int i = 0; i < M; ++i) {
        board[i] = (int *)malloc(N * sizeof(int));
    }
    FillZero(board, M, N);
 
    //Setting the initial position
    if (M > 3 && N > 1) {
        board[1][3] = 1;
    } else {
        printf("ERROR: Board size does not allow initial position [1][3] to be 1.\n");
        fclose(inputFile);
        fclose(outputFile);
        return 1;
    }
    //Printing the initial board
    printBoard(board, M, N, outputFile, 1);

    //Generating the next generations
    for (int i = 2; i <= generations; ++i) {
        NextGen(board, M, N);
        if (i % generationIncrement == 0 || i == generations) {
            printBoard(board, M, N, outputFile, i);
        }
    }
    //Freeing the memory
    for (int i = 0; i < M; ++i) {
        free(board[i]);
    }
    free(board);
    //Closing the files
    fclose(outputFile);
    fclose(inputFile);

    return 0;

    return 0;
}