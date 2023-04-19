# -*- coding: utf-8 -*-
import logging
from pathlib import Path
import wget
import glob
import numpy as np
import rasterio
import pyproj
import xarray as xr
from osgeo import osr
from osgeo import gdal
import netCDF4
import os


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


def process_geotifs(input_dir, output_dir):
    """Iterates over geotif files, slices data for Europe and converts the data to equal area projection.

    :param input_dir: Path to folder with raw CHELSA data.
    :param: output_dir: Path for storing out files.

    Returns:
        None
    """
    # Define the EPSG codes for the input and output coordinate systems
    input_epsg = 4326  # WGS84 geographic coordinate system
    output_epsg = 3035  # ETRS89 / LAEA Europe equal area projection

    # Create the output directory if it doesn't already exist
    os.makedirs(output_dir, exist_ok=True)

    # Iterate over the geotif files in the input directory
    for filename in os.listdir(input_dir):
        if filename.endswith(".tif"):
            input_path = os.path.join(input_dir, filename)
            output_path = os.path.join(output_dir, filename)

            # Open the input geotif file
            dataset = gdal.Open(input_path)

            # Get the geotransform and projection information
            geotransform = dataset.GetGeoTransform()
            projection = dataset.GetProjection()

            # Convert the geotransform to a spatial reference object
            srs = osr.SpatialReference()
            srs.ImportFromWkt(projection)

            # Create a new spatial reference object for the output coordinate system
            output_srs = osr.SpatialReference()
            output_srs.ImportFromEPSG(output_epsg)

            # Create a transformation object to convert from the input to output coordinate system
            transform = osr.CoordinateTransformation(srs, output_srs)

            # Read the input geotif data
            data = dataset.ReadAsArray()

            # Compute the indices for the Europe region
            x_size = dataset.RasterXSize
            y_size = dataset.RasterYSize
            x_offset = int(((-25.0 - geotransform[0]) / geotransform[1]).round())
            y_offset = int(((72.0 - geotransform[3]) / geotransform[5]).round())
            x_count = (
                int(((-10.0 - geotransform[0]) / geotransform[1]).round()) - x_offset
            )
            y_count = (
                int(((35.0 - geotransform[3]) / geotransform[5]).round()) - y_offset
            )

            # Slice the data for the Europe region
            data = data[y_offset : y_offset + y_count, x_offset : x_offset + x_count]

            # Convert the data to the output coordinate system
            x_res = (geotransform[1] * x_count) / 1000.0
            y_res = (geotransform[5] * y_count) / 1000.0
            output_geotransform = (
                geotransform[0] + x_offset * geotransform[1],
                x_res,
                0.0,
                geotransform[3] + y_offset * geotransform[5],
                0.0,
                -y_res,
            )
            output_data = np.empty((y_count, x_count), dtype=np.float32)
            output_data[:] = np.nan
            output_dataset = gdal.GetDriverByName("GTiff").Create(
                output_path, x_count, y_count, 1, gdal.GDT_Float32
            )
            output_dataset.SetGeoTransform(output_geotransform)
            output_dataset.SetProjection(output_srs.ExportToWkt())
            gdal.ReprojectImage(
                dataset, output_dataset, projection, output_srs.ExportToWkt(), gdal
            )
