import xml.etree.ElementTree as ET

class Parser:
    def __init__(self):
        self.logName: str = "Pslog.xml"

    def parse1(self):
        # Load and parse the XML log file
        tree = ET.parse("src\MyTestLog.xml")
        root = tree.getroot()
        ns = {"ev": "http://schemas.microsoft.com/win/2004/08/events/event"}

        # Initialize counters and storage
        VerboseDictionary: list[str,str,str] = []
        SuccessC: int = 0
        ErrorC: int = 0

        # Iterate through each event in the log
        for event in root.findall(".//ev:Event", ns):
            system = event.find("ev:System", ns)
            eventdata = event.find("ev:EventData", ns)

            # Extract system fields
            event_id = system.find("ev:EventID", ns).text
            timestamp = system.find("ev:TimeCreated", ns).attrib.get("SystemTime")

            # Extract message (first <Data> element)
            data_elem = eventdata.find("ev:Data", ns)
            message = data_elem.text if data_elem is not None else None
            # Store the extracted information
            VerboseDictionary.append( f"Event ID:{event_id} Time:{timestamp} Message: {message}")

        # Count successes and errors based on message content
        for i in VerboseDictionary:
            if "successfully" in i:
                SuccessC +=1
            else:
                ErrorC +=1
        # Success/ error counts returned for non verbose option
        # FuLL Log returned for verbose option
        return SuccessC, ErrorC, VerboseDictionary
