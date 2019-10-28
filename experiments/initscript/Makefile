
all: toupper.cwl caesar.cwl
	

toupper.cwl: toupper.nix nflib.nix
	./task.sh toupper > $@

caesar.cwl: caesar.nix nflib.nix
	./task.sh caesar > $@
