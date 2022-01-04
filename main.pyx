#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import csv
import re
import os
import tkinter

from zipfile import ZipFile
from collections import namedtuple, defaultdict
from tkinter import Tk, ttk, filedialog

from typing import List, Dict


INP_PAT = re.compile("^[df][t\\\.b]")
INPX_FIELD_DELIMITER = chr(4)
COLS_LEN = 15
Error = namedtuple("Error", "inpx_file inp_file row_num row")


class MyApp:
    def __init__(self, parent: Tk):
        self.parent = parent
        mainframe = ttk.Frame(parent, padding="3 3 12 12")
        mainframe.grid(column=0, row=0, sticky=(tkinter.N, tkinter.W, tkinter.E, tkinter.S))

        ttk.Button(mainframe, text="Open", command=self.open_file).grid(column=0, row=0, sticky=tkinter.W)
        self.status = ttk.Label(mainframe, text="Откройте файл")
        self.status.grid(column=0, row=1, sticky=(tkinter.W, tkinter.E))

        treeview_frame = ttk.Frame(mainframe, padding="3 3 5 5")
        treeview_frame.grid(column=0, row=2, sticky=(tkinter.N, tkinter.W, tkinter.E, tkinter.S))
        self.treeview = ttk.Treeview(treeview_frame)
        self.treeview.grid(column=0, row=0, sticky=(tkinter.N, tkinter.W, tkinter.E, tkinter.S))
        ysb = ttk.Scrollbar(treeview_frame, orient=tkinter.VERTICAL, command=self.treeview.yview)
        ysb.grid(column=1, row=0, sticky=(tkinter.N, tkinter.S))
        self.treeview.configure(yscrollcommand=ysb.set)

        for child in mainframe.winfo_children():
            child.grid_configure(padx=5, pady=5)

        mainframe.rowconfigure(2, weight=1)
        mainframe.columnconfigure(0, weight=1)
        treeview_frame.rowconfigure(0, weight=1)
        treeview_frame.columnconfigure(0, weight=1)

    def open_file(self):
        filename = filedialog.askopenfilename(filetypes=(("inpx files", "*.inpx"),))
        if filename:
            errors = parse_inpx(filename, self.progress_cb)
            self.status.configure(text=f'Просканировано: {os.path.realpath(filename)}')
            for filename, err in errors.items():
                self.treeview.insert('', 'end', filename, text=filename)
                for e in err:
                    self.treeview.insert(filename, 'end', e.row, text=f'{e.row_num}: {" ".join(e.row)}')

    def progress_cb(self, level: int):
        self.status.configure(text=f'Сканируем: {level}%')
        self.parent.update()


def parse_inpx(filename: str, progress_cb: MyApp.progress_cb = None,
               result: Dict[str, List[Error]] = None) -> Dict[str, Error]:
    errors = defaultdict(list)  # type: Dict[str, Error]
    with ZipFile(filename, 'r') as inpx:
        flst = [f for f in inpx.filelist if INP_PAT.match(f.filename)]
        for fnum, file in enumerate(flst):
            if progress_cb:
                precent = int(fnum * 100 / len(flst))
                progress_cb(precent)
            inp_file_data = inpx.read(file.filename).decode('UTF-8').splitlines()
            csv_reader = csv.reader(inp_file_data, delimiter=INPX_FIELD_DELIMITER)
            for row in csv_reader:
                if len(row) != COLS_LEN:
                    inpx_name = os.path.realpath(filename)
                    errors[file.filename].append(Error(inpx_name, file.filename, csv_reader.line_num, row))
    if result:
        result.update(errors)
    return errors


def _run_form():
    root = Tk()
    root.title("Проверка inpx файла")
    root.geometry("1024x768")
    root.columnconfigure(0, weight=1)
    root.rowconfigure(0, weight=1)
    MyApp(root)
    root.mainloop()


if __name__ == '__main__':
    _run_form()
