# Engineering-Projects

This repository showcases my high-level, production-ready tools and enterprise-grade frameworks. These projects represent a transition from procedural scripting to modular, security-focused software development.

## Featured Projects

### 1. Unveil: Cryptographic Steganography Tool
**Language:** Python | **Framework:** Tkinter / PyCryptodome


**Project Overview:**
Unveil is a desktop GUI application designed to demonstrate secure data concealment within digital imagery. Unlike standard steganography, Unveil integrates a dual-layer security approach:
1. **Encryption Layer:** Messages are encrypted using AES-256 before being embedded, ensuring that even if the steganographic layer is detected, the data remains unreadable.
2. **Steganographic Layer:** Utilizes Least Significant Bit (LSB) encoding to inject the ciphertext into image pixel data with zero perceptible change to the carrier file.

**Key Technical Challenges Overcome:**
* **Bit Manipulation:** Developing logic to modify pixel color channels without corrupting the image file structure.
* **GUI Integration:** Bridging the gap between Python’s cryptographic back-end and a user-friendly front-end.
* **Format Handling:** Managing the differences in header metadata across various image formats (PNG/BMP).

**Future Roadmap:**
* Implementation of session-based key management.
* Support for higher-capacity embedding algorithms (e.g., DCT/Frequency domain).

---

### 2. MBAM Replacement Solution (Pending Refactor)
**Language:** PowerShell | **Framework:** PSADT / Intune
* A modern framework for BitLocker PIN management designed for the 2026 MBAM deprecation.
* *Note: Currently undergoing final code hardening for production-standard documentation.*

---

## Active Curation Standards
I am currently refactoring this directory. Projects are moved here from my mini_projects repository only once they meet the following benchmarks:
* **Code Hardening:** Implementation of robust error handling and input sanitization.
* **Security Review:** Verification of cryptographic standards and secure execution logic.
* **Technical Documentation:** Comprehensive READMEs including architecture breakdowns and deployment guides.

## Engineering Principles
1. **Security-First:** Cryptographic integrity and data protection are baked into the design phase.
2. **Modular Design:** Using modules (`.psm1`, `.py`) to ensure code is reusable and testable.
3. **Enterprise Readiness:** Built for deployment via modern MDM tools like Microsoft Intune.

---
*For smaller logic exercises and syntax practice, please refer to my [Learning-Exercises] repository.*
