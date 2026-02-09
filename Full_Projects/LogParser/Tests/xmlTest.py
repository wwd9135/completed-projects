# This test will check different XML files to ensure the parser can handle various structures and edge cases.

def test_xml_parsing():
    from src import Parser

    parser = Parser.LogParser()

    # Test Case 1: Basic XML with one event
    result1 = parser.parser1("test_files/basic_event.xml")
    assert result1["summary"]["total"] == 1
    assert result1["data"][0]["event_id"] == 1000
    assert "successfully" in result1["data"][0]["message"].lower()

    # Test Case 2: XML with multiple events
    result2 = parser.parser1("test_files/multiple_events.xml")
    assert result2["summary"]["total"] == 3
    assert result2["summary"]["success"] == 2
    assert result2["summary"]["failed"] == 1

    # Test Case 3: XML with missing fields (e.g., no EventData)
    result3 = parser.parser1("test_files/missing_fields.xml")
    assert result3["summary"]["total"] == 1
    assert result3["data"][0]["message"] == "N/A"

    # Test Case 4: Malformed XML (should raise an error)
    try:
        parser.parser1("test_files/malformed.xml")
        assert False, "Expected ValueError for malformed XML"
    except ValueError:
        pass  # Expected exception