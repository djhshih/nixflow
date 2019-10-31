let
	lib = import ./nflib.nix;

	defaults = { inherit lib; };

	callTask = path: overrides:
		let f = import path;
		in f ( (builtins.intersectAttrs (builtins.functionArgs f) defaults)
				// overrides );
	
	tasks = {
		toupper = callTask ./toupper.nix {};
		caesar = callTask ./caesar.nix {};
	};
	
in tasks
