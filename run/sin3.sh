#!/bin/bash

if command -v gdate >/dev/null 2>&1; then
    DATE_CMD="gdate"  # macOS with GNU coreutils installed
else
    DATE_CMD="date"   # Linux or GNU coreutils already default
fi

usage() {
    echo "Usage: $0 -s <sparql> -d <data> -m <mode>(bwd|fwd) [-q <query>] [-v] [-r <result>]"
    echo
    echo "Parameters:"
    echo "  -s <sparql>   Path to SPARQL query file"
    echo "  -d <data>     Path(s) to Turtle data file(s), comma-separated"
    echo "  -m <mode>     Mode: 'bwd' (backward) or 'fwd' (forward)"
    echo "  -q <query>    Optional query file for execution in bwd mode"
    echo "  -v            Enable verbose output"
    echo "  -r <result>   Path to store results (default: res/results.n3)"
    exit 1
}

# Show usage if no arguments
if [[ $# -eq 0 ]]; then
    usage
fi

while getopts s:d:m:q:vr: option; do 
    case "${option}" in
        s) sparql=${OPTARG} ;;
        d) data=${OPTARG} ;;
        m) mode=${OPTARG} ;;
        q) query=${OPTARG} ;;
        v) verbose="true" ;;
        r) result=${OPTARG} ;;
        *) usage ;;
    esac
done

if [[ -z $sparql || -z $data || -z $mode ]]; then
    echo "Error: Missing required parameter(s)."
    usage
fi

if [[ "$mode" != "bwd" && "$mode" != "fwd" ]]; then
    echo "Error: Invalid mode '$mode'. Must be 'bwd' or 'fwd'."
    usage
fi

spin_file="tmp/query.spin"
if [[ $verbose == "true" ]]; then
    echo -e "\n> getting spin <"
fi
time_gen_spin=$( TIMEFORMAT="%R"; { time { java -jar sparql2spin.jar -sparql "$sparql" > "$spin_file"; } } 2>&1 )
if [[ $verbose == "true" ]]; then
    echo -e "(stored at $spin_file)"
fi

n3_file="tmp/n3query.n3"
n3_stderr="tmp/n3query-output.txt"
cmd="eye $spin_file code/aux.n3 --query code/query-$mode.n3 --nope --quantify https://eyereasoner.github.io/.well-known/genid/"
if [[ $verbose == "true" ]]; then
    echo -e "\n> getting n3 rules <"
    echo -e "$cmd"
fi
time_gen_n3=$( TIMEFORMAT="%R"; { time { eval "$cmd" > "$n3_file" 2>"$n3_stderr"; } } 2>&1 )
if [[ $verbose == "true" ]]; then
    echo -e "(stored at $n3_file)"
fi

sed -i'' -e 's|rdf:first|rdf:f1rst|g' "$n3_file"
sed -i'' -e 's|rdf:rest|rdf:r3st|g' "$n3_file"

if [[ -z $result ]]; then
    result="res/results.n3"
fi
if [[ $verbose == "true" ]]; then
    echo -e "\n> executing n3 <"
fi

load_cmd=""
IFS=',' read -ra datas <<< "$data"
for d in "${datas[@]}"; do
    load_cmd="$load_cmd --turtle $d"
done
unset IFS

start=$($DATE_CMD +%s%N)
if [[ $mode == "bwd" ]]; then
    cmd="eye code/runtime.n3 $n3_file $load_cmd --query $query --nope"
else
    cmd="eye code/runtime.n3 $n3_file $load_cmd --pass-only-new --nope"
fi
if [[ $verbose == "true" ]]; then
    echo -e "$cmd"
fi
error=$( { eval "$cmd" > "$result"; } 2>&1 )
end=$($DATE_CMD +%s%N)
time_exec_total=$(bc -l <<< "scale = 2; ($end-$start)/1000000000")

if [[ $verbose == "true" ]]; then
    echo -e "(stored results at $result)"
fi

time_rx='.*starting [^ ]+ \[msec cputime\] ([^ ]+) \[msec walltime\].*networking [^ ]+ \[msec cputime\] ([^ ]+) \[msec walltime\].*reasoning [^ ]+ \[msec cputime\] ([^ ]+) \[msec walltime\]'
[[ $error =~ $time_rx ]]
run_strt_time=${BASH_REMATCH[1]}
run_netw_time=${BASH_REMATCH[2]}
run_reas_time=${BASH_REMATCH[3]}

run_strt_time=$(bc -l <<< "scale = 2; $run_strt_time/1000")
run_netw_time=$(bc -l <<< "scale = 2; $run_netw_time/1000")
run_reas_time=$(bc -l <<< "scale = 2; $run_reas_time/1000")

echo -e "\ntime_gen_spin,time_gen_n3,run_strt_time,run_netw_time,run_reas_time,time_exec_total"
echo -e "$time_gen_spin,$time_gen_n3,$run_strt_time,$run_netw_time,$run_reas_time,$time_exec_total"

# if [[ $verbose == "true" ]]; then
#     echo -e "\nload data: $run_netw_time s\ngenerate spin: $time_gen_spin s\ngenerate n3: $time_gen_n3 s\ntotal: $time_exec_total s"
# fi
