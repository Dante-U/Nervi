#!/usr/bin/env python3

import os
import operator

# Configuration
SRC_DIR = "src"  # Directory containing .scad files with modules/functions
TEST_DIR = "tests"  # Directory containing test .scad files

# Track both modules and functions
items = {}
for filename in os.listdir(SRC_DIR):
    if filename.endswith(".scad"):
        filepath = os.path.join(SRC_DIR, filename)
        with open(filepath, "r") as f:
            for linenum, line in enumerate(f.readlines()):
                if line.startswith(("module ", "function ")):
                    is_module = line.startswith("module ")
                    itemname = line[7 if is_module else 9:].strip().split("(")[0].strip()
                    if itemname.startswith("_"):
                        continue
                    item_type = "module" if is_module else "function"
                    if itemname in items:
                        print(f"WARNING!!! {item_type.capitalize()} {itemname} re-defined at {filename}:{linenum+1}")
                        print(f"           Previously defined at {items[itemname][0]}:{items[itemname][1]}")
                    else:
                        items[itemname] = (filename, linenum+1, item_type)

covered = {}
uncovered = items.copy()
for filename in os.listdir(TEST_DIR):
    if filename.startswith("test_") and filename.endswith(".scad"):
        filepath = os.path.join(TEST_DIR, filename)
        with open(filepath, "r") as f:
            for linenum, line in enumerate(f.readlines()):
                if line.startswith("module "):
                    testmodule = line[7:].strip().split("(")[0].strip()
                    if testmodule.startswith("test_"):
                        itemname = testmodule.split("_", 1)[1]
                        if itemname in uncovered:
                            src_filename = uncovered[itemname][0]
                            if filename != f"test_{src_filename}":
                                print(f"WARNING!!! {uncovered[itemname][2].capitalize()} {itemname} defined at {src_filename}:{uncovered[itemname][1]}")
                                print(f"           but tested at {filename}:{linenum+1}")
                            covered[itemname] = (filename, linenum+1, uncovered[itemname][2])
                            del uncovered[itemname]

uncovered_by_file = {}
for itemname in sorted(list(uncovered.keys())):
    filename = uncovered[itemname][0]
    if filename not in uncovered_by_file:
        uncovered_by_file[filename] = []
    uncovered_by_file[filename].append((itemname, uncovered[itemname][2]))

mostest = []
for filename in uncovered_by_file.keys():
    mostest.append((len(uncovered_by_file[filename]), filename))

print("NOT COVERED:")
for cnt, filename in sorted(mostest, key=operator.itemgetter(0)):
    fileitems = uncovered_by_file[filename]
    print(f"  {filename}: {cnt} uncovered items")
    for itemname, item_type in fileitems:
        print(f"    {item_type} {itemname}")

totitems = len(items.keys())
covitems = len(covered)

print(
    f"Total coverage: {covitems} of {totitems} items ({100.0 * covitems / totitems:.2f}%)"
)

# vim: expandtab tabstop=4 shiftwidth=4 softtabstop=4 nowrap