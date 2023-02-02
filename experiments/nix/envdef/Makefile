
all: task.cwl
	

task.cwl: src/task.nix src/lib/default.nix
	nix-instantiate --eval --json --strict $< | jq . > $@

output.txt: task.cwl input.yaml
	cwltool $^

