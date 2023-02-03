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

nickex="nickel export --format json"
root='(import "nixflow/cwl.ncl")'
outdir=cwl

list_defs() {
	echo "record.fields ${root}.$1s" | $nickex | jq -r '.[]'
}

build_workflow() {
	local def=$1
	local type=$(echo "${root}.types.${def}" | $nickex | jq -r .)
	local target=$outdir/${def}.cwl

	# workflows can have dependencies: build them
	if [[ "$type" == "workflow" ]]; then
		depends=$(echo "array.map (fun x => x.name) ${root}.${type}s.${def}.depends" | 
				$nickex | jq -r '.[]')
		for d in $depends; do
			build_workflow $d
		done
	fi

	echo "Building $target ... "
	echo "${root}.${type}s.${def}.cwl" | $nickex | jq . > $target
}

mkdir -p $outdir

if [[ -z $def ]]; then
	list_defs $deftype
else
	build_workflow $def
fi

