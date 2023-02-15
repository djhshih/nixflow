#!/bin/bash

# Build CWL files.

set -euo pipefail

root='(import "nixflow/cwl.ncl")'

nickpr() {
	nickel export --format yaml <<< $1 |
	sed 's/---//;s/- //g'
}

nickex() {
	nickel export --format json <<< $1
}

list_defs() {
	nickex "record.fields ${root}"
}

build() {
	local def=$1
	local type=$(nickpr "${root}.${def}.type")
	local target=$outdir/${def}.cwl

	mkdir -p $outdir

	echo $type
	# workflows can have dependencies: build them
	if [[ $type =~ "workflow" ]]; then
		depends=$(nickpr "array.map (fun x => x.name) ${root}.${def}.depends")
		echo $depends
		for d in $depends; do
			build $d
		done
	fi

	echo "Building $target ... "
	nickex "${root}.${def}.cwl" > $target
}


if [[ $# < 1 ]]; then
	echo "usage: $0 [task | workflow]"
	echo "available tasks or workflows: "
	list_defs
	exit 1
fi

def=$1
outdir=cwl

build $def

