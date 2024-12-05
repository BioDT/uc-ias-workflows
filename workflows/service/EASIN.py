from clusterjob import Job
import os

account = "project_465000915"


# Function to create and submit a SLURM job directly using clusterjob
def job_process(script_path, logs_dir):
    """
    Create and submit a SLURM job directly using clusterjob for the EASIN task.
    """
    # Define script
    script = f"""
    echo "Start time = $(date)"
    echo "Submitting directory = "$SLURM_SUBMIT_DIR
    echo "working directory = "$PWD
    echo "Project name = "$SLURM_JOB_ACCOUNT
    echo "Job id = "$SLURM_JOB_ID
    echo "Job name = "$SLURM_JOB_NAME
    echo "memory per CPU = "$SLURM_MEM_PER_CPU
    echo "Node running the job script = "$SLURMD_NODENAME
    echo "Process ID of the process started for the task = "$SLURM_TASK_PID
    echo "Dependency = "$SLURM_JOB_DEPENDENCY
    echo "Number of nodes assigned to a job = "$SLURM_NNODES
    echo "Number of tasks requested by the job = "$SLURM_NTASKS
    echo "Number of cpus per task = "$SLURM_CPUS_PER_TASK

    module load LUMI/23.09 partition/L GDAL fontconfig FriBidi HarfBuzz git UDUNITS libsodium GSL libarchive/3.6.2-cpeGNU-23.09 R

    export CRAYBLAS_WARN=0

    Rscript --vanilla {script_path}

    echo "End of program at `date`"
    """

    # Define the SLURM job using Job
    job = Job(
        scheduler="slurm",  # Specify SLURM as the scheduler
        jobname="EASIN",
        root_dir=os.environ["ROOT_DIR"],
        account=account,
        time="01:30:00",
        partition="standard",
        mem="100G",
        nodes=1,
        ntasks=1,
        output=f"{logs_dir}/%x-%A-%a.out",
        error=f"{logs_dir}/%x-%A-%a.err",
        modules=[
            "LUMI/23.09",
            "partition/L",
            "GDAL",
            "fontconfig",
            "FriBidi",
            "HarfBuzz",
            "git",
            "UDUNITS",
            "libsodium",
            "GSL",
            "libarchive/3.6.2-cpeGNU-23.09",
            "R",
        ],
        export=["CRAYBLAS_WARN=0"],
        script=script,
    )

    # Submit the job to SLURM
    ar = job.submit()

    print("EASIN job submitted successfully!")

    ar.wait()  # Wait for the job to complete

    job_state = ar.sucessful()

    # Check the state of the job and return the appropriate message
    if job_state == False:
        print("EASIN job failed!")
        return False

    if job_state == True:
        print("EASIN job done!")
        return True
