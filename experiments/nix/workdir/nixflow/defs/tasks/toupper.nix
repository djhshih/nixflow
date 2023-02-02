{ lib }:

lib.mkTask {
  name = "toupper";
  inputs = {
    infile = "File";
    outfname = "string";
  };
  outputs = {
    outfile = ["File" "{outfname}"];
  };
  command = ''
    cat {infile} |
    tr a-z A-Z > {outfname}
  '';
  runtime = {
    cpu = 1;
    memory = 64;
    disk = 1;
    duration = 60;
  };
}
