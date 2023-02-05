# NB  all dependencies must be listed here
fun { dfn, caesar, .. } =>
{
  name = "cipher",

  # NB  missing inputs may be inferred from the steps
  inputs = {
    caesar2_outbase = "string",
  },

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
