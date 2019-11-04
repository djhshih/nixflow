let
	lib = import ../../lib;
	tasks = import ./tasks.nix { inherit lib; };
	workflows = import ./workflows.nix { inherit lib tasks; };
in
{
	inherit tasks workflows;
}
