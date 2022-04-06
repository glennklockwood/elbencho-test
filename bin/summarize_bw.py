#!/usr/bin/env python

import re
import csv
import json
import argparse

JOBTYPE_LABELS = {
    re.compile("bw.\d+threads.\d+.csv"): "Buffered I/O",
    re.compile("bw-direct.\d+threads.\d+.csv"): "Direct I/O",
    re.compile("bw-direct.\d+threads.\d+.out"): "Direct I/O",
    re.compile("bw-direct-blockvarpct0.\d\dthreads.\d+.csv"): "Direct I/O, blockvarpct=0",
    re.compile("iops-direct.\d+threads.\d+.csv"): "Direct I/O",
    re.compile("iops-direct.\d+threads.\d+.out"): "Direct I/O",
}

class BenchmarkParser():
    def __init__(self, filename):
        self._file_handle = open(filename, "r")
        self._search_line = self._find_filetype
        self._csv_parser = None
        self.label = "unknown"

        for rex_match, label in JOBTYPE_LABELS.items():
            if rex_match.search(filename):
                self.label = label
                break

    def _find_filetype(self, line):
        if line.startswith("ISO date"):
            self._search_line = self._parse_elbencho
        elif line.startswith("IOR-"):
            self._search_line = self._parse_ior

    def _parse_elbencho(self, line):
        self._file_handle.seek(0)
        self._file_handle = csv.DictReader(self._file_handle)
        for line in self._file_handle:
            if line.get("operation") == "WRITE":
                return {
                    "label": self.label,
                    "ppn": int(line.get("threads")),
                    "bw(mib/s)": float(line.get("MiB/s [last]")),
                    "iops": int(line.get("IOPS [last]"))
                }

    def _parse_ior(self, line):
        line = line.lower().lstrip()
        if line.startswith('write') and 'posix' in line:
            args = line.strip().split()
            return {
                "label": self.label,
                "ppn": int(args[14]),
                "bw(mib/s)": float(args[1]),
                "iops": float(args[5]),
            }

    def get_result(self):
        for line in self._file_handle:
            # if we found an elbencho result, pass off to a csv parser
            if self._search_line == self._parse_elbencho:
                return self._search_line(self)
            # otherwise use the line-by-line parser
            result = self._search_line(line)
            if result is not None:
                return result

def parse_results(files, **kwargs):
    results = []
    for filename in files:
        parser = BenchmarkParser(filename)
        result = parser.get_result()
        if result is not None:
            if kwargs:
                result.update(kwargs)
            results.append(result)
    return results

def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("file", nargs="+", type=str, help="IOR stdout or Elbencho csv outputs")
    args = parser.parse_args()

    for result in parse_results(args.file):
        print(result)

if __name__ == "__main__":
    main()
