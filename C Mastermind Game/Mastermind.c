/*Jaiden Angeles
Doc: 
Asgn: Assignment 1 Problem 2 - MASTERMIND
Date: June 16, 2023 
*/

/*Importing the std io library, stdlib for general-purpose, & time.h for time and date.*/
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define NUMBEROF_DIGITS 6
#define MAX_TRIES 100                   //100 tries is a fair limit for someone to guess the matches/partial matches

//Gererates a random 6-digit number from 0-9
void generateSolution(int *solution){
    for(int i=0; i<NUMBEROF_DIGITS; i++){
        solution[i] = rand() % 10;      //Using rand for part of pseudo random number generator
    }
}

//Prints the array for the integers
void printArray(int *arr){
    for(int i=0; i<NUMBEROF_DIGITS; i++){
        printf("%d ", arr[i]);
    }
    printf("\n");
}

//Gets the guess from the user
int getGuess(int *guess){
    int i = 0;
    char ch;
    int invalid = 0;
    while (i<NUMBEROF_DIGITS && (ch = getchar()) != '\n' && ch != EOF) {
        if(ch >= '0' && ch <= '9') {
            guess[i++] = ch - '0';
        } else if (ch != ' ' && ch != '\t'){
            invalid = 1;
            break;
        }
    }

    // if the user entered more than 6 digits, ignore the rest
    if(i == NUMBEROF_DIGITS) {
        while((ch = getchar()) != '\n' && ch != EOF);
        return 0;
    }

    // if the user entered less than 6 digits, the guess is invalid
    if (invalid) {
        return 1;
    }

    // if the user entered less than 6 digits, ask for more digits since it was invalid
    while(i < NUMBEROF_DIGITS){
        printf("You need to enter %d more digits to complete your guess\n", NUMBEROF_DIGITS - i);
        while((ch = getchar()) != '\n' && ch != EOF) {
            if(ch >= '0' && ch <= '9'){
                guess[i++] = ch - '0';
            } else if (ch != ' ' && ch != '\t'){
                return 1;
            }
        }
    }
    return 0;
}
//Checks the guess and matches it with the solution & counts the number of matches and partial matches
int matchGuess(int *solution, int *guess){
    int matches = 0, partial = 0;
    int matchIndex[NUMBEROF_DIGITS] = {0};
    int partialMatchIndex[NUMBEROF_DIGITS] = {0};
    int usedIndex[NUMBEROF_DIGITS] = {0}; // additional array to keep track of used digits in guess

//This block is the one checking for matches
    for(int i=0; i<NUMBEROF_DIGITS; i++){
        if(solution[i] == guess[i]){
            matches++;
            matchIndex[i] = 1;
            usedIndex[i] = 1;
        }
    }
//This block is the one checking for partial matches
    for(int i=0; i<NUMBEROF_DIGITS; i++){
        if(matchIndex[i] == 0){
            for(int j=0; j<NUMBEROF_DIGITS; j++){
                if(partialMatchIndex[j] == 0 && usedIndex[j] == 0 && solution[j] == guess[i]){
                    partial++;
                    partialMatchIndex[j] = 1;
                    usedIndex[j] = 1;
                    break;
                }
            }
        }
    }

    printf("Your guess was\n");
    printArray(guess);
    printf("My response was\n%d matches %d partial matches\n", matches, partial);

    if(matches == NUMBEROF_DIGITS)
        return 1;

    return 0;
}
//The Main function to run
int main(){
    int *solution = (int*)malloc(NUMBEROF_DIGITS * sizeof(int));
    int *guess = (int*)malloc(NUMBEROF_DIGITS * sizeof(int));
//This block is for the seed
    long seed;
    printf("Enter the integer value of the seed for the game: ");
    while(scanf("%ld", &seed) != 1) {
        while(getchar() != '\n'); 
        printf("Try again you made an error\nEnter the integer value of the seed for the game: ");
    }
    srand(seed);    //Using srand for part of pseudo random number generator, which intializes it.

    printf("For each turn enter 6 digits 0 <= digit <= 9\nSpaces or tabs in your response will be ignored\n");

    generateSolution(solution); //Generates the solution (obviously)

    // User can guess below 100 times.
    for(int i=0; i<MAX_TRIES; i++){
        printf("\nEnter your guess, 6 digits\n");
        if(getGuess(guess) == 1){
            printf("ERROR: A character in your guess was not a digit or a white space\n");
            while(getchar() != '\n');
            continue;
        }
        //Checks the guess and matches it with the solution
        if(matchGuess(solution, guess) == 1){
            printf("YOU DID IT!!\n");
            free(solution);
            free(guess);
            return 0;
        }
        //Resets the guess
        for(int i = 0; i < NUMBEROF_DIGITS; i++) {
            guess[i] = 0;
        }
    }
    //If the user fails to guess the solution
    printf("Game over. The solution was: ");
    printArray(solution);

    //Frees the memory
    free(solution);
    free(guess);
    return 0;
}
