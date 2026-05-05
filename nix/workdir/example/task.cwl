#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["bash", "script.sh"]
requirements:
    InitialWorkDirRequirement:
        listing:
            - entryname: script.sh
              entry: |-
                cat $(inputs.infile.path) |
                tr $(inputs.from_chars) $(inputs.to_chars) > $(inputs.outfname)

inputs:
    infile:
        type: File
    from_chars:
        type: string
    to_chars:
        type: string
    outfname:
        type: string
outputs:
    outfile:
        type: File
        outputBinding:
            glob: $(inputs.outfname)
