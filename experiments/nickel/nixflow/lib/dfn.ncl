{
	Path
		= fun label value =>
			if %typeof% value == `Str then
				value
			else
				%blame% (%tag% "not a path" label),

	Task
		| doc "Task definition"
		= {
			name    | Str
					    | doc "task name",
			inputs  | doc "record of input parameter name and type"
			        | {
			             outbase | doc "basename of output file"
			                     | Str | default = "string",
			            ..
			          },
			outputs | { .. } 
			        | doc "record of output parameter name, type, and value",
			exec    | Str
			        | doc "command line program and arguments"
			        | default = "bash",
			command | Str 
			        | doc "command to execute",
			..
		},

	CompiledTask 
		= contract.from_predicate (fun x => x.type == "task"),

	Workflow
		| doc "Workflow definition"
		= {
			name    | Str
			        | doc "workflow name",
			# inputs  | doc "record of input parameter names and types"
			#         | {
			#             outbase | doc "basename of output file"
			#                     | Str | default = "string",
			#             ..
			#           },
			depends | Array CompiledTask
			        | doc "task dependencies",
			steps   | { .. } 
			        | doc "record of tasks to call and their inputs",
			outputs | { .. } 
			        | doc "record of output variable types and sources",
			..
		},
}
