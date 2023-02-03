let util = import "./util.ncl" in

let p = {

	cwl_version = "v1.0",

	script = "run.sh",

	interpolate
		| doc m%"
			Interpolate string `s`, converting `{var}` to `$(input.var)$`,
			for each key-value pair in record `vars`
			"%
		= fun s vars =>
			let var_names = record.fields vars in
			let tokens = array.map (fun x => "{%{x}}") var_names in
			let f = fun var =>
				if vars."%{var}" == "File"
				then "$(inputs.%{var}.path)"
				else "$(inputs.%{var})" in
			let new_tokens = array.map f var_names in
			util.replace_all tokens new_tokens s,

	make_inputs
		| doc m%"
			vars is a record of variable names and types, e.g.
				{ infile = "File", param = "string" }
			"%
		= fun vars =>
			let
				f = fun k v => { type = v }
			in record.map f vars,

	make_outputs
		| doc m%"
			in_vars is a record of input variable names and types
			out_vars is a record of output variable names and a list containing type
			and the glob pattern, e.g.
			  { outfile = ["File" {inputs.outfname}"], outval = "string" }
			"%
		= fun in_vars out_vars =>
			let
				f = fun k v =>
					if builtin.is_array v
					then {
						type = array.elem_at 0 v,
						outputBinding.glob = interpolate (array.elem_at 1 v) in_vars
					}
					else { type = v }
			in record.map f out_vars,

	var_path = fun s => string.replace "." "/" s,

	make_workflow_inputs = make_inputs,

	make_workflow_outputs
		| doc m%"
			`out_vars` is a record of output variable names and reference, e.g.
			  { outfile = ["File", "task.outfile"], outval = ["string", "task.outval"] }
			we want to convert it to:
			  { outfile = { outputSource = "task/outfile", type = "File" }, ... }
			"%
		= fun out_vars =>
			let
				f = fun k v =>
					if builtin.is_array v
					then {
						type = array.elem_at 0 v,
						outputSource = var_path (array.elem_at 1 v)
					}
					else null
			in record.map f out_vars,

	link_steps
		| doc m%"
			Link steps of a workflow using record `steps` and array `depends`
			"%
		= fun steps depends =>
			let
				f = fun k step =>
					# k may not equal the task name
					let task = array.head (array.filter (fun x => x.name == step.task) depends) in
					{
						run = "%{step.task}.cwl",
						"in" = record.map (fun k v => var_path v) step.inputs,
						out = record.fields task.cwl.outputs,
					}
			in record.map f steps,
					

} in {

	interpolate = p.interpolate,

	is_task
		| doc "Check if value is a task"
		= fun x => x.type == "task",

	is_workflow
		| doc "Check if value is a workflow"
		= fun r => r.type == "workflow",

	make_task
		| doc "Make a task from definition record `r`"
		= fun r => {
			type = "task",
			name = r.name,
			cwl = {
				cwlVersion = p.cwl_version,
				class = "CommandLineTool",
				baseCommand = [ "bash", p.script ],
				inputs = p.make_inputs r.inputs,
				outputs = p.make_outputs r.inputs r.outputs,
				requirements = {
					InitialWorkDirRequirement.listing = [
						{
							entryname = p.script,
							entry = p.interpolate r.command r.inputs
						}
					],
				},
			}
		},

	make_workflow
		| doc "Make a workflow from definition record `r`"
		= fun r => {
			type = "workflow",
			name = r.name,
			depends = r.depends,
			cwl = {
				cwlVersion = p.cwl_version,
				class = "Workflow",
				requirements = if array.any is_workflow r.depends
					then { SubworkflowFeatureRequirement = {} }
					else {},
				inputs = p.make_workflow_inputs r.inputs,
				outputs = p.make_workflow_outputs r.outputs,
				steps = p.link_steps r.steps r.depends,
			},
		},

}
