fun lib =>

lib.make_task {
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
  tr A-Z N-ZA-M > {outfname}  
  "%,
}
