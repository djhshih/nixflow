with (import ./nflib.nix);
mkWorkflow {
	inputVars = {
		infile = "File";
		from_chars = "string";
		to_chars = "string";
		outfname = "string";
	};
	outputVars = {
		outfile = ["File" "$(inputs.outfname)"];
	};
	command = ''
		cat $(inputs.infile.path) |
		tr $(inputs.from_chars) $(inputs.to_chars) > $(inputs.outfname)
	'';
}
