import logging

logger = logging
#TODO: add SMTP to the logger
logger.basicConfig(format='%(asctime)s - %(name)s - %(lineno)d -  %(message)s', filename='../logs/workflows.log', datefmt='%d-%b-%y %H:%M:%S', level=logging.INFO)