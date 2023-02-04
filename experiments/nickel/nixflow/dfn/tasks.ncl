fun { lib } =>

let params = let lib_ = lib in { lib = lib_ } in
{
  caesar | default = lib.make_task (import "tasks/caesar.ncl" params),
  tr | default = lib.make_task (import "tasks/tr.ncl" params),
}
