if (args.Length == 0)
{
    Console.WriteLine("Please provide an input file");
    Console.WriteLine("\n\nPress any key to close the application");
    Console.ReadKey();

    return;
}

string fileData = new StreamReader(args[0]).ReadToEnd();
int index = 0;

byte[] memory = new byte[30000];
int memoryIndex = 0;

int openingBrackets = 0;
int closingBrackets = 0;

while (index < fileData.Length)
{
    switch (fileData[index])
    {
        case '+':
            memory[memoryIndex]++;
            break;

        case '-':
            memory[memoryIndex]--;
            break;

        case '>':
            memoryIndex = memoryIndex == 29999 ? 0 : memoryIndex + 1;
            break;

        case '<':
            memoryIndex = memoryIndex == 0 ? 29999 : memoryIndex - 1;
            break;

        case '.':
            Console.Write(((char) memory[memoryIndex]));
            break;

        case ',':
            memory[memoryIndex] = (byte) Console.ReadKey().KeyChar;
            break;

        case '[':
            if (memory[memoryIndex] == 0)
            {
                while (fileData[index] != ']' || openingBrackets > 0)
                {
                    index++;

                    if (fileData[index] == '[') openingBrackets++;
                    if (fileData[index] == ']') openingBrackets--;
                }
            }

            openingBrackets = 0;

            break;

        case ']':
            if (memory[memoryIndex] != 0)
            {
                while (fileData[index] != '[' || closingBrackets > 0)
                {
                    index--;

                    if (fileData[index] == ']') closingBrackets++;
                    if (fileData[index] == '[') closingBrackets--;
                }
            }

            closingBrackets = 0;

            break;

        default:
            break;
    }

    index++;
}

Console.WriteLine("\n\nPress any key to close the application");
Console.ReadKey();