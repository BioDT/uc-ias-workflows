from feedbackloop.chelsa import vSensor, intaker
from feedbackloop.corine import get_token, vSensor, intaker


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
    """CHELSA Workflow"""
    return {
        "actions": [
            vSensor("../references/chelsa/test.txt"),
            intaker("../references/chelsa/test.txt", "../datasets/raw/chelsa"),
        ],
    }


# TODO: Add access token to the intaker action
def task_corine():
    """CLMS CORINE Workflow"""
    return {
        "actions": [
            get_token("../corine/clc.json"),
            vSensor(""),
            intaker("aaccessToken", "../logs/feedback/corine/*.json","../datasets/raw/corine"),
        ],
    }

