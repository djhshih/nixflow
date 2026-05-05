fun { dfn } =>
{
  name = "tr",
  inputs = {
    infile = "File",
    from_char = "string",
    to_char = "string",
    # outbase = "string",
  },
  outputs = {
    outfile = "{outbase}.txt",
  },
  command = m%"
    tr {from_char} {to_char} < {infile} > {outbase}.txt
  "%,
} | dfn.Task
