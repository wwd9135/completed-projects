from tkinter import *

root = Tk()
root.title("Simple calculator")

e = Entry(root, width=35, borderwidth=5)
e.grid(row=0, column=0, columnspan=3, padx=10, pady=10)

# Global variables to store the current value and the operator
current_value = ""
previous_value = ""
operator = ""


def addition(a, b):
    result = float(a) + float(b)
    return result

def multi(a, b):
    result = float(a) * float(b)
    return result

def divide(a, b):
    if b == "0":  # Prevent division by zero
        return "Error"
    result = float(a) / float(b)
    return result

def subtract(a, b):
    result = float(a) - float(b)
    return result


def button_click(a, b=None, c=None):
    global current_value, previous_value, operator

    if c == "clear":  # Clear the entry and reset values
        current_value = ""
        previous_value = ""
        operator = ""
        e.delete(0, END)
    elif c == "equals":  # Perform the calculation
        if operator == "+":
            result = addition(previous_value, current_value)
        elif operator == "-":
            result = subtract(previous_value, current_value)
        elif operator == "*":
            result = multi(previous_value, current_value)
        elif operator == "/":
            result = divide(previous_value, current_value)
        else:
            result = "Error"
        
        e.delete(0, END)
        e.insert(0, result)
        current_value = str(result)  # Store the result for further operations
        previous_value = ""
        operator = ""
    elif c in ["+", "-", "*", "/"]:  # Store operator and current value
        operator = c
        previous_value = current_value
        current_value = ""
        e.delete(0, END)
    else:  # Regular number or symbol insertion
        current_value += str(a)
        e.delete(0, END)
        e.insert(0, current_value)

# Define buttons
one = Button(root, text="1", padx=40, pady=20, command=lambda: button_click(1))
two = Button(root, text="2", padx=40, pady=20, command=lambda: button_click(2))
three = Button(root, text="3", padx=40, pady=20, command=lambda: button_click(3))
four = Button(root, text="4", padx=40, pady=20, command=lambda: button_click(4))
five = Button(root, text="5", padx=40, pady=20, command=lambda: button_click(5))
six = Button(root, text="6", padx=40, pady=20, command=lambda: button_click(6))
seven = Button(root, text="7", padx=40, pady=20, command=lambda: button_click(7))
eight = Button(root, text="8", padx=40, pady=20, command=lambda: button_click(8))
nine = Button(root, text="9", padx=40, pady=20, command=lambda: button_click(9))
zero = Button(root, text="0", padx=40, pady=20, command=lambda: button_click(0))

multy = Button(root, text="*", padx=40, pady=20, command=lambda: button_click(None, None, "*"))
divi = Button(root, text="/", padx=40, pady=20, command=lambda: button_click(None, None, "/"))
sub = Button(root, text="-", padx=40, pady=20, command=lambda: button_click(None, None, "-"))
plus = Button(root, text="+", padx=40, pady=20, command=lambda: button_click(None, None, "+"))
equals = Button(root, text="=", padx=91, pady=20, command=lambda: button_click(None, None, "equals"))
clear = Button(root, text="Clear", padx=79, pady=20, command=lambda: button_click(None, None, "clear"))

# Display buttons in the grid
one.grid(column=0, row=4)
two.grid(column=1, row=4)
three.grid(column=2, row=4)
four.grid(column=0, row=3)
five.grid(column=1, row=3)
six.grid(column=2, row=3)
seven.grid(column=0, row=2)
eight.grid(column=1, row=2)
nine.grid(column=2, row=2)
zero.grid(column=0, row=5)

multy.grid(column=3, row=1)
divi.grid(column=3, row=2)
sub.grid(column=3, row=3)
plus.grid(column=0, row=6)
equals.grid(columnspan=2, column=1, row=6)

clear.grid(columnspan=2, column=1, row=5)

root.mainloop()
