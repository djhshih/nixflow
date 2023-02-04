let util = import "./util.ncl" in

let p = {

	cwl_version = "v1.0",

	script = "command",

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
					let glob = interpolate v in_vars in
					if string.contains "*" glob then {
						type = { type = "array", items = "File" },
						outputBinding.glob = glob,
					} else {
						type = "File",
						outputBinding.glob = glob,
					}
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
		= fun dfn  =>
			let out_types = workflow_output_types dfn in
			let	f = fun name source =>
				{
					type = out_types."%{name}",
					outputSource = var_path source,
				}
			in record.map f dfn.outputs,

	find_dep
		| doc m%"
			Find dependency by name in a dependency array
			"%
		= fun name depends =>
			let matches = 
				(array.filter (fun x => x.name == name) depends) in
			if array.length matches == 0 then
				builtin.trace "error: %{name} not found in depends"
					{name = "", type = "error"}
			else array.head matches,

	link_steps
		| doc m%"
			Link steps of a workflow using record `steps` and array `depends`
			"%
		= fun steps depends =>
			let
				f = fun k step =>
					# k may not equal the task name
					let name =
						if record.has_field "task" step then step.task else k in
					let task = find_dep name depends in
					{
						run = "%{name}.cwl",
						"in" = record.map (fun k v => var_path v) step.inputs,
						out = record.fields task.cwl.outputs,
					}
			in record.map f steps,
					
	missing_workflow_inputs
		| doc m%"
			Find missing workflow inputs from dfn `steps` and `depends`.
			e.g. Produce `{ caesar = {out = {type = "string"}}, caesar2 = {out = {type = "string"}} }`
			to indicate that step `caesar` is missing input `out` and `caesar2` is missing `out`.
			"%
		= fun steps depends => 
			let f = fun k v => 
				let	name = if record.has_field "task" v then v.task else k in
				let task = find_dep name depends in
				let vars = record.fields task.cwl.inputs in
				let missing_vars =
					if record.has_field "inputs" v then
						let defined = (record.fields v.inputs) in
						array.filter (fun var => !(array.any (fun d => var == d) defined)) vars
					else vars
				in array.foldl (fun r var => r & {"%{var}" = task.cwl.inputs."%{var}"})
					{} missing_vars
#in record.map f steps |> record.values |> array.foldl (&) {},
			in record.map f steps,

	missing_to_inputs
		| doc m%"
			Format `missing` record as inputs record by
			prepending step name to the variable name and flattening the record.
			"%
		= fun missing =>
			let f = fun k vars =>
				let names = record.fields vars in
				array.foldl (fun r name => r & {"%{k}_%{name}" = vars."%{name}"}) {} names
			in record.map f missing |> record.values |> array.foldl (&) {},

	insert_missing
		| doc m%"
			Insert `missing` inputs into dfn `steps`.
			"%
		= fun missing steps =>
			let f = fun k vars =>
				let names = record.fields vars in
				array.foldl (fun r name => r & { "inputs"."%{name}" = "%{k}_%{name}" }) {} names
			in (record.map f missing) & steps,

	workflow_output_types
		| doc m%"
			Determine workflow output types
			"%
		= fun { steps, depends, outputs, .. } =>
			let f = fun k v =>
				let tokens = string.split "." v in
				let step_name = array.elem_at 0 tokens in
				let out_name = array.elem_at 1 tokens in
				let step = steps."%{step_name}" in
				let task_name =
					if record.has_field "task" step then step.task else step_name in
				let task = find_dep task_name depends in
				task.cwl.outputs."%{out_name}".type
			in (record.map f outputs),

} in {

	is_task
		| doc "Check if value is a task"
		= fun x => x.type == "task",

	is_workflow
		| doc "Check if value is a workflow"
		= fun x => x.type == "workflow",

	make_task
		| doc "Make a task from definition record `r`"
		= fun r => {
			type = "task",
			name = r.name,
			cwl = {
				cwlVersion = p.cwl_version,
				class = "CommandLineTool",
				baseCommand = string.split " " r.exec @ [p.script],
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
		= fun r => 
			let missing = p.missing_workflow_inputs r.steps r.depends in
			let filled_steps = p.insert_missing missing r.steps in
			{
				type = "workflow",
				name = r.name,
				depends = r.depends,
				cwl = {
					cwlVersion = p.cwl_version,
					class = "Workflow",
					requirements = if array.any is_workflow r.depends
						then { SubworkflowFeatureRequirement = {} }
						else {},
					inputs =
						let inputs_ = if record.has_field "inputs" r
							then p.make_workflow_inputs r.inputs else {}
						in inputs_ & p.missing_to_inputs missing,
					outputs = p.make_workflow_outputs r,
					steps = p.link_steps filled_steps r.depends,
				},
			},

	interpolate = p.interpolate,

}
