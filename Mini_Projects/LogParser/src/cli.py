from argparse import ArgumentParser, Namespace

class Cli:
    def __init__(self):
        pass

    def Args(self):
        parser = ArgumentParser(description="CLI for the application")
        parser.add_argument('Verbose', type=str, help='Enter a f ')
        # Find which file format our event logs will take.