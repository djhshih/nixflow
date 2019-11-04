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

instantiate="nix-instantiate --eval --json --strict --expr"
main="(import ./nixflow/defs/top-level)"

if [[ $# < 2 ]]; then
	$instantiate "builtins.attrNames ${main}.${type}s" |
		jq -r '.[]'
else
	$instantiate "${main}.${type}s.$2.cwl" |
		jq .
fi
