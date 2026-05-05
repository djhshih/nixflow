{ lib }:

let
  callDef = lib.callDefWith { inherit lib; };
in
{
  translate = callDef ../tasks/translate.nix {};
  toupper = callDef ../tasks/toupper.nix {};
  caesar = callDef ../tasks/caesar.nix {};
}
