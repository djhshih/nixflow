{ lib }:

lib.mkTask {
	name = "caesar";
	inputs = {
		infile = "File";
		#from_chars = "string";
		#to_chars = "string";
		outfname = "string";
	};
	outputs = {
		outfile = ["File" "{outfname}"];
	};
	command = ''
		cat {infile} |
		tr ABCDEFGHIJKLMNOPQRSTUVWXYZ NOPQRSTUVWXYZABCDEFGHIJKLM > {outfname}
	'';
}
