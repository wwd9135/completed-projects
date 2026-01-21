# CLI Log Parsing Tool

## Overview
A lightweight command-line tool for parsing **Windows Event Logs (XML format)** and producing structured, readable output.

The parser extracts operationally useful fields from each event, including:

- **Event ID**
- **Timestamp**
- **Status / severity** (e.g. Error, Success)

Output verbosity is configurable via CLI flags, allowing either concise summaries or more detailed inspection depending on use case.

This project is intentionally modest in scope but deliberately engineered with long-term software quality in mind.

---
## Usage
From inside the LogParser folder, run:

python __main__.py -v 0

Arguments

-v, --verbosity
Controls output detail level:

-v0 → minimal output

-v1 → more verbose output
Planned Improvements

As learning progresses, this project will be extended with:
- Structured logging using Python’s logging module
- External configuration files instead of hardcoded values
- Unit tests using pytest
- Improved error handling and validation

## Motivation & Learning Goals
This project exists to reinforce fundamentals that actually matter in real engineering work, rather than chasing surface-level features.

Key areas of focus:

- **Object-oriented design**  
  Logic is split into clear components; the entry point only coordinates execution.

- **Project structure & modularity**  
  Code is organised so functionality can be extended without rewriting existing logic.

- **Type hints**  
  Used consistently to improve readability, correctness, and future maintainability.

- **CLI tooling**  
  Implemented using `argparse`, following common patterns used in production tools.

- **Clean, readable code**  
  Emphasis on clarity over cleverness.

This project is part of a broader effort to build strong foundations in Python before moving into more complex tooling and data structures.

---

## Design Philosophy
- Keep the entry point thin — no business logic in `__main__.py`
- Separate parsing, processing, and output concerns
- Build tools that could realistically exist in an internal engineering environment

