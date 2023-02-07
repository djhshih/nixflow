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

nickex="nickel export"
root='(import "nixflow/cwl.ncl")'
outdir=in

list_defs() {
	echo "record.fields ${root}.$1s" | $nickex | jq -r '.[]'
}

make_template() {
	local def=$1
	local type=$(echo "${root}.types.${def}" | $nickex | jq -r .)
	local target=common.ncl

	mkdir -p $outdir/$def/
	nickel <<< "let inputs = ${root}.${type}s.${def}.cwl.inputs in let f = fun k v => v.type in record.map f inputs" \
		> $outdir/$def/$target
}

mkdir -p $outdir

if [[ -z $def ]]; then
	list_defs $deftype
else
	make_template $def
fi

