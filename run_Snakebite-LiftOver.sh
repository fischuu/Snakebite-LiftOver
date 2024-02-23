module load snakemake/7.17.1

pipelineFolder="/users/fischerd/git/Snakebite-LiftOver"
projectFolder="/scratch/project_2005222/SNPPanel"

export APPTAINER_TMPDIR="/scratch/project_2005222/tmp"
export APPTAINER_CACHEDIR="/scratch/project_2005222/tmp"

mkdir -p $APPTAINER_TMPDIR

# Create the rulegraph
snakemake -s $pipelineFolder/Snakebite-LiftOver.smk \
          --configfile $projectFolder/Snakebite-LiftOver_config.yaml \
          --rulegraph | dot -T png > $projectFolder/workflow.png

snakemake -s $pipelineFolder/Snakebite-LiftOver.smk \
          -j 300 \
          --use-singularity \
          --singularity-args "-B /scratch:/scratch,/users" \
          --configfile $projectFolder/Snakebite-LiftOver_config.yaml \
          --latency-wait 60 \
          --cluster-config $projectFolder/Snakebite-LiftOver_server-config.yaml \
          --cluster "sbatch -t {cluster.time} --account={cluster.account} --gres=nvme:{cluster.nvme} --job-name={cluster.job-name} --tasks-per-node={cluster.ntasks} --cpus-per-task={cluster.cpus-per-task} --mem-per-cpu={cluster.mem-per-cpu} -p {cluster.partition} -D {cluster.working-directory}" \
          --scheduler greedy \
	        --cluster-cancel scancel \
          -p $@
