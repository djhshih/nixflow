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

nixev="nix-instantiate --eval --strict --expr --json"
root="(import ./nixflow)"
outdir=cwl

list_defs() {
	$nixev "builtins.attrNames ${root}.$1s" | jq -r '.[]'
}

build_workflow() {
	local def=$1
	local type=$($nixev "${root}.type.${def}" | jq -r .)
	local target=$outdir/${def}.cwl

	if [[ ! -f $target ]]; then
		# workflows can have dependencies: build them
		if [[ "$type" == "workflow" ]]; then
			depends=$($nixev "map (x: x.name) ${root}.${type}s.${def}.depends" | jq -r '.[]')
			for d in $depends; do
				build_workflow $d
			done
		fi

		echo "Building $target ... "
		$nixev "${root}.${type}s.${def}.cwl" | jq . > $target
	fi
}

mkdir -p $outdir

if [[ -z $def ]]; then
	list_defs $deftype
else
	build_workflow $def
fi

