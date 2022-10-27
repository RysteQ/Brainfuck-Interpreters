#include <stdio.h>
#include <stdlib.h>

#define instruction(programData, offset) *(programData + offset)

char *readFile(const char* inputFile);
void brainfuckInterpreter(char *programData);
char getChar();

int main(int argc, char **argv) {
    char *programData;

    if (argc != 2) {
        printf("No input file detected\n");
        return -1;
    }

    programData = readFile(argv[1]);

    if (*programData == '\0') {
        printf("Error reading file\n");
        return -1;
    } else {
        brainfuckInterpreter(programData);
    }

    return 0;
}

char *readFile(const char* inputFile) {
    FILE *filePointer = fopen(inputFile, "r");
    char *toReturn = malloc(1);
    int toReturnSize = 1;
    char toSave;

    if (filePointer == NULL) {
        *toReturn = '\0';
        return toReturn;
    }

    while ((toSave = fgetc(filePointer)) != EOF) {
        *(toReturn + toReturnSize - 1) = toSave;

        toReturn = realloc(toReturn, toReturnSize + 1);
        toReturnSize++;
    }

    *(toReturn + toReturnSize) = '\0';

    return toReturn;
}

void brainfuckInterpreter(char *programData) {
    char memory[30000] = { 0 };
    int memoryPointer = 0;
    int offset = 0;

    int openingBrackets = 0;
    int closingBrackets = 0;

    while (instruction(programData, offset) != '\0') {
        switch (instruction(programData, offset)) {
            case '+':
                memory[memoryPointer]++;
                break;

            case '-':
                memory[memoryPointer]--;
                break;

            case '>':
                memoryPointer++;
                
                if (memoryPointer == 30000) {
                    memoryPointer = 0;
                }

                break;

            case '<':
                memoryPointer--;

                if (memoryPointer < 0) {
                    memoryPointer = 29999;
                }

                break;

            case '.':
                printf("%c", memory[memoryPointer]);
                break;

            case ',':
                memory[memoryPointer] = getChar();
                break;

            case '[':
                if (memory[memoryPointer] == 0) {
                    while (instruction(programData, offset) != ']' || openingBrackets > 0) {
                        offset++;

                        if (instruction(programData, offset) == '[') {
                            openingBrackets++;
                        }

                        if (instruction(programData, offset) == ']') {
                            openingBrackets--;
                        }
                    }
                }

                break;

            case ']':
                if (memory[memoryPointer] != 0) {
                    while (instruction(programData, offset) != '[' || closingBrackets > 0) {
                        offset--;
                        
                        if (instruction(programData, offset) == ']') {
                            closingBrackets++;
                        }

                        if (instruction(programData, offset) == '[') {
                            closingBrackets--;
                        }
                    }
                }

                break;

            default:
                break;
        }
        
        offset++;
    }
}

char getChar() {
    char toReturn;

    scanf("%c", &toReturn);

    return toReturn;
}
