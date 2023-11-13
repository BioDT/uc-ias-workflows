# -*- coding: utf-8 -*-
import logging, sys, glob, os, json, hashlib, time
from pathlib import Path
import wget
import numpy as np
import pyproj
import netCDF4
import xarray as xr
import rioxarray as rxr
import rasterio
from rasterio.enums import Resampling
import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
import s3fs
import deepdiff



def vSensor(input_paths):
    """Senses new CHELSA data from their S3 server.

    :param input_path: The path for S3 CHELSA data directory where to check new data.

    Returns:
        diff_json:JSON Difference between the previous and new metadata.
    """
    logger = logging.getLogger(__name__)
    logger.info("checking CHELSA metadata...")
    # Check for new CHELSA data
    try: 
        #TODO: Change URL string to environment variable
        s3 = s3fs.S3FileSystem(anon=True, endpoint_url="https://os.zhdk.cloud.switch.ch/")
        for x in input_paths:
            file_list = s3.ls(path=f"{x}")
            new_log=[]
            logger.info("comparing CHELSA metadata...")
            for i in file_list:
                checksum = s3.metadata(path=f"{i}", refresh=False)
                #print(checksum)
                info = s3.info(path=f"{i}")
                checksum.update(info)
                checksum["LastModified"]=checksum["LastModified"].strftime("%Y-%m-%d %H:%M:%S")
                #append new metadata to the metadata file
                new_log.append(checksum)
        list_of_files = glob.glob('logs/feedback/chelsa/*.json') # * means all if need specific format then *.csv
        latest_file = max(list_of_files, key=os.path.getctime)
        with open(f"logs/feedback/chelsa/{time.time()}.json", "w") as f:
            json.dump(new_log, f)
        print(f"new CHELSA log saved to {f.name}")
    except:
        print("Error:", sys.exc_info()[0])
        return False

    # Compare the new metadata with the previous metadata using DIFF
    try:
        with open(f"logs/feedback/chelsa/{latest_file}", "w") as f:
            #logs = json.load(f)
            #TODO: Validate the difference between the previous and new metadata
            diff = deepdiff.DeepDiff(f, new_log, view='tree')
            diff_json = json.dumps(diff.to_json(), indent=2)
            with open(f"logs/diff/chelsa/{time.time()}.json", "w") as d:
                json.dump(json.loads(diff_json), d)
                print(f"new CHELSA diff saved to {d.name}")
            return diff_json
    except:
        print("Error:", sys.exc_info()[0])
        return False
    
def intaker(path_to_download_list, output_dir):
    """Downloads the CHELSA yearly data from the C3S S3 server.

    :param path_to_download_list: The path for the txt file with CHELSA data url list.
    :param: output_dir: The path where data files are downloaded to.

    Returns:
        None
    """
    logger = logging.getLogger(__name__)
    logger.info("downloading CHELSA data...")
    # Download the CHELSA data from the C3S S3 server
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

            """ 
def feedback():
    # Helper tool to print linted json objects
    def print_json(json_obj: str):
        json_formatted_str = json.dumps(json_obj, indent=2)
        print(json_formatted_str)
    # Configure Selenium
    chrome_options = webdriver.ChromeOptions()
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--no-sandbox')
    chrome_options.headless = True

    # Load Selenium Chromium driver
    wd = webdriver.Chrome('chromedriver',options=chrome_options)

    # Hook to Chelsa S3 bucket /GLOBAL/
    # wd.get("https://envicloud.wsl.ch/#/?prefix=chelsa%2Fchelsa_V2%2FGLOBAL%2F")

    # Hook to Chelsa S3 bucket /GLOBAL/climatologies/1981-2010/bio/
    wd.get("https://envicloud.wsl.ch/#/?bucket=https%3A%2F%2Fos.zhdk.cloud.switch.ch%2Fenvicloud%2F&prefix=chelsa%2Fchelsa_V2%2FGLOBAL%2Fclimatologies%2F1981-2010%2Fbio%2F")
    wd.title
    # Identify element
    l = wd.find_element("xpath", "/html/body/div/div/main/div/div/div/div[1]/div/div[2]/div/div/div/button[1]")

    # Perform click
    l.click()
    # Get innerHTML for ../bio/ elements
    data = wd.find_element("xpath", "/html/body/div/div/main/div/div/div/div[1]/div/div[2]/div/div/div[2]")
    print(data.get_attribute('innerHTML'))

    # from selenium.webdriver.common.by import By

    web_data = wd.find_element(By.CSS_SELECTOR, "#app > div.v-application--wrap > main > div > div > div > div.col-sm-9.col-12 > div > div.v-card__text > div > div > div.v-treeview-node__children")
    metadata = web_data.text.split("\n")

    # Split metadata into groups
    groups = [metadata[i:i+3] for i in range(0, len(metadata), 3)]

    # Create a dataframe from the scraped metadata sorted by datetime
    df = pd.DataFrame(groups, columns=['name', 'size', 'date'])
    df['date'] = pd.to_datetime(df['date'])
    df = df.sort_values("date", ascending=False)

    # Generate MD5 hash for each row of a dataframe
    def hash_row(row):

        row_str = ''.join([str(val) for val in row])
        row_hash = hashlib.md5(row_str.encode()).hexdigest()

        return row_hash

    df['hash'] = df.apply(hash_row, axis=1)
    #TODO: Add date/time to the JSON filename
    df.to_json("logs/feedbackloops/chelsa_logs.json")
      """