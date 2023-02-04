fun { lib } =>
{
  name = "caesar",
  inputs = {
    infile = "File",
    outfname = "string",
  },
  outputs = {
    outfile = ["File", "{outfname}"],
  },
  command = m%"
    cat {infile} |
    tr A-Za-z N-ZA-Mn-za-m > {outfname}  
  "%,
}
