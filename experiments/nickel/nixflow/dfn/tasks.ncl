fun { lib, dfn } =>

let params = let dfn_ = dfn in { dfn = dfn_ } in
{
  caesar | default = lib.make_task (import "tasks/caesar.ncl" params),
  tr | default = lib.make_task (import "tasks/tr.ncl" params),
  csv2ncl | default = lib.make_task (import "tasks/csv2ncl.ncl" params),
}
