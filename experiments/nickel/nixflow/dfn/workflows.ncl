fun r =>

let defaults = { lib | default = r.lib } & r.tasks in
{
  cipher = import "workflows/cipher.ncl" defaults
}
