#!/bin/bash

set -euo pipefail

if [[ $# < 1 ]]; then
	nix-instantiate --eval --json --strict --expr \
		"let ws = import ./workflows.nix; in builtins.attrNames ws" |
		jq -r '.[]'
else
	nix-instantiate --eval --json --strict --expr \
		"let ws = import ./workflows.nix; in ws.$1.cwl" |
		jq .
fi
