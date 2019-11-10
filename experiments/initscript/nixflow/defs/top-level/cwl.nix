let
  lib = import ../../lib/cwl.nix;
  tasks = import ./tasks.nix { inherit lib; };
  workflows = import ./workflows.nix { inherit lib tasks; };
in
{
  inherit tasks workflows;
  all = tasks // workflows;
}
