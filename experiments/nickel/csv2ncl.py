#!/usr/bin/env python

import argparse
import os

pr = argparse.ArgumentParser("Convert csv to nickel")
pr.add_argument("infile", help="input file")
pr.add_argument("-s", "--sep", default=",", help="separator")
pr.add_argument("-o", "--outfile", help="output file")

# process arguments

argv = pr.parse_args()
infile = argv.infile
sep = argv.sep
if argv.outfile:
  outfile = argv.outfile
else:
  infilestem, ext = os.path.splitext(infile);
  outfile = infilestem + ".ncl"

# read input file

with open(infile) as inf:
  header = inf.readline().rstrip()
  fields = header.split(sep)
  out = []
  for line in inf:
    rows = []
    values = line.rstrip().split(sep)
    for k, v in zip(fields, values):
        rows.append('{} = "{}"'.format(k, v))
    out.append('{\n\t\t' + ',\n\t\t'.join(rows) + '\n\t}'  )

# write output file

with open(outfile, 'w') as outf:
  outf.write('[\n\t' + ',\n\t'.join(out) + '\n]')

