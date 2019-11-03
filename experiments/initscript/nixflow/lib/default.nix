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
	mkOutputAttrs = inVars: outVars:
		let
			f = attr: {
				name = attr;
				value =
					let
						x = builtins.getAttr attr outVars;
					in
						if builtins.isList x
						then rec {
							type = builtins.elemAt x 0;
							outputBinding = {
								glob = interpolate (builtins.elemAt x 1) inVars;
								#loadContents = (type != "File");
								#outputEval = if type == "File" then null else "$(self[0].contents)";
							};
						}
						else { type = x; }
					;
			};
			pairs = map f (builtins.attrNames outVars);
		in builtins.listToAttrs pairs;

	mkWorkflowInputAttrs = mkInputAttrs;

	variablePath = str: builtins.replaceStrings ["."] ["/"] str;

	mkWorkflowOutputAttrs = outVars:
		let
			f = attr: {
				name = attr;
				value =
					let
						x = builtins.getAttr attr outVars;
					in
						if builtins.isList x
						then {
							type = builtins.elemAt x 0;
							outputSource = variablePath (builtins.elemAt x 1);
						}
						else { type = x; }
					;
			};
			pairs = map f (builtins.attrNames outVars);
		in builtins.listToAttrs pairs;

	linkSteps = steps: depends:
		let
			f = stepName: {
				name = stepName;
				value =
					let
						step = builtins.getAttr stepName steps;
						taskName = step.task;
						task = builtins.getAttr taskName depends;
					in
						{
							run = "${taskName}.cwl";
							"in" =
								let
									h = var: {
										name =  var;
										value = variablePath (builtins.getAttr var step.inputs);
									};
									pairs = map h (builtins.attrNames step.inputs);
								in builtins.listToAttrs pairs;
							out = builtins.attrNames task.cwl.outputs;
						}
					;
			};
			pairs = map f (builtins.attrNames steps);
		in builtins.listToAttrs pairs;

	interpolate = str: vars:
		let
			varNames = (builtins.attrNames vars);
			tokens = map (x: "{${x}}") varNames;
			f = var:
				if builtins.getAttr var vars == "File"
				then "$(inputs.${var}.path)"
				else "$(inputs.${var})";
			newTokens = map f varNames;
		in
			builtins.replaceStrings tokens newTokens str;

	script = "script.sh";

	cwlVersion = "v1.0";

in
{
	callDefWith = defaults: fp: args:
		with builtins;
		let
			f = if isFunction fp then fp else import fp;
			auto = intersectAttrs (functionArgs f) defaults;
		in f (auto // args);

	mkTask = { inputs, outputs, command }: {
		type = "task";
		cwl = {
			inherit cwlVersion;
			class = "CommandLineTool";
			baseCommand = [ "bash" script ];
			inputs = mkInputAttrs inputs;
			outputs = mkOutputAttrs inputs outputs;
			requirements = {
				InitialWorkDirRequirement.listing = [
					{
						entryname = script;
						entry = interpolate command inputs;
					}
				];
			};
		};
	};

	mkWorkflow = { inputs, outputs, depends, steps }: {
		type = "workflow";
		cwl = {
			inherit cwlVersion;
			class = "Workflow";
			inputs = mkWorkflowInputAttrs inputs;
			outputs = mkWorkflowOutputAttrs outputs;
			steps = linkSteps steps depends;
		};
	};
}
