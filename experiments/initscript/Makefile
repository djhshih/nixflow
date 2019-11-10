lib = nixflow/lib
tasks = nixflow/defs/tasks
workflows = nixflow/defs/workflows

all: toupper.cwl caesar.cwl cipher.cwl
	

toupper.cwl: $(tasks)/toupper.nix $(lib)/cwl.nix
	./build.sh task toupper

caesar.cwl: $(tasks)/caesar.nix $(lib)/cwl.nix
	./build.sh task caesar

cipher.cwl: toupper.cwl caesar.cwl $(workflows)/cipher.nix $(lib)/cwl.nix
	./build.sh workflow cipher

clean:
	rm -rf toupper.cwl caesar.cwl cipher.cwl
