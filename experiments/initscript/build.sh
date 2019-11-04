#!/bin/bash

# Build CWL files.

set -euo pipefail

if [[ $# < 1 ]]; then
	echo "usage $0 <task | workflow> [name]"
	exit 1
fi

type=$1
if [[ "$type" != "task" && "$type" != "workflow" ]]; then
	echo "Input error: we got $type but expect task or workflow"
	exit 1
fi

nix="nix-instantiate --eval --json --strict --expr"
root="(import ./nixflow/defs/top-level)"

if [[ $# < 2 ]]; then
	$nix "builtins.attrNames ${root}.${type}s" | jq -r '.[]'
else
	def=$2

	# build dependencies
	if [[ "$type" == "workflow" ]]; then
		depends=$($nix "map (x: x.name) ${root}.${type}s.${def}.depends" | jq -r '.[]')
		for d in $depends; do
			# TODO write to better location
			out=$d.cwl
			if [[ ! -f $out ]]; then
				echo "Building $d ... "
				$nix "${root}.all.$d.cwl" | jq . > $out
			fi
		done
	fi

	# build target
	echo "Building $def ... "
	# TODO write to better location
	out=${def}.cwl
	$nix "${root}.${type}s.${def}.cwl" | jq . > $out
fi
