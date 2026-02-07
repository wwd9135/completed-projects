# Unveil: Cryptographic Steganography Utility

Unveil is a Python-based security tool designed to demonstrate the dual-layer protection of sensitive data through a home-made encryption algoritim (Losely based on AES) and **Least Significant Bit (LSB) Steganography**. 

By embedding encrypted ciphertext into the pixel data of standard image files, Unveil ensures that data is not only unreadable but also invisible to the naked eye.

# Developer’s Note
I recently reviewed this code a year after its inception. To be blunt: the ideas are great, but the implementation is "legacy."

This was built in 48 hours with a focus on functionality over form. Consequently, it ignores many OOP best practices (Single Responsibility, modularity, etc.). However, I’ve kept it public because the innovation behind the solution is something I'm still proud of and it has a special place in my heart- I was very passionate about learning encryption & stegonography, getting to build my own algorithim and stegonography functionality from scratch, as well as a GUI to house it was an amazing experience . It stands as a testament to my growth— I now build with proper project structures and strict class hierarchies from day one.


## Technical Workflow

The tool follows a multi-stage pipeline to ensure data integrity and stealth:

1.  **Encryption Phase:** The plaintext message is padded and encrypted using my Encryptor.py module. This ensures that even if a third party detects the hidden data, they cannot access the content without the specific cryptographic key, providing CIA.
2.  **Binary Conversion:** The resulting ciphertext is converted into a bitstream.
3.  **LSB Embedding:** The script iterates through the RGB channels of the carrier image. It replaces the least significant bit of each byte with a bit from the ciphertext. This method results in a color shift so minute (1/255th of a color's intensity) that it is mathematically imperceptible to human vision.
4.  **Reconstruction:** A new carrier image is generated (PNG/BMP) that contains the hidden payload.
5. **Decryption:** Calls Decryption module- data is decrypted- currently this project is setup so data is stored in session, didnt build a database to store records to as this isn't being deployed in production at all. 


## Key Features

* **GUI Interface:** A clean, functional desktop environment built with **Tkinter** for easy file selection and message input.
* **Lossless Preservation:** Defaults to PNG/BMP formats to prevent the compression artifacts found in JPEGs, which would otherwise corrupt the hidden bitstream.
* **Dual-Layer Security:** Combines standard cryptography with steganographic "security through obscurity."

## Challenges & Research Points

During development, several key engineering hurdles were addressed:

* **Bit-Depth Sensitivity:** Managing how different image bit-depths affect the available storage capacity for the hidden message.
* **Header Integrity:** Ensuring that the LSB modification does not interfere with the image file's metadata or header, which would render the file "corrupt" to standard image viewers.
* **Payload Capacity:** Calculating the maximum message length based on the image resolution:  
    `Max Capacity (bits) = (Width * Height * 3 Channels)`
* **Decryption:** Perhaps this biggest of all: this was heinous to say the least, I had built the GUI/stegonography, encryption up, and tried to build the decryptor at the end, reverse engineering my encryption algorithim was painful and took many iterations overall.

## Roadmap & Future Enhancements

* **ECC Implementation:** Integrating Error Correcting Codes to make the hidden message more resilient to minor image edits.
* **Key Exchange:** Moving from simple passphrases to a more robust session-based key management system.
* **Advanced Algorithms:** Exploring Discrete Cosine Transform (DCT) steganography for embedding data within compressed JPEG files.

## Navigation:
This project is split down into a main file & an encryptor/decryptor which is used to encrypt the data before the stegonography occurs then decrypt once the user inputs their details/token given during stegonography in the GUI.
### [Main] (./_main_.py): This file hosts the GUI- it calls on the other two files.
- [Encryptor] (./Encryptor.py): Hosts the encryption, essentially a module, class can be called from main and individual functions used from there.
- [Decryptor] (./Decryptor.py): Hosts the decryption, takes a token/ credentials and allows the decryption of the users data they initially inputted.

## Technical explanation
* **Gui app:**
This file handles the core steganography logic, using Least Significant Bit (LSB) substitution to hide encrypted data within image pixels.

* **Data Engineering & Pipeline**
- Binary Encoding: Converts source text into a continuous 8-bit binary stream, calculating "triplet fits" to map data against RGB channels.

- The Buffer Strategy: Uniquely utilizes a pandas.DataFrame as a structured buffer to manage pixel states. While computationally expensive compared to bytearrays, it allowed for precise tracking of bit-substitution during the prototyping phase.

- Cryptographic Layer: Implements a binary-level Caesar Cipher that shifts integer values before LSB injection, ensuring the hidden data isn't stored as plain-text ASCII.

* **Steganographic Method**
The changer() method performs the injection by stripping the last bit of a pixel's color channel and replacing it with a data bit. The modified pixels are then re-serialized into a lossless PNG via the Pillow library to prevent compression artifacts from corrupting the payload.

* **Architectural Retrospective**
- Patterns: The current version utilizes "God Classes" where I/O, state management, and processing are tightly coupled.

- Refactor Goal: Future iterations will move away from pandas in favor of direct NumPy array manipulation to improve memory efficiency and processing speed.
