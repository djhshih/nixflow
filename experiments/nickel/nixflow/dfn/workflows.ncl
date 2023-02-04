fun r =>

let params = { lib | default = r.lib } & r.tasks in
{
  cipher | default = import "workflows/cipher.ncl" params
}
