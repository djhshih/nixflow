fun { dfn } =>
{
  name = "csv2ncl",
  inputs = {
    infile = "File",
    sep = "string",
    outbase = "string",
  },
  outputs = {
    outfile = "{outbase}.txt",
  },
  exec = "python",

  # NB string literal '\n' will not be serialized properly by cwltool!
  command = m%"

with open('{infile}') as inf:
  header = inf.readline().rstrip()
  fields = header.split('{sep}')
  out = []
  for line in inf:
    rows = []
    values = line.rstrip().split('{sep}')
    for k, v in zip(fields, values):
        rows.append('{}="{}"'.format(k, v))
    out.append( '{' + ','.join(rows) + '}' )

with open('{outbase}.txt', 'w') as outf:
  outf.write('[' + ','.join(out) + ']')
  
  "%,
} | dfn.Task
