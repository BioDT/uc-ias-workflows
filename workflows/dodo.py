from data.chelsa import download_data, geotiff_to_netcdf, feedback


def task_feedback():
    """Feedbackloop CHELSA """
    return {
        "actions": [feedback()]
    }

def task_download_chelsa():
    """Download CHELSA data"""
    return {
        "actions": [download_data("../references/chelsa/test.txt", "../datasets/raw/chelsa")]
    }


#TODO: Compare the raw datasets to the previos dataset to check for WHAT has changed

def task_process_chelsa():
    """Process CHELSA .tif files to NetCDF4"""
    return{
        "action":[geotiff_to_netcdf("../datasets/raw/chelsa/", "../datasets/processed/chelsa/2-resmpled_CHELSA_bio1-19.nc")]
    }
