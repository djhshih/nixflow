infile=$1
from_chars=$2
to_chars=$3
outfname=$4

cat ${infile} | tr ${from_chars} ${to_chars} > ${outfname}
