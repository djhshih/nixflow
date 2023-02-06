lib = nixflow/lib
tasks = nixflow/dfn/tasks
workflows = nixflow/dfn/workflows
tasks = nixflow/dfn/tasks

all: cwl/cipher.cwl cwl/csv2ncl.cwl cwl/letter-cases.cwl
	

cwl:
	mkdir -p $@

cwl/cipher.cwl: $(tasks)/caesar.ncl $(workflows)/cipher.ncl $(lib)/cwl.ncl cwl
	./build.sh workflow cipher

cwl/letter-cases.cwl: $(tasks)/tr.ncl $(workflows)/letter-cases.ncl $(lib)/cwl.ncl cwl
	./build.sh workflow letter-cases

cwl/csv2ncl.cwl: $(tasks)/csv2ncl.ncl cwl
	./build.sh task csv2ncl

output:
	cwltool --cachedir cache/cipher --outdir out cwl/cipher.cwl input.yaml
	# using a cache directory for the letter-cases workflow causes an incorrect
	# cache directory to be created... perhaps because both steps use tr.cwl and
	# the same input file (even though the other parameters are different)?
	cwltool --outdir out cwl/letter-cases.cwl example/letter-cases/input.yaml

clean:
	rm -rf cwl out cache

