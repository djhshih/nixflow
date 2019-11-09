{ lib, tasks }:

let
  callDef = lib.callDefWith ({ inherit lib; } // tasks);
in
{
  cipher = callDef ../workflows/cipher.nix {};
}
