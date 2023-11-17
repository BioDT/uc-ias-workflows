import logging

logger = logging
#TODO: add SMTP to the logger
logger.basicConfig(format='%(asctime)s - %(message)s', filename='../logs/workflows.log', datefmt='%d-%b-%y %H:%M:%S')