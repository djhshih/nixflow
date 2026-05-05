#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: bash
inputs:
    script:
        type: File
        inputBinding:
            position: 0
    infile:
        type: File
        inputBinding:
            position: 1
    from_chars:
        type: string
        inputBinding:
            position: 2
    to_chars:
        type: string
        inputBinding:
            position: 3
    outfname:
        type: string
        inputBinding:
            position: 4
outputs:
    outfile:
        type: File
        outputBinding:
            glob: $(inputs.outfname)
