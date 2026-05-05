let
	# vars is a set of variables and their types
	# e.g. { infile = "File"; a = "string"; b = "int"; }
	mkInputAttrs = vars:
		let
			f = attr: {
				name = attr;
				value = { type = builtins.getAttr attr vars; };
			};
			pairs = map f (builtins.attrNames vars);
			# first position argument is always the script
			script = {
				type = "File";
				inputBinding = { position = 0; };
			};
		in (builtins.listToAttrs pairs) // { inherit script; };
	
	# vars is a set of variables and list containing type and glob
	# e.g. { outfile = ["File" "$(inputs.outfname)"], outval = "string" }
	mkOutputAttrs = vars:
		let
			f = attr: {
				name = attr;
				value =
					let
						x = builtins.getAttr attr vars;
					in
						if builtins.isList x
						then rec {
							type = builtins.elemAt x 0;
							outputBinding = {
								glob = builtins.elemAt x 1;
								#loadContents = (type != "File");
								#outputEval = if type == "File" then null else "$(self[0].contents)";
							};
						}
						else { type = x; }
					;
			};
			pairs = map f (builtins.attrNames vars);
		in builtins.listToAttrs pairs;
in
{
	task = {inputVars, outputVars}: rec {
		cwlVersion = "v1.0";
		class = "CommandLineTool";
		baseCommand = "bash";
		inputs = mkInputAttrs inputVars;
		outputs = mkOutputAttrs outputVars;
		#stdin = "$(inputs.script.path)";
		requirements = {
			#InlineJavascriptRequirement = {};
			EnvVarRequirement = {
				envDef =
					let
						f = x: {
							name = x;
							value = if (builtins.getAttr x inputs).type == "File"
								then "$(inputs.${x}.path)"
								else "$(inputs.${x})"
							;
						};
						pairs = map f (builtins.attrNames inputs);
					in builtins.listToAttrs pairs;
			};
		};
	};
}
