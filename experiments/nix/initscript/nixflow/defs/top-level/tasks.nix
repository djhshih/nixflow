{ lib }:

let
  callDef = lib.callDefWith { inherit lib; };
in
{
  toupper = callDef ../tasks/toupper.nix {};

  caesar = callDef ../tasks/caesar.nix {};
}
