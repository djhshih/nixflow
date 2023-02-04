fun r =>

let params = { lib | default = r.lib } in
{
  caesar | default = import "tasks/caesar.ncl" params,
  tr | default = import "tasks/tr.ncl" params,
}
