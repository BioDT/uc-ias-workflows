from clusterjob import JobScript
from feedbackloop.chelsa import vSensor, intaker


def job_vSensor(input_paths):
    """Executes the workflow."""
    vSensor = f"python3 -c 'from feedbackloop.chelsa import vSensor; vSensor(input_paths={input_paths})'"
    jobscript = JobScript(
        shebang="#!/bin/bash",
        preamble=[
            "module load Python/3.8.2-GCCcore-9.3.0",
            "pip install -r requirements.txt",
            "cd workflows",
        ],
        body=vSensor,
        backend="slurm",
        jobname="chelsa_vSensor",
        time="00:05:00",
        nodes=1,
        threads=1,
        mem=4000,
    )


def job_intaker(download_list, output_dir):
    """Submits the CHELSA intaker."""
    intaker = f"python3 -c 'from feedbackloop.chelsa import intaker; intaker(path_to_download_list={download_list}, output_dir={output_dir})'"
    jobscript = JobScript(
        shebang="#!/bin/bash",
        preamble=[
            "module load Python/3.8.2-GCCcore-9.3.0",
        ],
        body=intaker,
        backend="slurm",
        jobname="chelsa_intaker",
        time="02:00:00",
        nodes=2,
        threads=4,
        mem=16000,
    )
