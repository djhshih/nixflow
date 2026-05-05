fun { dfn, tr, .. } =>
{
  name = "letter-cases",

  # NB  default parameters, e.g. outbase (string) is automatically declared
  inputs = {
    infile = "File",
    from_char = "string",
  },

  depends = [ tr ],

  steps = {
    upper = {
      task = "tr",
      # NB since infile, from_char, and outbase are defined above,
      #    we can auto-fill them as arguments to task parameters with the 
      #    same name
      # NB missing argument for the `to_char` task parameter will be
      #    set to a `upper_to_char` workflow parameter, which will be
      #    automaticlaly defined
      inputs = {
        # infile = "infile",
        # from_char = "from_char",
        # to_char = "upper_to_char",
        # outbase = "outbase",
      }
    },
    lower = {
      task = "tr",
      # NB we specify `lower_outbase` explicitly here, because we do not want
      #    to use the same `outbase` as in the `upper` step
      inputs = {
        infile = "upper.outfile",
        # from_char = "from_char",
        # to_char = "lower_to_char",
        outbase = "lower_outbase",
      },
    },
  },

  outputs = {
    upper = "upper.outfile",
    lower = "lower.outfile",
  },
} | dfn.Workflow
