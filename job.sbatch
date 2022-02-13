#!/bin/bash

#
# For SLURM
#
#SBATCH --nodes=1				#	Number of requested nodes per task
#SBATCH --account=xxxxxxxx			#	Account
#SBATCH --time=05:00:00				#	Max wall time
#SBATCH --qos=normal				#	Specify normal QOS
#SBATCH --partition=shas			#	Specify Summit haswell nodes
#SBATCH --ntasks=1				#	Number of tasks per job
#SBATCH --array=1-18				#	Set array

#SBATCH --job-name=greenland_downscaling	#	Job submission name
#SBATCH --output=./%x.%j.out			#	Output file name with Job ID
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email@example.com

ml gcc; ml proj; ml cmake
#
# Check for job arrays:
#
if [ -n "${SLURM_ARRAY_TASK_ID}" ]; then
	command1=$(sed -n ${SLURM_ARRAY_TASK_ID}p to_exec.lst)
elif [ -n "${PBS_ARRAY_INDEX}" ]; then
	command1=$(sed -n ${PBS_ARRAY_INDEX}p to_exec.lst)
else
	command1=""
fi

#
# Execute job
#
if [ -n "${command1}" ]; then
	# Case using job arrays with a job manager
	eval ${command1}
else
	# Other cases
	bash to_exec.lst
fi
