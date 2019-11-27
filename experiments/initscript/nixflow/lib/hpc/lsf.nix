rec {
  runtime = {
    # required number of cores
    cpu = 1;
    # required RAM in MiB per core
    memory = 1024;
    # time duration limit in minutes
    duration = 120;
    # native specifications
    native = "";
  };
  submit = ''
    bsub -J {jname} -cwd {work} -o {out} -e {err} -env all \
      -n {cpu} -R "usage[mem={memory}]" -W {duration} \
      {native} {script}
  '';
  kill = "bkill {jid}";
  check = "bjobs {jid}";
}
