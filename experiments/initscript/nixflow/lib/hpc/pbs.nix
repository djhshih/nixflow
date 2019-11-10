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
    qsub -N {jname} -d {work} -o {out} -e {err} \
      -l ppn={cpu} -l pvmem={memory}mb -l pmem={memory}mb -l walltime={duration} \
      {native} -V \
      {script}
  '';
  kill = "qdel {jid}";
  check = "qstat -f {jid}";
}
