lib = nixflow/lib
tasks = nixflow/dfn/tasks
workflows = nixflow/dfn/workflows
tasks = nixflow/dfn/tasks

all: cwl/cipher.cwl cwl/csv2ncl.cwl cwl/letter-cases.cwl
	

cwl:
	mkdir -p $@

cwl/cipher.cwl: $(tasks)/caesar.ncl $(workflows)/cipher.ncl $(lib)/cwl.ncl cwl
	./build.sh cipher

cwl/letter-cases.cwl: $(tasks)/tr.ncl $(workflows)/letter-cases.ncl $(lib)/cwl.ncl cwl
	./build.sh letter-cases

cwl/csv2ncl.cwl: $(tasks)/csv2ncl.ncl cwl
	./build.sh csv2ncl

output:
	cwltool --cachedir cache/cipher --outdir out/cipher cwl/cipher.cwl in/cipher/input.yaml
	cwltool --cachedir cache/letter-cases --outdir out/letter-cases cwl/letter-cases.cwl in/letter-cases/input.yaml

clean:
	rm -rf cwl out cache

