from feedbackloop.chelsa import vSensor as chelsa_vSensor, intaker as chelsa_intaker
from feedbackloop.corine import (
    get_token as clc_get_token,
    vSensor as clc_vSensor,
    intaker as clc_intaker,
)


""" 
def task_setup():
    #Setup Workflow Environment    
    return {
        "actions": [
            "python -m pip install -r ../requirements.txt",
            "python -m pip install -e .",

        ],
    }
"""


def task_chelsa():
    """CHELSA Task"""
    return {
        "actions": [
            chelsa_vSensor(
                "../references/chelsa/test.txt",
                "../logs/feedback/chelsa/",
                "../logs/diff/chelsa/",
            ),
            chelsa_intaker("../references/chelsa/test.txt", "../datasets/raw/chelsa/"),
            "RScript /users/khantaim/iasdt-workflows/workflows/process/chelsa.R",
        ],
    }


""" 
def task_corine():
    #CLC Task
    return {
        "actions": [
            clc_get_token("../references/corine/clc.json"),
            clc_vSensor(""),
            clc_intaker("aaccessToken", "../logs/feedback/corine/*.json","../datasets/raw/corine"),
        ],
    }

 """
