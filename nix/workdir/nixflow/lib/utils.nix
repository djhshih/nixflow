let
  bns = builtins;
in
rec {
  makeOverridable = f: args0:
    let
      res0 = f args0;
    in
      res0 // { override = args: makeOverridable f (args0 // args); };

  # TODO
  # example of extracting 10 from "10G"
  # builtins.fromJSON (builtins.elemAt (builtins.elemAt (builtins.split
  # "([[:digit:]]+)" "10G") 1) 0)
}
