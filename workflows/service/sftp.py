from simple_sftp.client import Client
import os

# Read the relavant environment variables in the .env file
ip = os.environ["FTP_SERVER_IP"]
user = os.environ["FTP_LOGIN_USER"]
password = os.environ["FTP_LOGIN_PASSWORD"]
PORT = os.environ["FTP_CONNECT_PORT"]  # not required. default 22

c = Client(ip, user, password)


def upload(remote_path, local_path):
    """
    Uploads a file to a remote server.
    Args:
        remote_path (str): The path on the remote server where the file will be uploaded.
        local_path (str): The path of the local file to be uploaded.
    Returns:
        str: A message indicating the success of the upload.
    """

    c.upload(remote_path, local_path)
    return "SFTP Upload Success"


def download(remote_path, local_path):
    """
    Downloads a file from a remote server to a local path.
    Args:
        remote_path (str): The path to the file on the remote server.
        local_path (str): The path where the file will be saved locally.
    Returns:
        str: A message indicating the download was successful.
    """

    c.download(remote_path, local_path)
    return "SFTP Download Success"
