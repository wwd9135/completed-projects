import xml.etree.ElementTree as ET

class Parser:
    def __init__(self):
        self.logName: str = "Pslog.xml"

    def parse1(self):
        tree = ET.parse("src\MyTestLog.xml")
        root = tree.getroot()

        ns = {"ev": "http://schemas.microsoft.com/win/2004/08/events/event"}
        VerboseDictionary: list[str,str,str] = []
        SuccessC: int = 0
        ErrorC: int = 0
        for event in root.findall(".//ev:Event", ns):

            system = event.find("ev:System", ns)
            eventdata = event.find("ev:EventData", ns)

            # Extract system fields
            event_id = system.find("ev:EventID", ns).text
            timestamp = system.find("ev:TimeCreated", ns).attrib.get("SystemTime")

            # Extract message (first <Data> element)
            data_elem = eventdata.find("ev:Data", ns)
            message = data_elem.text if data_elem is not None else None

            VerboseDictionary.append( f"Event ID:{event_id} Time:{timestamp} Message: {message}")
            
        for i in VerboseDictionary:
            if "successfully" in i:
                SuccessC +=1
            else:
                ErrorC +=1
        # Success/ error counts returned for non verbose option
        # Full logs returned for the verbose option.
        return SuccessC, ErrorC, VerboseDictionary
