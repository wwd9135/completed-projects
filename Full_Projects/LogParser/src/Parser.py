import xml.etree.ElementTree as ET
from dataclasses import dataclass, asdict
import logging

# Standard logging setup
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger()

@dataclass(frozen=True)
class EventRecord:
    """The 'Source of Truth' for a single log entry."""
    event_id: int
    timestamp: str
    message: str

class LogParser:
    def __init__(self):
        # XML Namespaces: vital for Windows Event XMLs
        self.ns = {"ev": "http://schemas.microsoft.com/win/2004/08/events/event"}
        self.events = []
        self.success_count = 0
        self.error_count = 0

    def parser1(self, filename: str):
        """Parses XML and returns a normalized dictionary summary."""
        try:
            tree = ET.parse(filename)
            root = tree.getroot()
        except ET.ParseError as e:
            logger.error(f"XML Parse Error: {e}")
            raise ValueError(f"File {filename} is not a valid XML.")

        # Iterate through events and normalize
        for event in root.findall(".//ev:Event", self.ns):
            # Extract
            system = event.find("ev:System", self.ns)
            event_id = int(system.find("ev:EventID", self.ns).text)
            timestamp = system.find("ev:TimeCreated", self.ns).attrib.get("SystemTime")
            
            data_elem = event.find(".//ev:EventData/ev:Data", self.ns)
            message = data_elem.text if data_elem is not None else "N/A"

            # Normalize into Dataclass
            record = EventRecord(event_id=event_id, timestamp=timestamp, message=message)
            
            # Logic: Convert dataclass to dict and store
            self.events.append(asdict(record))

            # Update Metrics
            if "successfully" in message.lower():
                self.success_count += 1
            else:
                self.error_count += 1

        return self._generate_report()

    def _generate_report(self):
        """Builds the final clean output dictionary."""
        return {
            "summary": {
                "total": len(self.events),
                "success": self.success_count,
                "failed": self.error_count
            },
            "data": self.events  # Clean list of dictionaries
        }

