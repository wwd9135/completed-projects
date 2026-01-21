from src import Cli, Parser

# Initialize classes and run the main application
def main():
    cli = Cli()
    cli.Args()
    parser = Parser()
    ParsedData = parser.parse1()
    VerboseOutput: list[str]= (ParsedData[2])
    ShortOutput: list[str,str] =  [ParsedData[0], ParsedData[1]]
    print(ShortOutput)
main()