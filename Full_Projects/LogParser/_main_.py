import logging
import json
import os
import sys
from src import Cli, LogParser

# 1. Setup Logger immediately
logging.basicConfig(
    level=logging.DEBUG,
    filename='main.log',
    filemode='a',
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def check_environment():
    """Validates the execution environment and virtual machine state."""
    # Check if we are running in a virtual environment
    if not hasattr(sys, 'real_prefix') and not (sys.base_prefix != sys.prefix):
        logger.warning("Application is NOT running in a virtual environment (venv).")
    else:
        logger.debug("Venv validation successful.")

def main():
    check_environment()
    
    # 2. Retrieve Arguments
    try:
        arguments = Cli.get_arguments() 
        logger.info(f"Target file: {arguments}")
    except Exception as e:
        logger.error(f"Failed to retrieve CLI arguments: {e}")
        print("Error: Could not read command line arguments.")
        return

    # 3. File Path Validation (Normalization)
    if not os.path.exists(arguments):
        logger.error(f"File not found at location: {os.path.abspath(arguments)}")
        print(f"Error: The file '{arguments}' does not exist.")
        return

    # 4. Parsing Execution
    try:
        parser = LogParser()
        # Using the standardized method name 'parse' from our previous refactor
        parsed_data = parser.parser1(filename=arguments)
        
        # Display results
        print(json.dumps(parsed_data, indent=4))
        logger.info("Pipeline completed successfully.")
        
    except Exception as e:
        logger.error(f"Parsing pipeline failed: {e}", exc_info=True)
        print(f"An error occurred during parsing: {e}")

if __name__ == "__main__":
    main()