import logging
import os
import json
from argparse import ArgumentParser, Namespace

logger = logging.getLogger(__name__)

class Cli:
    @staticmethod
    def get_arguments() -> str:
        """Parses CLI input and validates file existence."""
        parser = ArgumentParser(
            description="Windows Event Log XML Parser",
            usage="python main.py [FileName]"
        )
        parser.add_argument("FileName", help="Path to the XML log file", type=str)
        
        args: Namespace = parser.parse_args()
        target_file = args.FileName

        # Robustness check: Don't just open the file, check if it exists and is a file
        if not os.path.isfile(target_file):
            logger.error(f"File not found or inaccessible: {target_file}")
            print(f"Error: '{target_file}' is not a valid file path.")
            raise FileNotFoundError(f"Cannot locate: {target_file}")

        logger.info(f"Target file validated: {target_file}")
        return target_file

    @staticmethod
    def display_results(data: dict):
        """
        Handles the 'Presentation Layer'. 
        Decouples the printing logic from the parsing logic.
        """
        if not data:
            logger.warning("Display called with empty data.")
            print("No data to display.")
            return

        try:
            # Polishing the output
            print("\n" + "="*30)
            print("   LOG PARSING COMPLETE")
            print("="*30)
            
            # Print Summary
            summary = data.get("summary", {})
            print(f"Total Events: {summary.get('total', 0)}")
            print(f"Successes:    {summary.get('success', 0)}")
            print(f"Failures:     {summary.get('failed', 0)}")
            print("-" * 30)

            # Optional: Ask user if they want to see raw JSON
            show_raw = input("Display raw event data? (y/n): ").lower()
            if show_raw == 'y':
                print(json.dumps(data.get("data", []), indent=4))

        except Exception as e:
            logger.error(f"Output presentation failed: {e}")
            raise ValueError("Error formatting output display.")