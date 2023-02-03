fun { lib, caesar, .. } =>

lib.make_workflow {
  name = "cipher",

  # inputs = {
  #   infile = "File",
  # },

  depends = [ caesar ],

  steps = {
    caesar = {
      # task = "caesar",
      # inputs = {
      #     infile = "infile",
      # },
    },
    caesar2 = {
      task = "caesar",
      inputs = {
        infile = "caesar.outfile",
      },
    },
  },

  outputs = {
    encrypted = ["File", "caesar.outfile"],
    decrypted = ["File", "caesar2.outfile"],
  },
}
