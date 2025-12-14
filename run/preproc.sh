#!/bin/bash

data=$1
result=$2

mkdir -p tmp

if [[ ! "${data}" =~ \.nt$ ]]; then
    echo -e "> getting n-triples data <"
    time_gen_nt=$( TIMEFORMAT="%R"; { time { java -jar turtle2nt.jar -turtle $data  > $result; } } 2>&1 )
    echo -e "(stored at $result)"
fi
echo -e "> preprocessing n-triples <"
start=$(gdate +%s%N)
sed -i'' -e 's|<http://www.w3.org/1999/02/22-rdf-syntax-ns#first>|<http://www.w3.org/1999/02/22-rdf-syntax-ns#f1rst>|g' $result
sed -i'' -e 's|<http://www.w3.org/1999/02/22-rdf-syntax-ns#rest>|<http://www.w3.org/1999/02/22-rdf-syntax-ns#r3st>|g' $result
end=$(gdate +%s%N)
time_preproc=$(bc -l <<< "scale = 2; ($end-$start)/1000000000")

echo -e "\ngenerate nt: $time_gen_nt s\npreproc: $time_preproc s"