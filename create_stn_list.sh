pushd ./output/ 1>&2
ls *.smet | awk 'BEGIN {n=0; print "[INPUT]"} {n++; printf "STATION%d = %s\n", n, $0}'
popd 1>&2
