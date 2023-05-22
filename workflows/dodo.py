from data.chelsa import download_data, geotiff_to_netcdf


def task_download_chelsa():
    """Download CHELSA data"""
    return {
        "actions": [download_data("../references/chelsa/test.txt", "../datasets/raw/chelsa")]
    }

def task_process_chelsa():
    """Process CHELSA .tif files to NetCDF4"""
    return{
        "action":[geotiff_to_netcdf("../datasets/raw/chelsa/", "../datasets/processed/chelsa/2-resmpled_CHELSA_bio1-19.nc")]
    }