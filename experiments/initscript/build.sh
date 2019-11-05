#!/bin/bash

# Build CWL files.

set -euo pipefail

if [[ $# < 1 ]]; then
	echo "usage $0 <task | workflow> [name]"
	exit 1
fi

deftype=$1

if [[ "$deftype" != "task" && "$deftype" != "workflow" ]]; then
	echo "Input error: we got $deftype but expect task or workflow"
	exit 1
fi

if [[ $# < 2 ]]; then
	def=''
else
	def=$2
fi


nix="nix-instantiate --eval --strict --expr --json"
root="(import ./nixflow/defs/top-level)"

list_defs() {
	$nix "builtins.attrNames ${root}.$1s" | jq -r '.[]'
}

build_workflow() {
	local def=$1
	local deftype=$($nix "${root}.all.${def}.type" | jq -r .)

	# TODO write to better location
	target=${def}.cwl	

	if [[ ! -f $target ]]; then
		# local variables will be overwritten in recursive call (quirk of Bash)
		# therefore, we need to build the target now
		# ideally, we would build the target last
		echo "Building $target ... "
		$nix "${root}.${deftype}s.${def}.cwl" | jq . > $target

		# workflows can have dependencies: build them
		if [[ "$deftype" == "workflow" ]]; then
			depends=$($nix "map (x: x.name) ${root}.${deftype}s.${def}.depends" | jq -r '.[]')
			for d in $depends; do
				build_workflow $d 
			done
		fi
	fi
}

if [[ -z $def ]]; then
	list_defs $deftype
else
	build_workflow $def
fi

