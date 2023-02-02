{ lib }:

lib.mkTask {
  name = "caesar";
  inputs = {
    infile = "File";
    outfname = "string";
  };
  outputs = {
    outfile = ["File" "{outfname}"];
  };
  command = ''
    cat {infile} |
    tr A-Z N-ZA-M > {outfname}
  '';
  runtime = {
    cpu = 1;
    memory = 64;
    disk = 1;
    duration = 60;
  };
}
