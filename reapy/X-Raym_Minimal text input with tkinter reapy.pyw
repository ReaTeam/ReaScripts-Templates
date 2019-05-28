import reapy

from tkinter import *

# Quit the script
def quit():
  global root
  root.destroy()

def callback():
    text = E1.get()
    quit()
    reapy.show_message_box(text, title='test', mode='ok-cancel')

root = Tk() # Init TK
root.lift() # Stay on top

L1 = Label(root, text="Text")
L1.grid(row=0, column=0)
E1 = Entry(root, bd = 5)
E1.grid(row=0, column=1)

MyButton1 = Button(root, text="Submit", width=10, command=callback)
MyButton1.grid(row=1, column=1)

root.mainloop()
