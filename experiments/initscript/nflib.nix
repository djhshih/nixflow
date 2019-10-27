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
		in (builtins.listToAttrs pairs);
	
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
	script = "script.sh";
in
{
	mkWorkflow = {inputVars, outputVars, command}: rec {
		cwlVersion = "v1.0";
		class = "CommandLineTool";
		baseCommand = [ "bash" script ];
		inputs = mkInputAttrs inputVars;
		outputs = mkOutputAttrs outputVars;
		requirements = {
			InitialWorkDirRequirement.listing = [
				{
					entryname = script;
					entry = command;
				}
			];
		};
	};
}
