fun { dfn } =>
{
  name = "caesar",
  inputs = {
    infile = "File",
    outbase = "string",
  },
  outputs = {
    outfile = ["File", "{outbase}.txt"],
  },
  command = m%"
    cat {infile} |
    tr A-Za-z N-ZA-Mn-za-m > {outbase}.txt
  "%,
} | dfn.Task
