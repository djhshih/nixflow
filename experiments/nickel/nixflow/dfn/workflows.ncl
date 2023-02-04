fun { lib, tasks} =>

let params = let lib_ = lib in { lib = lib_ } & tasks in
{
  cipher | default = lib.make_workflow (import "workflows/cipher.ncl" tasks)
}
