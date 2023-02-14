# -*- coding: utf-8 -*-
import click
import logging
from pathlib import Path
import urllib.request


""" @click.command()
@click.argument('input_filepath', type=click.Path(exists=True))
@click.argument('output_filepath', type=click.Path()) """




def download_data(path_to_download_list, path_to_download_to):
    """Downloads the CHELSA data from the C3S FTP server.

    Returns:
        None
    """
    logger = logging.getLogger(__name__)
    logger.info("downloading CHELSA data...")
    # Download the CHELSA data from the C3S FTP server
    with open(path_to_download_list) as url_list:
        for line in url_list:
            response = urllib.request.Request(line, path_to_download_to)
            if response.status_code == 200:
                logger.info("downlaoded CHELSA data from {}".format(line))
            else:
                logger.warning("failed to download CHELSA data from {}".format(line))
