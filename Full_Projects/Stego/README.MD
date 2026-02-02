# Unveil: Cryptographic Steganography Utility

Unveil is a Python-based security tool designed to demonstrate the dual-layer protection of sensitive data through **AES-256 Encryption** and **Least Significant Bit (LSB) Steganography**. 

By embedding encrypted ciphertext into the pixel data of standard image files, Unveil ensures that data is not only unreadable but also invisible to the naked eye.



## Technical Workflow

The tool follows a multi-stage pipeline to ensure data integrity and stealth:

1.  **Encryption Phase:** The plaintext message is padded and encrypted using the **PyCryptodome** library. This ensures that even if a third party detects the hidden data, they cannot access the content without the specific cryptographic key.
2.  **Binary Conversion:** The resulting ciphertext is converted into a bitstream.
3.  **LSB Embedding:** The script iterates through the RGB channels of the carrier image. It replaces the least significant bit of each byte with a bit from the ciphertext. This method results in a color shift so minute (1/255th of a color's intensity) that it is mathematically imperceptible to human vision.
4.  **Reconstruction:** A new carrier image is generated (PNG/BMP) that contains the hidden payload.



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

## Roadmap & Future Enhancements

* **ECC Implementation:** Integrating Error Correcting Codes to make the hidden message more resilient to minor image edits.
* **Key Exchange:** Moving from simple passphrases to a more robust session-based key management system.
* **Advanced Algorithms:** Exploring Discrete Cosine Transform (DCT) steganography for embedding data within compressed JPEG files.

## Usage Note
This tool is a Proof of Concept (PoC) intended for educational purposes and security research.
