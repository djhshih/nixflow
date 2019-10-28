#!/bin/bash

set -euo pipefail

if [[ $# < 1 ]]; then
	nix-instantiate --eval --json --strict --expr \
		"let ts = import ./default.nix; in builtins.attrNames ts" |
		jq -r '.[]'
else
	nix-instantiate --eval --json --strict --expr \
		"let ts = import ./default.nix; in ts.$1.cwl" |
		jq .
fi
