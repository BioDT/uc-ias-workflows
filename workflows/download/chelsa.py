# -*- coding: utf-8 -*-
import logging
from pathlib import Path
import wget


def download_data(path_to_download_list, path_to_download_to):
    """Downloads the CHELSA yearly data from the C3S FTP server.

    :param path_to_download_list: The path for the txt file with CHELSA data url list.
    :param: path_to_download_to: The path where data files are downloaded to.
    
    Returns:
        None
    """
    logger = logging.getLogger(__name__)
    logger.info("downloading CHELSA data...")
    # Download the CHELSA data from the C3S FTP server
    with open(path_to_download_list) as url_list:
        for line in url_list:
            response = wget.download(line, out=path_to_download_to)
            logger.info("downlaoded CHELSA data from {}".format(response))
