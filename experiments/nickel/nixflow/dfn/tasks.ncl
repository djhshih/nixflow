fun r =>

let defaults = { lib | default = r.lib } in
{
  caesar = import "tasks/caesar.ncl" defaults,
  tr = import "tasks/tr.ncl" defaults,
}
