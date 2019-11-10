rec {
  runtime = {
    # required number of cores
    cpu = 1;
    # required RAM in MiB (need to convert to KiB and convert to total memory)
    memory = 1024;
    # time duration limit in minutes
    duration = 120;
    # native specifications
    native = "";
  };
  submit = ''
    bsub -J {jname} -cwd {work} -o {out} -e {err} \
      -p {cpu} -M {memory} -W {duration} \
      {native} -env all \
      {script}
  '';
  kill = "bkill {jid}";
  check = "bjobs -j {jid}";
}
