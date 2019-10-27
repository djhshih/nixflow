declare -xp 
cat ${infile} | tr ${from_chars} ${to_chars} > ${outfname}
