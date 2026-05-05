{
	Path
		= std.contract.from_predicate (fun value =>
			if %typeof% value == 'Str then 'Ok
			else 'Error { message = "not a path" }
		),

	Task
		| doc "Task definition"
		= {
			name    | String
					    | doc "task name"
					    | default = "",
			inputs  | doc "record of input parameter name and type"
			        | {
			             outbase | doc "basename of output file"
			                     | String | default = "string",
			            ..
			          }
			        | default = {},
			outputs | { .. }
			        | doc "record of output parameter name, type, and value"
			        | default = {},
			exec    | String
			        | doc "command line program and arguments"
			        | default = "bash",
			command | String
			        | doc "command to execute"
			        | default = "",
			runtime | doc "runtime resource requirements"
			        | {
			             cpu | Number | default = 1,
			             memory | Number | default = 2048,
			             disk | Number | default = 1024,
			            ..
			          }
			        | default = {},
			..
		},

	CompiledTask 
		= std.contract.from_predicate (fun x => x.type == "task"),

	Workflow
		| doc "Workflow definition"
		= {
			name    | String
			        | doc "workflow name"
			        | default = "",
			# inputs  | doc "record of input parameter names and types"
			#         | {
			#             outbase | doc "basename of output file"
			#                     | String | default = "string",
			#             ..
			#           },
			depends | Array CompiledTask
			        | doc "task dependencies"
			        | default = [],
			steps   | { .. }
			        | doc "record of tasks to call and their inputs"
			        | default = {},
			outputs | { .. }
			        | doc "record of output variable types and sources"
			        | default = {},
			..
		},
}
