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
    sbatch -J {jname} -D {work} -o {out} -e {err} \
      --cpus-per-task {cpu} --mem-per-cpu {memory} -t {duration} \
      {native} --export=ALL \
      {script}
  '';
  kill = "scancel {jid}";
  check = "squeue -j {jid}";
}
