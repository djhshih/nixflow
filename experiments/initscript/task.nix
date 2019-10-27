with (import ./nflib.nix);
mkWorkflow {
	inputVars = {
		infile = "File";
		from_chars = "string";
		to_chars = "string";
		outfname = "string";
	};
	outputVars = {
		outfile = ["File" "{outfname}"];
	};
	command = ''
		cat {infile} |
		tr {from_chars} {to_chars} > {outfname}
	'';
}
