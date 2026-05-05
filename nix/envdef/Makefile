
all: cwl/task.cwl
	

cwl:
	mkdir -p $@

cwl/task.cwl: src/task.nix src/lib/default.nix cwl
	nix-instantiate --eval --json --strict $< | jq . > $@

output.txt: cwl/task.cwl input.yaml
	cwltool $^

clean:
	rm -rf cwl output.txt

