let lib_ = import "lib/cwl.ncl" in
let dfn_ = import "lib/dfn.ncl" in
let tasks_ = import "dfn/tasks.ncl"
  { lib = lib_, dfn = dfn_ } in
let workflows_ = import "dfn/workflows.ncl"
  { lib = lib_, dfn = dfn_, tasks = tasks_ } in
tasks_ & workflows_
