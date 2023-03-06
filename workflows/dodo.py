from data.chelsa import download_data


def task_chelsa():
    """Download CHELSA data"""
    return {
        "actions": [download_data("../references/chelsa_paths.txt", "../datasets/raw/chelsa")]
    }
