#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
inputs:
  infile:
    type: File
  from_chars:
    type: string
  to_chars:
    type: string
  toupper_outfname:
    type: string
  caesar_outfname:
    type: string
  caesar_caesar_outfname:
    type: string
outputs:
  encrypted:
    type: File
    outputSource: caesar/outfile
  decrypted:
    type: File
    outputSource: caesar2/outfile
steps:
  toupper:
    run: toupper.cwl
    in:
      infile: infile
      from_chars: from_chars
      to_chars: to_chars
      outfname: toupper_outfname
    out: [outfile]
  caesar:
    run: caesar.cwl
    in:
      infile: toupper/outfile
      outfname: caesar_outfname
    out: [outfile]
  caesar2:
    run: caesar.cwl
    in:
      infile: caesar/outfile
      outfname: caesar_caesar_outfname
    out: [outfile]

