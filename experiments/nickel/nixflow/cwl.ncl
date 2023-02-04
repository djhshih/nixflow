let lib_ = import "lib/cwl.ncl" in
let tasks_ = import "dfn/tasks.ncl"
  { lib = lib_ } in
let workflows_ = import "dfn/workflows.ncl"
  { lib = lib_, tasks = tasks_ } in
let get_types = record.map (fun k v => v.type) in
{
  tasks = tasks_,
  workflows = workflows_,
  types = get_types tasks_ & get_types workflows_,
}
