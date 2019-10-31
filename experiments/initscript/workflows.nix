let
	lib = import ./nflib.nix;

	tasks = import ./tasks.nix;

	defaults = { inherit lib; } // tasks;

	callWorkflow = path: overrides:
		let f = import path;
		in f ( (builtins.intersectAttrs (builtins.functionArgs f) defaults)
				// overrides );

	workflows = {
		cipher = callWorkflow ./cipher.nix {};
	};
	
in workflows
