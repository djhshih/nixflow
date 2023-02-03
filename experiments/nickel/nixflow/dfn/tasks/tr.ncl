fun { lib } =>

lib.make_task {
  name = "caesar",
  inputs = {
    infile = "File",
    from_char = "string",
    to_char = "string",
    outfname = "string",
  },
  outputs = {
    outfile = ["File", "{outfname}"],
  },
  command = m%"
    cat {infile} |
    tr {from_char} {to_char} > {outfname}  
  "%,
}
