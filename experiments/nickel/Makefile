lib = nixflow/lib
tasks = nixflow/dfn/tasks
workflows = nixflow/dfn/workflows
tasks = nixflow/dfn/tasks

all: cwl/cipher.cwl
	

cwl:
	mkdir -p $@

cwl/cipher.cwl: $(tasks)/caesar.ncl $(workflows)/cipher.ncl $(lib)/cwl.ncl cwl
	./build.sh workflow cipher

output:
	cwltool cwl/cipher.cwl input.yaml

clean:
	rm -rf cwl output*.txt

