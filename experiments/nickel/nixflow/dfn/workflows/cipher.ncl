fun { lib, caesar, .. } =>

lib.make_workflow {
  name = "cipher",

  inputs = {
    infile = "File",
    caesar_outfname = "string",
    caesar2_outfname = "string",
  },

  outputs = {
    encrypted = ["File", "caesar.outfile"],
    decrypted = ["File", "caesar2.outfile"],
  },

  depends = [ caesar ],

  steps = {
    caesar = {
      task = "caesar",
      inputs = {
        infile = "infile",
        outfname = "caesar_outfname",
      },
    },
    caesar2 = {
      task = "caesar",
      inputs = {
        infile = "caesar.outfile",
        outfname = "caesar2_outfname",
      },
    },
  },
}