#!/usr/bin/env python

import re
import argparse

JOBTYPE_LABELS = {
    re.compile("bw.\d+threads.\d+.csv"): "Buffered I/O",
    re.compile("bw-direct.\d+threads.\d+.csv"): "Direct I/O",
    re.compile("bw-direct.\d+threads.\d+.out"): "Direct I/O",
    re.compile("bw-direct-blockvarpct0.\d\dthreads.\d+.csv"): "Direct I/O, blockvarpct=0",
}

class BenchmarkParser():
    def __init__(self, filename):
        self._filehandle = open(filename, "r")
        self._search_line = self._find_filetype
        self.label = "unknown"

        for rex_match, label in JOBTYPE_LABELS.items():
            if rex_match.search(filename):
                self.label = label
                break

    def _find_filetype(self, line):
        if line.startswith('ISO date'):
            self._search_line = self._parse_elbencho
        elif line.startswith("IOR-"):
            self._search_line = self._parse_ior

    def _parse_elbencho(self, line):
        if 'WRITE' in line:
            args = line.strip().split(',')
            return {"label": self.label, "ppn": int(args[5]), "bw(mib/s)": float(args[22])}

    def _parse_ior(self, line):
        line = line.lower().lstrip()
        if line.startswith('write') and 'posix' in line:
            args = line.strip().split()
            return {"label": self.label, "ppn": int(args[14]), "bw(mib/s)": float(args[1])}

    def get_result(self):
        for line in self._filehandle:
            result = self._search_line(line)
            if result is not None:
                return result

def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("file", nargs="+", type=str, help="IOR stdout or Elbencho csv outputs")
    args = parser.parse_args()

    for filename in args.file:
        parser = BenchmarkParser(filename)
        result = parser.get_result()
        if result is not None:
            print(result)

if __name__ == "__main__":
    main()
