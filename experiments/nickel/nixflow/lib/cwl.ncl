let util = import "./util.ncl" in
let p = {
	cwl_version = "v1.0",

	interpolate
		| doc m%"
			interpolate string `s`, converting `{var}` to `$(input.var)$`,
			using each key-value pair in record `vars`
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

	script = "run.sh"

} in {

	interpolate = p.interpolate,

	make_task = fun r => {
		name = r.name,
		type = "task",
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
	}

}
