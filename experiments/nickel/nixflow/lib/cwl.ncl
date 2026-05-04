let util = import "./util.ncl" in

let p = {

	cwl_version = "v1.0",

	script = "command",

	interpolate
		| doc m%"
			Interpolate std.string `s`, converting `{var}` to `$(input.var)$`,
			for each key-value pair in std.record `vars`
			"%
		= fun s vars =>
			let var_names = std.record.fields vars in
			let f = fun s var =>
				let token = "%{var}" in
				let replacement = 
					if vars."%{var}" == "File"
					then "$(inputs.%{var}.path)"
					else "$(inputs.%{var})" in
				util.replace_all token replacement s
			in std.array.fold_left f s var_names,

	make_inputs
		| doc m%"
			vars is a std.record of variable names and types, e.g.
				{ infile = "File", param = "std.string" }
			"%
		= fun vars =>
			let
				f = fun k v => { type = v }
			in std.record.map f vars,

	make_outputs
		| doc m%"
			in_vars is a std.record of input variable names and types
			out_vars is a std.record of output variable names and a list containing type
			and the glob pattern, e.g.
			  { outfile = ["File" {inputs.outfname}"], outval = "std.string" }
			"%
		= fun in_vars out_vars =>
			let
				f = fun k v =>
					let glob = interpolate v in_vars in
					if std.string.contains "*" glob then {
						type = { type = "std.array", items = "File" },
						outputBinding.glob = glob,
					} else {
						type = "File",
						outputBinding.glob = glob,
					}
			in std.record.map f out_vars,

	var_path = fun s => std.string.replace "." "/" s,

	make_workflow_inputs = make_inputs,

	make_workflow_outputs
		| doc m%"
			`out_vars` is a std.record of output variable names and reference, e.g.
			  { outfile = ["File", "task.outfile"], outval = ["std.string", "task.outval"] }
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
			in std.record.map f dfn.outputs,

	find_dep
		| doc m%"
			Find dependency by name in a dependency std.array
			"%
		= fun name depends =>
			let matches = 
				(std.array.filter (fun x => x.name == name) depends) in
			if std.array.length matches == 0 then
				std.io.trace "error: %{name} not found in depends"
					{name = "", type = "error"}
			else std.array.first matches,

	link_steps
		| doc m%"
			Link steps of a workflow using std.record `steps` and std.array `depends`
			"%
		= fun steps depends =>
			let
				f = fun k step =>
					# k may not equal the task name
					let name =
						if std.record.has_field "task" step then step.task else k in
					let task = find_dep name depends in
					{
						run = "%{name}.cwl",
						"in" = std.record.map (fun k v => var_path v) step.inputs,
						out = std.record.fields task.cwl.outputs,
					}
			in std.record.map f steps,
					
	find_missing_task_args
		| doc m%"
			Find missing workflow inputs based on missing task arguments in dfn `steps`,
			relying on compiled task std.records in `depends`.
			e.g. Produce `{ caesar = {out = {type = "std.string"}}, caesar2 = {out = {type = "std.string"}} }`
			to indicate that step `caesar` is missing input `out` and `caesar2` is missing `out`.
			"%
		= fun steps depends => 
			let f = fun k v => 
				let	name = if std.record.has_field "task" v then v.task else k in
				let task = find_dep name depends in
				let vars = std.record.fields task.cwl.inputs in
				let missing_vars =
					if std.record.has_field "inputs" v then
						let defined = (std.record.fields v.inputs) in
						std.array.filter (fun var => !(std.array.any (fun d => var == d) defined)) vars
					else vars
				in std.array.fold_left (fun r var => r & {"%{var}" = task.cwl.inputs."%{var}"})
					{} missing_vars
			in std.record.map f steps,

	missing_to_inputs
		| doc m%"
			Format `missing` std.record as inputs std.record by
			prepending step name to the variable name and flattening the std.record.
			"%
		= fun missing =>
			let f = fun k vars =>
				let names = std.record.fields vars in
				std.array.fold_left (fun r name => r & {"%{k}_%{name}" = vars."%{name}"}) {} names
			in std.record.map f missing |> std.record.values |> std.array.fold_left (&) {},

	insert_auto_args
		| doc m%"
			Insert auto arguments into dfn `steps` if the input workflow parameter name
		  matches the task parameter name.
			"%
		= fun inputs steps depends =>
			let f = fun step_name step =>
				let task = find_step_task step_name step depends in
				let step_inputs = 
					if std.record.has_field "inputs" step then step.inputs 
					else {} in
				let g = fun var type =>
					if std.record.has_field var step_inputs then
						# step already defined the parameter: do nothing
						{}
					else if std.record.has_field var task.cwl.inputs &&
						task.cwl.inputs."%{var}".type == type then
						# step did not define parameter but task has parameter with the
						# same name and type: add this parameter to the step
						{ inputs."%{var}" = var }
					else
						# no match: do nothing
						{}
				in let adds = std.record.map g inputs |> std.record.values in
				std.array.fold_left (fun r add => r & add) step adds
			in (std.record.map f steps)
		,

	insert_missing_args
		| doc m%"
			Insert `missing` inputs into dfn `steps`.
			"%
		= fun missing steps =>
			let f = fun k vars =>
				let names = std.record.fields vars in
				std.array.fold_left (fun r name => r & { "inputs"."%{name}" = "%{k}_%{name}" }) {} names
			in (std.record.map f missing) & steps,

	find_step_task
		| doc m%"
			Find compiled task std.record for `step` from depends
			"%
		= fun step_name step depends =>
			let task_name =
				if std.record.has_field "task" step then step.task else step_name in
			find_dep task_name depends,

	find_required_args
		| doc m%"
			Find required args in dfn `steps`, returning std.record of arg name and type
			"%
		= fun steps depends =>
			let f = fun step_name step =>
				if std.record.has_field "inputs" step then
					let g = fun var v =>
						# ignore args based on task outputs
						if std.string.contains "." v then {}
						else
							let task = find_step_task step_name step depends in
							{ "%{v}" = task.cwl.inputs."%{var}".type }
					in std.record.map g step.inputs |> std.record.values
				else []
			in let vars = std.record.map f steps |> std.record.values |> std.array.flatten in
			std.array.fold_left (fun r x => r & x) {} vars,

	workflow_output_types
		| doc m%"
			Determine workflow output types
			"%
		= fun { steps, depends, outputs, .. } =>
			let f = fun k v =>
				let tokens = std.string.split "." v in
				let step_name = std.array.at 0 tokens in
				let out_name = std.array.at 1 tokens in
				let step = steps."%{step_name}" in
				let task_name =
					if std.record.has_field "task" step then step.task else step_name in
				let task = find_dep task_name depends in
				task.cwl.outputs."%{out_name}".type
			in (std.record.map f outputs),

} in {

	is_task
		| doc "Check if value is a task"
		= fun x => x.type == "task",

	is_workflow
		| doc "Check if value is a workflow"
		= fun x => x.type == "workflow",

	make_task
		| doc "Make a task from definition std.record `r`"
		= fun r => {
			type = "task",
			name = r.name,
			cwl = {
				cwlVersion = p.cwl_version,
				class = "CommandLineTool",
				baseCommand = std.string.split " " r.exec @ [p.script],
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
		| doc "Make a workflow from definition std.record `r`"
		= fun r => 
			let inputs_declared = if std.record.has_field "inputs" r then r.inputs else {} in
			let rargs_dfn = p.find_required_args r.steps r.depends in
			let inputs_dfn = inputs_declared & { outbase = "std.string" } & rargs_dfn in
			let steps1 = p.insert_auto_args inputs_dfn r.steps r.depends in
			let missing = p.find_missing_task_args steps1 r.depends in
			let steps2 = p.insert_missing_args missing steps1 in
			{
				steps1_ = steps1,
				type = "workflow",
				name = r.name,
				depends = r.depends,
				cwl = {
					cwlVersion = p.cwl_version,
					class = "Workflow",
					requirements = if std.array.any is_workflow r.depends
						then { SubworkflowFeatureRequirement = {} }
						else {},
					inputs = p.make_workflow_inputs inputs_dfn & p.missing_to_inputs missing,
					outputs = p.make_workflow_outputs r,
					steps = p.link_steps steps2 r.depends,
				},
			},

	interpolate = p.interpolate,

}
