# CLMS DOCUMENTATION:https://eea.github.io/clms-api-docs/download.html#request-the-download
import requests
import json
import time
import jwt
import glob
import os

API="https://land.copernicus.eu/api/"
PRODUCT="CORINE-Land-Cover"


def get_token():
    # Load saved key from filesystem
    service_key = json.load(open('../references/corine/clc.json', 'rb'))

    private_key = service_key['private_key'].encode('utf-8')

    claim_set = {
        "iss": service_key['client_id'],
        "sub": service_key['user_id'],
        "aud": service_key['token_uri'],
        "iat": int(time.time()),
        "exp": int(time.time() + (60 * 60)),
    }
    grant = jwt.encode(claim_set, private_key, algorithm='RS256')
    req1= requests.post(f'{API}@@oauth2-token', headers={'Accept': 'application/json', 'Content-Type': 'application/x-www-form-urlencoded'}, data='grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=REDACTED')
    req1.raise_for_status()
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

    access_token_info_json = result.json()
    access_token = access_token_info_json.get('access_token')
    print(access_token)

    return True

def vSensor():
    
    req3=requests.get(f'{API}@search?portal_type=DataSet&metadata_fields=UID&metadata_fields=dataset_full_format&&metadata_fields=dataset_download_information&&b_size=100000', headers={'Accept': 'application/json'})
    items = req3.json()['items']
    substrings = ['CORINE Land Cover', 'Europe', '100 m', '6-yearly']
    current =[]
    new = []
    obj = {}
    for data in items:
            if (substrings[0] in data['title']) & (substrings[2] in data['title']) & (substrings[3] in data['title']) & ('Change' not in data['title']):
                obj['title']=data['title']
                obj['dataset_full_format']=data['dataset_full_format']
                obj['dataset_download_information']=data['dataset_download_information']
                obj['UID']=data['UID']
                obj['@id']=data['@id']
                current.append(obj)
                obj = {}

    list_of_files = glob.glob('../logs/feedback/corine/*.json') # * means all if need specific format then *.csv
    latest_file = max(list_of_files, key=os.path.getctime)
        
    if latest_file:
            with open(latest_file, 'r') as f:
                old = json.load(f)
                for i in new:
                    if i not in old:
                        new.append(i) 
                        print('new CORINE data available...')
                    else:
                        print('no new data')
                with open(f'../logs/feedback/corine/clms-{round(time.time())}.json', 'w') as f:
                    json.dump(new, f)
    return True
    
def intaker():
     for i in current:
    DatasetID = i['UID']
    DatasetDownloadInformationID = ''

    for x in i['dataset_download_information']['items']:
        if x['full_format'] == 'Geotiff':
            DatasetDownloadInformationID = x['@id']
    print(DatasetID)
    print(DatasetDownloadInformationID)           
    task=requests.post(f'{API}@datarequest_post', headers={'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': f'Bearer {access_token}'}, json={'Datasets': [{'DatasetID': DatasetID, 'DatasetDownloadInformationID': DatasetDownloadInformationID, 'OutputFormat': 'Geotiff', 'OutputGCS': 'EPSG:4326'}]})
    print(task.json())
    status=requests.get(f'{API}@datarequest_search', headers={'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': f'Bearer {access_token}'})
    print(status.json())
    with open('../references/corine/status-sample.json', 'w') as f:
    json.dump(status.json(), f)
