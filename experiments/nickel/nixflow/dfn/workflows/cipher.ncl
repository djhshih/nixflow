# NB  all dependencies must be listed here
fun { dfn, caesar, .. } =>
{
  name = "cipher",

  # NB  input parameters may be inferred from:
  #     args missing from steps (e.g. caesar_infile)
  #     args used in steps (e.g. caesar2_outbase)
  # NB  default parameters, e.g. outbase (string) will be inserted and linked
  # inputs = {
  #   caesar2_outbase = "string",
  # },

  # NB  all task dependencies used in steps must also be listed here
  depends = [ caesar ],

  steps = {
    caesar = {
      # NB  if task has the same name as the step, it can be omitted
      # task = "caesar",

      # NB  omitted inputs can be automatically inserted into the cwl
      # inputs = {
      #     infile = "infile",
      # },
    },
    caesar2 = {
      # NB  task name must be specified if it is not the same as the step name
      task = "caesar",
      inputs = {
        infile = "caesar.outfile",
        outbase = "caesar2_outbase",
      },
    },
  },

  outputs = {
    encrypted = "caesar.outfile",
    decrypted = "caesar2.outfile",
  },
} | dfn.Workflow
