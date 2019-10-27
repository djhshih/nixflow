
all: nix.cwl
	

nix.cwl: task.nix nflib.nix
	nix-instantiate --eval --json --strict ./task.nix | jq . > $@
