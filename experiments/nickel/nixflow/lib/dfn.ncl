{
	Task
		| doc "Task definition"
		= {
			name    | Str
					    | doc "task name",
			inputs  | { .. }
						  | doc "record of input parameter name and type",
			outputs | { .. } 
						  | doc "record of output parameter name, type, and value",
			command | Str 
							| doc "execution command",
			..
		},

	CompiledTask 
		= contract.from_predicate (fun x => x.type == "task"),

	Workflow
		| doc "Workflow definition"
		= {
			name    | Str
			        | doc "workflow name",
			depends | Array CompiledTask
			        | doc "task dependencies",
			steps   | { .. } 
			        | doc "record of tasks to call and their inputs",
			outputs | { .. } 
				      | doc "record of output variable types and sources",
			..
		},
}
