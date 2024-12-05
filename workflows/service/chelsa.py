from clusterjob import Job
import xarray as xr
import os
import numpy as np
from natsort import natsorted
import datetime


account = "project_465000915"


# TODO Convert paths to environment variables


def convert2nc(input_paths, output_dir):
    """
    Converts netCDF files to a merged netCDF file.

    Args:
        input_paths (str): The directory path where the netCDF files are located.
        output_dir (str): The directory path where the merged netCDF file will be saved.

    Returns:
        None
    """
    # Define the directory path where the netCDF files are located
    directory = input_paths

    # Get a list of all netCDF files in the directory
    files = natsorted([file for file in os.listdir(directory) if file.endswith(".nc")])

    # Create an empty dictionary to store the datasets
    datasets_m = {}
    datasets_c = {}

    # Iterate over each netCDF file
    for file in files:
        # Open the netCDF file using xarray
        ds = xr.open_dataset(os.path.join(directory, file))
        variables = list(ds.data_vars)

        if (
            "ClimModel" in ds[variables[0]].attrs
            and "ClimScenario" in ds[variables[0]].attrs
            and "TimePeriod" in ds[variables[0]].attrs
        ):
            # Get the unique ClimModel and ClimScenario attributes
            clim_model = ds[variables[0]].attrs["ClimModel"]
            clim_scenario = ds[variables[0]].attrs["ClimScenario"]
            time_period = ds[variables[0]].attrs["TimePeriod"]
            # ds[variables[0]].attrs["lambert_azimuthal_equal_area"]
            # ds[variables[0]].attrs["LongName"] = ds[variables[0]].attrs["Long_name"]
            # ds[variables[0]].attrs.pop("Long_name", None)
            # ds[variables[0]].attrs["Var"] = ds.attrs["Var"]
            ds[variables[0]].attrs["Explanation"] = ds[variables[0]].attrs[
                "explanation"
            ]
            del ds[variables[0]].attrs["explanation"]
            ds.attrs["ClimModel"] = clim_model
            ds.attrs["ClimScenario"] = clim_scenario
            ds.attrs["TimePeriod"] = time_period
            # ds.attrs['crs_wkt'] = str(ds[variables[1]].attrs["crs_wkt"])
            # ds.attrs['spatial_ref'] = str(ds[variables[1]].attrs["spatial_ref"])
            # ds.attrs['proj4'] = str(ds[variables[1]].attrs["proj4"])
            # ds.attrs['epsg_code'] = str(ds[variables[1]].attrs["epsg_code"])
            # ds.attrs['geotransform'] = str(ds[variables[1]].attrs["geotransform"])
            # ds.attrs['crs'] = ds[variables[1]].attrs["crs_wkt"]
            # ds = ds.rename({variables[0]: ds.attrs["Var"]})

            # Create a key for the dataset dictionary using the ClimModel and ClimScenario attributes
            key = f"{clim_model}_{clim_scenario}_{time_period}"

            # Store the dataset in the dictionary
            if key not in datasets_m:
                datasets_m[key] = []
            datasets_m[key].append(ds)
        # Get the unique ClimModel and ClimScenario attributes
        else:
            datasets_c["Current"] = ds

    # Iterate over the datasets dictionary and merge the datasets
    for key, ds in datasets_m.items():
        # Combine all datasets into a single dataset
        merged_ds = xr.merge(ds)
        # Delete unnecessary attributes
        del merged_ds.attrs["Var"]
        del merged_ds.attrs["Long_name"]
        del merged_ds.attrs["unit"]
        del merged_ds.attrs["explanation"]
        del merged_ds.attrs["created_by"]
        del merged_ds.attrs["date"]
        # Add metadata to the merged dataset
        merged_ds.attrs["Organization"] = (
            "Helmholtz Centre for Environmental Research (UFZ)"
        )
        merged_ds.attrs["Project"] = "Biodiversity Digital Twin (BioDT)"
        merged_ds.attrs["Date"] = str(datetime.datetime.now())
        merged_ds.attrs["EPSG"] = "3035"
        # Save the merged dataset to a netCDF file
        merged_ds.encoding.update({"zlib": True, "complevel": 9})
        merged_ds.to_netcdf(f"{output_dir}/{key}.nc")
    return True


def job_vSensor(input_paths):
    """Executes the workflow."""
    vSensor = f"python3 -c 'from feedbackloop.chelsa import vSensor; vSensor(input_paths={input_paths})'"
    job = JobScript(
        shebang="#!/bin/bash",
        root_dir=os.environ["ROOT_DIR"],
        preamble=[
            "module load cray-python",
            "source /pfs/lustrep3/users/khantaim/iasdt-workflows/iasdt-pyenv/bin/activate",
        ],
        body=vSensor,
        backend="slurm",
        jobname="CHELSA_vSensor",
        time="00:05:00",
        nodes=1,
        threads=1,
        mem=4000,
        account=account,
        partition="standard",
    )
    # Submit the job to SLURM
    ar = job.submit()

    print("CHELSA vSensor job submitted successfully!")

    ar.wait()  # Wait for the job to complete

    job_state = ar.sucessful()

    # Check the state of the job and return the appropriate message
    if job_state == False:
        print("CHELSA vSensor job failed!")
        return False

    if job_state == True:
        print("CHELSA vSensor job done!")
        return True


def job_intaker(download_list, output_dir):
    """Submits the CHELSA intaker."""
    intaker = f"python3 -c 'from feedbackloop.chelsa import intaker; intaker(path_to_download_list={download_list}, output_dir={output_dir})'"
    job = JobScript(
        shebang="#!/bin/bash",
        backend="slurm",
        root_dir=os.environ["ROOT_DIR"],
        preamble=[
            "module load cray-python",
            "source /pfs/lustrep3/users/khantaim/iasdt-workflows/iasdt-pyenv/bin/activate",
        ],
        body=intaker,
        backend="slurm",
        jobname="CHELSA_intaker",
        time="02:00:00",
        nodes=2,
        threads=4,
        mem=16000,
        account=account,
        partition="standard",
    )
    # Submit the job to SLURM
    ar = job.submit()

    print("CHELSA intaker job submitted successfully!")

    ar.wait()  # Wait for the job to complete

    job_state = ar.sucessful()

    # Check the state of the job and return the appropriate message
    if job_state == False:
        print("CHELSA intaker job failed!")
        return False

    if job_state == True:
        print("CHELSA intaker job done!")
        return True


def job_processor(script_path, logs_dir):
    """
    Create and submit a SLURM job directly using clusterjob for the CHELSA processing task.
    """

    # Define a script

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
    # Define the SLURM job
    job = Job(
        backend="slurm",
        jobname="CHELSA_process",
        account=account,
        root_dir=os.environ["ROOT_DIR"],
        time="01:00:00",
        partition="standard",
        mem="200G",
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
        exports=["CRAYBLAS_WARN=0"],
        script=script,
    )

    # Submit the job to SLURM
    ar = job.submit()

    print("CHELSA processing job submitted successfully!")

    ar.wait()  # Wait for the job to complete

    job_state = ar.sucessful()

    # Check the state of the job and return the appropriate message
    if job_state == False:
        print("CHELSA processing job failed!")
        return False

    if job_state == True:
        print("CHELSA processing job done!")
        return True
