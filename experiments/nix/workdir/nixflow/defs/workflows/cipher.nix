{ lib, toupper, caesar }:

lib.mkWorkflow {
  name = "cipher";

  # TODO populate inputs automatically by searching
  #      for unfulfilled inputs to tasks
  inputs = {
    infile = "File";
    toupper_outfname = "string";
    caesar_outfname = "string";
    caesar_caesar_outfname = "string";
  };

  outputs = {
    encrypted = ["File" "caesar.outfile"];
    decrypted = ["File" "caesar2.outfile"];
  };

  depends = [ toupper caesar ];

  # specify variable bindings from one task to another
  steps = {
    toupper = {
      task = "toupper";
      inputs = {
        infile = "infile";
        outfname = "toupper_outfname";
      };
    };
    caesar = {
      task = "caesar";
      inputs = {
        infile = "toupper.outfile";
        outfname = "caesar_outfname";
      };
    };
    caesar2 = {
      task = "caesar";
      inputs = {
        infile = "caesar.outfile";
        outfname = "caesar_caesar_outfname";
      };
    };
  };
}
