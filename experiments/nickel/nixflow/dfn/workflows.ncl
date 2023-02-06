fun { lib, dfn, tasks} =>

let params = let dfn_ = dfn in { dfn = dfn_ } & tasks in
{
  cipher | default = lib.make_workflow (import "workflows/cipher.ncl" params),
  letter-cases | default = lib.make_workflow (import "workflows/letter-cases.ncl" params),
}
