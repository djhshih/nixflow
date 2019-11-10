let
  bns = builtins;
in
rec {
  interpolate = str: vars:
    let
      varNames = (bns.attrNames vars);
      tokens = map (x: "{${x}}") varNames;
      f = var:
        if bns.getAttr var vars == "File"
        then "$(inputs.${var}.path)"
        else "$(inputs.${var})";
      newTokens = map f varNames;
    in
      bns.replaceStrings tokens newTokens str;

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
