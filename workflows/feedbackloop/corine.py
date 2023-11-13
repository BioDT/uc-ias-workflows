# CLMS DOCUMENTATION:https://eea.github.io/clms-api-docs/download.html#request-the-download
import requests
import json
import time
import jwt
import glob
import os
import logging

API = "https://land.copernicus.eu/api/"
PRODUCT = "CORINE Land Cover"


def get_token(credentials):
    """Gets a JWT for CLMS API access.

    Returns:
       access_token: The access token for the CLMS API.
    """
    # Load saved key from filesystem
    service_key = json.load(open(credentials, "rb"))
    # Convert the private key to a bytes object
    private_key = service_key["private_key"].encode("utf-8")
    # Create a claim set for the JWT
    claim_set = {
        "iss": service_key["client_id"],
        "sub": service_key["user_id"],
        "aud": service_key["token_uri"],
        "iat": int(time.time()),
        "exp": int(time.time() + (60 * 60)),
    }
    # Create a signed JWT from the claim set
    grant = jwt.encode(claim_set, private_key, algorithm="RS256")
    # Authorize user with the CLMS API
    req1 = requests.post(
        f"{API}@@oauth2-token",
        headers={
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded",
        },
        data="grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=REDACTED",
    )
    req1.raise_for_status()
    # Make a request to the token endpoint to exchange the JWT for a token
    result = requests.post(
        service_key["token_uri"],
        headers={
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded",
        },
        data={
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
            "assertion": grant,
        },
    )
    result.raise_for_status()

    # Convert the response to JSON
    access_token_info_json = result.json()
    # Extract the access token from the JSON response
    access_token = access_token_info_json.get("access_token")
    access_token.raise_for_status()
    print("New CLMS Access token generated: ", access_token)

    return access_token


def vSensor(logs_folder):
    """Senses new CORINE data from the CLMS API.

    :param logs_folder: The path for the folder with CLMS logs.

    Returns:
        True if new data is available, False if not.
    """
    # Get the DataSet metadata from the CLMS API
    req3 = requests.get(
        f"{API}@search?portal_type=DataSet&metadata_fields=UID&metadata_fields=dataset_full_format&&metadata_fields=dataset_download_information&&b_size=100000",
        headers={"Accept": "application/json"},
    )
    items = req3.json()["items"]
    substrings = ["CORINE Land Cover", "Europe", "100 m", "6-yearly"]
    current = []
    new = []
    obj = {}
    # Check if the metadata contains the required substrings
    for data in items:
        if (
            (substrings[0] in data["title"])
            & (substrings[2] in data["title"])
            & (substrings[3] in data["title"])
            & ("Change" not in data["title"])
        ):
            # Append the metadata to an object and the object to a list
            obj["title"] = data["title"]
            obj["dataset_full_format"] = data["dataset_full_format"]
            obj["dataset_download_information"] = data["dataset_download_information"]
            obj["UID"] = data["UID"]
            obj["@id"] = data["@id"]
            current.append(obj)
            obj = {}

    # Load the previous metadata from the logs folder
    list_of_files = glob.glob(
        logs_folder or "../logs/feedback/corine/*.json"
    )  # * means all if need specific format then *.json
    # Get the latest log file
    latest_file = max(list_of_files, key=os.path.getctime)

    # Compare the new metadata with the previous metadata
    if latest_file:
        with open(latest_file, "r") as f:
            old = json.load(f)
            for i in new:
                if i not in old:
                    new.append(i)
                    print("New CORINE data available...")
                else:
                    print("No new CORINE data")
            with open(
                f"../logs/feedback/corine/clms-{round(time.time())}.json", "w"
            ) as f:
                json.dump(new, f)
    return True


def intaker(access_token, logs_folder, output_dir):
    """Downloads the CORINE 6-yearly data from the CLMS server.

    :param access_token: The access token for the CLMS API.
    :param logs_folder: The path for the folder with CLMS logs.
    :param: output_dir: The path where data files are downloaded to.

    Returns:
        None
    """
    clms = glob.glob(
        logs_folder or "../logs/feedback/corine/*.json"
    )  # * means all if need specific format then *.csv
    latest_clms = max(clms, key=os.path.getctime)
    dataset_list = json.load(open(f"../references/corine/{latest_clms}.json", "rb"))
    for i in dataset_list:
        DatasetID = i["UID"]
        DatasetDownloadInformationID = ""

        for x in i["dataset_download_information"]["items"]:
            if x["full_format"] == "Geotiff":
                DatasetDownloadInformationID = x["@id"]
                print(DatasetID)
                print(DatasetDownloadInformationID)
                task = requests.post(
                    f"{API}@datarequest_post",
                    headers={
                        "Accept": "application/json",
                        "Content-Type": "application/json",
                        "Authorization": f"Bearer {access_token}",
                    },
                    json={
                        "Datasets": [
                            {
                                "DatasetID": DatasetID,
                                "DatasetDownloadInformationID": DatasetDownloadInformationID,
                                "OutputFormat": "Geotiff",
                                "OutputGCS": "EPSG:4326",
                            }
                        ]
                    },
                )
                print(task.json())
            
                while status.json()["items"][0]["status"] != "Completed":
                    time.sleep(10)
                    status = requests.get(
                        f"{API}@datarequest_search",
                        headers={
                            "Accept": "application/json",
                            "Content-Type": "application/json",
                            "Authorization": f"Bearer {access_token}",
                        },
                    )
                    print(status.json())
                #TODO: Add download functionality
                download = requests.get(
                    f"{API}@datarequest_search",
                    headers={
                        "Accept": "application/json",
                        "Content-Type": "application/json",
                        "Authorization": f"Bearer {access_token}",
                    },
                )