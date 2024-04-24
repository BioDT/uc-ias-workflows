from clusterjob import JobScript


#TODO Convert paths to environment variables
def job_vSensor(input_paths):
    """Executes the workflow."""
    vSensor = f"python3 -c 'from feedbackloop.chelsa import vSensor; vSensor(input_paths={input_paths})'"
    jobscript = JobScript(
        
        shebang="#!/bin/bash",
        rootdir="/pfs/lustrep3/users/khantaim/iasdt-workflows/workflows",
        preamble=[
            "module load cray-python",
            "source /pfs/lustrep3/users/khantaim/iasdt-workflows/iasdt-pyenv/bin/activate",
        ],
        body=vSensor,
        backend="slurm",
        jobname="chelsa_vSensor",
        time="00:05:00",
        nodes=1,
        threads=1,
        mem=4000,
        queue="ju-standard",
    )


def job_intaker(download_list, output_dir):
    """Submits the CHELSA intaker."""
    intaker = f"python3 -c 'from feedbackloop.chelsa import intaker; intaker(path_to_download_list={download_list}, output_dir={output_dir})'"
    jobscript = JobScript(
        shebang="#!/bin/bash",
        rootdir="/pfs/lustrep3/users/khantaim/iasdt-workflows/workflows",
        preamble=[
            "module load cray-python",
            "source /pfs/lustrep3/users/khantaim/iasdt-workflows/iasdt-pyenv/bin/activate",
            "cd workflows",
        ],
        body=intaker,
        backend="slurm",
        jobname="chelsa_intaker",
        time="02:00:00",
        nodes=2,
        threads=4,
        mem=16000,
        queue="ju-standard",
    )

