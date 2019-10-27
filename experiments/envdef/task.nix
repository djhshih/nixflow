with (import ./nflib.nix);
task {
	inputVars = {
		infile = "File";
		from_chars = "string";
		to_chars = "string";
		outfname = "string";
	};
	outputVars = {
		outfile = ["File" "$(inputs.outfname)"];
	};
}
