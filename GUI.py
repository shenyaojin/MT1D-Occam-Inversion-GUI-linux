import inversion_core
from tkinter import *
import tkinter.filedialog
import os


def get_data():
    a = tkinter.filedialog.askopenfilename()
    f = open("temp", 'w')
    print(a)
    f.write(a)
    f.close()


def inversion():
    nlayer = int(e1.get())
    maxit = int(e2.get())
    tol = float(e3.get())
    mode = int(e4.get())
    noise = int(e5.get())
    f = open("temp", 'r')
    filename = f.readline()
    folder_name = filename.strip(".edi")
    f.close()
    # remove temp file
    os.system("rm temp")
    inversion_core.mt1dinv(filename, nlayer, maxit, tol, mode, noise)
    notice = "Notice: the results have been saved to " + folder_name
    tkinter.messagebox.showinfo("it works!", notice)


# GUI module
top = Tk()

window_x = top.winfo_screenwidth()
window_y = top.winfo_screenheight()
WIDTH = 500
HEIGHT = 350
x = (window_x - WIDTH) / 2
y = (window_y - HEIGHT) / 2

top.geometry(f'{WIDTH}x{HEIGHT}+{int(x)}+{int(y)}')
top.resizable(width=False, height=False)

top.title("MT1DOCC")
tkinter.messagebox.showinfo("Notice", "This version is base on shell, theoretically it could work on cygwin.")
Label(top, text="MT1DOCC in Python", font=("Source Sans Pro", 16)).grid(row=1, column=1)
Label(top, text="Shenyao Jin", font=("Source Sans Pro", 16)).grid(row=2, column=1)
Label(top, text="Zhejiang Univ.", font=("Source Sans Pro", 16)).grid(row=3, column=1)

Label(top, text="nlayer：", font=("Source Sans Pro", 13)).grid(row=4)
Label(top, text="max iteration：", font=("Source Sans Pro", 13)).grid(row=5)
Label(top, text="tol：", font=("Source Sans Pro", 13)).grid(row=6)
Label(top, text="mode：", font=("Source Sans Pro", 13)).grid(row=7)
Label(top, text="noise：", font=("Source Sans Pro", 13)).grid(row=8)

e1 = Entry(top)
e2 = Entry(top)
e3 = Entry(top)
e4 = Entry(top)
e5 = Entry(top)

e1.grid(row=4, column=1, padx=10, pady=5)
e2.grid(row=5, column=1, padx=10, pady=5)
e3.grid(row=6, column=1, padx=10, pady=5)
e4.grid(row=7, column=1, padx=10, pady=5)
e5.grid(row=8, column=1, padx=10, pady=5)

button = Button(top, width=20, height=2, text='Choose file', command=get_data)
button.grid(row=9)

button1 = Button(top, width=20, height=2, text='Calculate', command=inversion)
button1.grid(row=9, column=2)

top.mainloop()
