{ lib, toupper, caesar }:

lib.mkWorkflow {
	# TODO populate inputs automatically by searching
	#      for unfulfilled inputs to tasks
	inputs = {
		infile = "File";
		from_chars = "string";
		to_chars = "string";
		toupper_outfname = "string";
		caesar_outfname = "string";
		caesar_caesar_outfname = "string";
	};

	outputs = {
		encrypted = ["File" "caesar.outfile"];
		decrypted = ["File" "caesar2.outfile"];
	};

	depends = { inherit toupper caesar; };

	# specify variable bindings from one task to another
	steps = {
		toupper = {
			task = "toupper";
			inputs = {
				infile = "infile";
				from_chars = "from_chars";
				to_chars = "to_chars";
				outfname = "toupper_outfname";
			};
		};
		caesar = {
			task = "caesar";
			inputs = {
				infile = "toupper.outfile";
				outfname = "caesar_outfname";
			};
		};
		caesar2= {
			task = "caesar";
			inputs = {
				infile = "caesar.outfile";
				outfname = "caesar_caesar_outfname";
			};
		};
	};
}
