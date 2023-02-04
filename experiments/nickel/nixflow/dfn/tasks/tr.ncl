fun { dfn } =>
{
  name = "caesar",
  inputs = {
    infile = "File",
    from_char = "string",
    to_char = "string",
    outbase = "string",
  },
  outputs = {
    outfile = ["File", "{outbase}.txt"],
  },
  command = m%"
    cat {infile} |
    tr {from_char} {to_char} > {outbase}.txt
  "%,
} | dfn.Task
