# Overview
This directory showcases my security‑focused coding projects. It currently includes two tools designed to deepen my understanding of cryptography, Windows internals, and resilient automation.

## Unveil
**Unveil** is a steganography application that encrypts plaintext using a custom algorithm and embeds the ciphertext within an image’s pixel data. The tool is delivered through a Tkinter GUI that I built from scratch.

### Key Features
- Accepts an image and a user‑provided plaintext string for encryption.
- Uses a custom encryption algorithm I developed to explore cryptographic concepts.
- Stores all data only in session — no tokens or payloads are written to disk.
- Supports in‑session decryption, allowing users to retrieve their embedded data on demand.

## LogParser
**LogParser** is a resilient Windows event log parser built for reliability, flexibility, and fault tolerance.

### Key Features
- Processes XML event logs and automatically repairs malformed XML so all entries can be parsed.
- Supports time‑range filtering, keyword matching, and event ID filtering to streamline analysis.
- Includes extensive testing to ensure robust handling of edge cases, including invalid filenames, unsupported file types, and corrupted log data.
