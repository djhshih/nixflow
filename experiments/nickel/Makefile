lib = nixflow/lib
tasks = nixflow/dfn/tasks
workflows = nixflow/dfn/workflows

all: cwl/cipher.cwl
	

cwl:
	mkdir -p $@

cwl/caesar.cwl:
	./build.sh task caesar

cwl/cipher.cwl: cwl/caesar.cwl $(workflows)/cipher.ncl $(lib)/cwl.ncl cwl
	./build.sh workflow cipher

output_caesar.txt:
	cwltool cwl/cipher.cwl input.yaml

clean:
	rm -rf cwl output*.txt

