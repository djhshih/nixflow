
all: nix.cwl
	

nix.cwl: task.nix nflib.nix
	nix-instantiate --eval --json --strict --expr '(import ./task.nix) { lib = (import ./nflib.nix); }' | jq . > $@
