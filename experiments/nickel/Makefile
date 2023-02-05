lib = nixflow/lib
tasks = nixflow/dfn/tasks
workflows = nixflow/dfn/workflows
tasks = nixflow/dfn/tasks

all: cwl/cipher.cwl cwl/csv2ncl.cwl
	

cwl:
	mkdir -p $@

cwl/cipher.cwl: $(tasks)/caesar.ncl $(workflows)/cipher.ncl $(lib)/cwl.ncl cwl
	./build.sh workflow cipher

cwl/csv2ncl.cwl: $(tasks)/csv2ncl.ncl cwl
	./build.sh task csv2ncl

output:
	cwltool --cachedir cache --outdir out cwl/cipher.cwl input.yaml

clean:
	rm -rf cwl output*.txt

