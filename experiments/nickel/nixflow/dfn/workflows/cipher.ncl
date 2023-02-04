# NB  all dependencies must be listed here
fun { dfn, caesar, .. } =>
{
  name = "cipher",

  # NB  inputs may be inferred from the steps
  # inputs = {
  #   infile = "File",
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
      },
    },
  },

  # TODO infer variable type
  outputs = {
    encrypted = ["File", "caesar.outfile"],
    decrypted = ["File", "caesar2.outfile"],
  },
} | dfn.Workflow
