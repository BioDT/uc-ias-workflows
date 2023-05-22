# -*- coding: utf-8 -*-
import logging
from pathlib import Path
import wget
import glob
import numpy as np
import pyproj
import netCDF4
import os
import xarray as xr
import rioxarray as rxr
import rasterio
from rasterio.enums import Resampling



def download_data(path_to_download_list, output_dir):
    """Downloads the CHELSA yearly data from the C3S FTP server.

    :param path_to_download_list: The path for the txt file with CHELSA data url list.
    :param: output_dir: The path where data files are downloaded to.

    Returns:
        None
    """
    logger = logging.getLogger(__name__)
    logger.info("downloading CHELSA data...")
    # Download the CHELSA data from the C3S FTP server
    with open(path_to_download_list) as url_list:
        for line in url_list:
            response = wget.download(line, out=output_dir)
            logger.info("downlaoded CHELSA data from {}".format(response))

def geotiff_to_netcdf(directory_path, output_file_path):
    
    # Define the bounding box for Europe
    europe_bounds = [-25, 35, 45, 75]

    # Iterate over all files in the directory
    for filename in os.listdir(directory_path):
        print("---------------------------------------------")
        output=filename.rsplit("_V")
        # Check if the file is a GeoTIFF
        if filename.endswith(".tif"):
            print(f"Reading {filename}...")

            # Open the GeoTIFF using rioxarray
            data = rxr.open_rasterio(os.path.join(directory_path, filename))
            print(f"Processing {filename} as xarray...")
           
            # Slice the data for Europe
            data_europe = data.rio.clip_box(*europe_bounds)
            print(f"Clipping {filename} for Europe...")

            # Reproject the data to ESPG-3530
            data_europe = data_europe.rio.reproject("EPSG:3035")
            print(f"Reprojecting {filename} as ESPG:3035...")
            
            # Resample data to 10x10 KM grids based on https://corteva.github.io/rioxarray/stable/examples/resampling.html
            downscale_factor = 1/10
            new_width = data_europe.rio.width * downscale_factor
            new_height = data_europe.rio.height * downscale_factor
            data_resampled= data_europe.rio.reproject(
                data_europe.rio.crs,
                shape=(new_height, new_width),
                resampling=Resampling.average,)
            print(f"Resamplimg {filename} using average algorithm...")

            # Convert to xarray DataArray to xrray Dataset
            dsout=data_resampled.to_dataset(name=f"{output[0]}")

            print(f"Final dataset for {output[0]}: ")
            print(dsout)

            # Convert the data to a netCDF4 file using xarray
            dsout.to_netcdf(
                output_file_path, 
                mode="a",
                group="/",
                format="NETCDF4"
            )
            print(f"{filename} processed and saved to {output_file_path} as {output[0]}")