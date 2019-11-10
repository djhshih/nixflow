rec {
  runtime = {
    # required number of cores
    cpu = 1;
    # required RAM in MiB
    memory = 1024;
    # time duration limit in minutes
    duration = 120;
    # native specifications
    native = "";
  };
  submit = ''
    qsub -N {jname} -wd {work} -o {out} -e {err} \
      -pe smp {cpu} -l mem_free={memory}M -l h_vmem={memory}M -l h_rt={duration} \
      {native} -V \
      {script}
  '';
  kill = "qdel {jid}";
  check = "qstat -f {jid}";
}
