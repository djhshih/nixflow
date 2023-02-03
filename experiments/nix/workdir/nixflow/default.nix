let
  lib = import ./lib/cwl.nix;
  tasks = import ./defs/top-level/tasks.nix { inherit lib; };
  workflows = import ./defs/top-level/workflows.nix { inherit lib tasks; };
  getTypes = builtins.mapAttrs (k: v: v.type);
in
{
  inherit tasks workflows;
  type = getTypes tasks // getTypes workflows;
}
