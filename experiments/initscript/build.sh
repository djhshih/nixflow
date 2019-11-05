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
	local ldef=$1
	local ldeftype=$($nix "${root}.all.${ldef}.type" | jq -r .)
	# TODO write to better location
	local target=${ldef}.cwl

	if [[ ! -f $target ]]; then
		# workflows can have dependencies: build them
		if [[ "$ldeftype" == "workflow" ]]; then
			depends=$($nix "map (x: x.name) ${root}.${ldeftype}s.${ldef}.depends" | jq -r '.[]')
			for d in $depends; do
				build_workflow $d 
			done
		fi

		echo "Building $target ... "
		$nix "${root}.${ldeftype}s.${ldef}.cwl" | jq . > $target
	fi
}

if [[ -z $def ]]; then
	list_defs $deftype
else
	build_workflow $def
fi

