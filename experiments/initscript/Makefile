
all: toupper.cwl caesar.cwl cipher.cwl
	

toupper.cwl: toupper.nix nflib.nix
	./task.sh toupper > $@

caesar.cwl: caesar.nix nflib.nix
	./task.sh caesar > $@

cipher.cwl: toupper.cwl caesar.cwl nflib.nix
	./workflow.sh cipher > $@
