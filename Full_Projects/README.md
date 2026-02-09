# Overview 
This directory contains my security‑focused coding projects. Two projects are currently included.

## Unveil
A steganography application that encrypts plaintext using a custom encryption algorithm and embeds the result within an image’s pixels, delivered through a Tkinter GUI I built.
- The GUI accepts an image and a user‑provided string for encryption.
- The string is encrypted using a custom algorithm I developed to deepen my understanding of cryptography.
- All data exists only in session; no database is used to store tokens or payloads, though this could be added in a future version.
- Decryption also occurs in session, allowing the user to retrieve their data on request


## LogParser
A resilient Windows event log parser designed for reliability and flexibility.
- Handles XML event logs, automatically rewriting malformed XML so the parser can process all entries.
- Supports time‑range filtering, keyword matching, and event ID filtering to optimise analysis.
- Includes extensive testing to ensure edge cases are handled correctly, with safeguards for invalid filenames, file types, and corrupte
