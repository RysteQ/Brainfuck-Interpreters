import sys

def initMemory():
    toReturn = []

    for i in range(30000):
        toReturn.append(0)

    return toReturn

if len(sys.argv) == 1:
    sys.exit("Please provide a input file")

inputFile = open(sys.argv[1], "r")

program = inputFile.read()
programIndex = 0

memory = initMemory()
memoryIndex = 0

openingBrackets = 0
closingBrackets = 0

while programIndex < len(program):
    match program[programIndex]:
        case '+':
            if memory[memoryIndex] != 255:
                memory[memoryIndex] += 1
            else:
                memory[memoryIndex] = 0
            
        case '-':
            if memory[memoryIndex] != 0:
                memory[memoryIndex] -= 1
            else:
                memory[memoryIndex] = 255
            
        case '>':
            if memoryIndex != len(memory) - 1:
                memoryIndex += 1
            else:
                memoryIndex = 0
            
        case '<':
            if memoryIndex != 0:
                memoryIndex -= 1
            else:
                memoryIndex = len(memory) - 1
            
        case '.':
            print(chr(memory[memoryIndex]), end = "")
            
        case ',':
            memory[memoryIndex] = input()[0]
            
        case '[':
            if memory[memoryIndex] == 0:
                while program[programIndex] != ']' or closingBrackets > 0:
                    if program[programIndex] == '[':
                        closingBrackets -= 1
                    elif program[programIndex] == ']':
                        closingBrackets += 1

                    programIndex += 1

                closingBrackets = 0
                
        case ']':
            if memory[memoryIndex] != 0:
                while program[programIndex] != '[' or openingBrackets > 0:
                    if program[programIndex] == ']':
                        openingBrackets -= 1
                    elif program[programIndex] == '[':
                        openingBrackets += 1
                        
                    programIndex -= 1

                openingBrackets = 0
            
    programIndex += 1
