from feedbackloop.chelsa import vSensor as chelsa_vSensor, intaker as chelsa_intaker
from feedbackloop.corine import (
    get_token as clc_get_token,
    vSensor as clc_vSensor,
    intaker as clc_intaker,
)
from state.rocrates import action_one


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
        "depen"
        "actions": [
            (chelsa_vSensor, [], {
                'path_file': '/users/khantaim/iasdt-workflows/references/chelsa/test.txt',
                'logs_feedback': '/users/khantaim/iasdt-workflows/logs/feedback/chelsa/',
                'logs_diff': '/users/khantaim/iasdt-workflows/logs/diff/chelsa/'}),
            (chelsa_intaker, [], {
                'path_to_download_list': '/users/khantaim/iasdt-workflows/references/chelsa/test.txt',
                'output_dir': '/users/khantaim/iasdt-workflows/datasets/raw/chelsa/'}),
            "Rscript /pfs/lustrep3/users/khantaim/iasdt-workflows/workflows/process/chelsa.R"
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


def task_service():
    """Service Task"""
    return {
        "actions": [
            (action_one, [], {
                "input": "input",
                "output": "output",
                }),
        ],
    }