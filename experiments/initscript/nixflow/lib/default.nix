let
	bns = builtins;

	# vars is a set of variables and their types
	# e.g. { infile = "File"; a = "string"; b = "int"; }
	mkInputAttrs = vars:
		let
			f = attr: {
				name = attr;
				value = { type = bns.getAttr attr vars; };
			};
			pairs = map f (bns.attrNames vars);
		in (bns.listToAttrs pairs);
	
	# vars is a set of variables and list containing type and glob
	# e.g. { outfile = ["File" "$(inputs.outfname)"], outval = "string" }
	mkOutputAttrs = inVars: outVars:
		let
			f = attr: {
				name = attr;
				value =
					let
						x = bns.getAttr attr outVars;
					in
						if bns.isList x
						then rec {
							type = bns.elemAt x 0;
							outputBinding = {
								glob = interpolate (bns.elemAt x 1) inVars;
								#loadContents = (type != "File");
								#outputEval = if type == "File" then null else "$(self[0].contents)";
							};
						}
						else { type = x; }
					;
			};
			pairs = map f (bns.attrNames outVars);
		in bns.listToAttrs pairs;

	mkWorkflowInputAttrs = mkInputAttrs;

	variablePath = str: bns.replaceStrings ["."] ["/"] str;

	mkWorkflowOutputAttrs = outVars:
		let
			f = attr: {
				name = attr;
				value =
					let
						x = bns.getAttr attr outVars;
					in
						if bns.isList x
						then {
							type = bns.elemAt x 0;
							outputSource = variablePath (bns.elemAt x 1);
						}
						else { type = x; }
					;
			};
			pairs = map f (bns.attrNames outVars);
		in bns.listToAttrs pairs;

	linkSteps = steps: depends:
		let
			f = stepName: {
				name = stepName;
				value =
					let
						step = bns.getAttr stepName steps;
						taskName = step.task;
						task = bns.getAttr taskName depends;
					in
						{
							run = "${taskName}.cwl";
							"in" =
								let
									h = var: {
										name =  var;
										value = variablePath (bns.getAttr var step.inputs);
									};
									pairs = map h (bns.attrNames step.inputs);
								in bns.listToAttrs pairs;
							out = bns.attrNames task.cwl.outputs;
						}
					;
			};
			pairs = map f (bns.attrNames steps);
		in bns.listToAttrs pairs;

	interpolate = str: vars:
		let
			varNames = (bns.attrNames vars);
			tokens = map (x: "{${x}}") varNames;
			f = var:
				if bns.getAttr var vars == "File"
				then "$(inputs.${var}.path)"
				else "$(inputs.${var})";
			newTokens = map f varNames;
		in
			bns.replaceStrings tokens newTokens str;

	script = "script.sh";

	cwlVersion = "v1.0";

in
{
	callDefWith = defaults: fp: args:
		let
			f = if bns.isFunction fp then fp else import fp;
			auto = bns.intersectAttrs (bns.functionArgs f) defaults;
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
