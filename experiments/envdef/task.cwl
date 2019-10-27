#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: bash
requirements:
    EnvVarRequirement:
        envDef:
            infile: $(inputs.infile.path)
            from_chars: $(inputs.from_chars)
            to_chars: $(inputs.to_chars)
            outfname: $(inputs.outfname)
#stdin: $(inputs.script.path)
inputs:
    script:
        type: File
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
