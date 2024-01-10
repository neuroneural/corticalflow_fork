#!/bin/bash

#define nodes
nodes=("arctrdagn001" "arctrdagn002" "arctrdagn003" "arctrdagn004" "arctrdagn005" "arctrdagn006" "arctrdagn007" "arctrdagn008" "arctrdagn009" "arctrdagn010" "arctrdagn014" "arctrdagn016" "arctrdagn017")
#nodes=("arctrdagn002" "arctrdagn003" "arctrdagn004" "arctrdagn005" "arctrdagn006" "arctrdagn007" "arctrdagn008" "arctrdagn009" "arctrdagn010" "arctrdagn014" "arctrdagn016" "arctrdagn017")
#nl=()
for (( i = 1; i <= 100; i++ )); do
	    # Code to be executed in each iteration
	
	
for node in "${nodes[@]}"
do
	    echo $node
            # Check if the node is available
		    if scontrol show node="$node" | grep -q "State=IDLE"
                        then
                                # If the node is available, submit the job to that node and exit the loop
				#nl+=("$node")
				sbatch --nodelist="${node}" bm.submitpredictlhall.sbatch	
				echo "node was free " $node
                        break
                fi
done
sleep 20
done
#nodelist=$(IFS=','; echo "${nl[@]}")
#echo "nodes " "${nl[@]}"
#echo $nodelist
#echo "tasks" ${#nl[@]}
#sbatch --nodelist="${nodelist}" --tasks-per-node=1 --ntasks=${#nl[@]} bm.submitpredictlhall.sbatch
