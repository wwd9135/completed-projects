The following txt files serve a specific purpose:

Name- flag.txt
Purpose- to provide the input txt for my decryptor, of course you can upload any txt, doc, img you like.
Value- Well done you have captured the flag  successully well done

Name- dis.txt
Purpose- Take the caeser cipher binary output
Value- Dependant on-
# Writing the result to a file
if shifted_binary is not None:  # Ensure the shifted binary is valid
    shifted_binary_str = ''.join(str(binary) for binary in shifted_binary)  # Convert to string
    print(f"Writing the following data to the file: {shifted_binary_str}")  # Debugging step

    with open("dis.txt", "w") as file:  # Use "w" mode to overwrite the file
        file.write(f"The final outputted hash is:\n{shifted_binary_str}")

Name-output.txt
Purpose- Take the encryption header output, and letting it be used in the decryptor program.
Value- Dependant on-
# Write the encryption header to a file
        result = "\n".join(self.encryptionHeader)
