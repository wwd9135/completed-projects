from src import Cli, Parser

# Initialize classes and run the main application
def main():
    cli = Cli()
    Arguments = cli.args()
    parser = Parser()
    ParsedData = parser.parse1()
    VerboseOutput: list[str]= (ParsedData[2])
    
    ShortOutput: list[str,str] =  [ParsedData[0], ParsedData[1]]
    if Arguments == 0:
        cli.Verbose(VerboseOutput,ShortOutput)
        
    elif Arguments == 1:
        cli.NonVerbose(ShortOutput)

main()
