lib = nixflow/lib
tasks = nixflow/defs/tasks
workflows = nixflow/defs/workflows

all: cwl/toupper.cwl cwl/caesar.cwl cwl/cipher.cwl
	

cwl:
	mkdir -p $@

cwl/toupper.cwl: $(tasks)/toupper.nix $(lib)/cwl.nix cwl
	./build.sh task toupper

cwl/caesar.cwl: $(tasks)/caesar.nix $(lib)/cwl.nix cwl
	./build.sh task caesar

cwl/cipher.cwl: cwl/toupper.cwl cwl/caesar.cwl $(workflows)/cipher.nix $(lib)/cwl.nix cwl
	./build.sh workflow cipher

output_caesar.txt:
	cwltool cwl/cipher.cwl input.yaml

clean:
	rm -rf cwl output*.txt

