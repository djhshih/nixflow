#!/bin/bash

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

if [[ $# < 2 ]]; then
	nix-instantiate --eval --json --strict --expr \
		"let d = import ./nixflow/defs/top-level; in builtins.attrNames d.${type}s" |
		jq -r '.[]'
else
	nix-instantiate --eval --json --strict --expr \
		"let d = import ./nixflow/defs/top-level; in d.${type}s.$2.cwl" |
		jq .
fi
