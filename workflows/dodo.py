from download.chelsa import download_data


def task_chelsa():
    """Download CHELSA data"""
    return {
        "actions": [download_data("../references/test.txt", "../datasets/raw/chelsa")]
    }
