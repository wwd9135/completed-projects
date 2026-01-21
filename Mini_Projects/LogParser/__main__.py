from src import Cli, Parser

# Initialize classes and run the main application
def main():
    # Create CLI instance and parse arguments
    cli = Cli()
    Arguments = cli.args()

    parser = Parser()
    ParsedData = parser.parse1()

    # Prepare data for output based on verbosity level given by usern in CLI args
    VerboseOutput: list[str]= (ParsedData[2])
    ShortOutput: list[str,str] =  [ParsedData[0], ParsedData[1]]
    if Arguments == 0:
        cli.Verbose(VerboseOutput,ShortOutput)
        
    elif Arguments == 1:
        cli.NonVerbose(ShortOutput)

main()