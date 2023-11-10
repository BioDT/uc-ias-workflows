# IASDT-workflows

Data workflows for the IAS-DT, as part of BioDT.
A detailed overview can be found on the project wiki: https://wiki.eduuni.fi/x/Yg2cEw

![overview](assets/IASDT-Data Streams Overview.png)

![sample](assets/CHELSA-studyarea.jpeg)

## Folder Descriptions

- assets/ --> static assets (images, videos, etc.)
- datasets/ --> datasets divided into `raw`, `interim`, and `processed` sub-folders
- docs/ --> software documentation
- logs/ --> logs for workflow runs
- models/ --> modeling code
- notebooks/ --> jupyter notebooks as playground and testing environment
- references/ --> reference files
- workflows/ --> Pydoit workflows
    - feedbackloop --> feedback loop tasks for "listening" to data changes and downloading datasets 
    - process --> data processing tasks
    - state --> state management tasks
    - service --> downstream data servicing and HPC management tasks

## Usage

- Clone the GitLab repository to your local or cloud development environment. 
- Create and configure the .env file with the necessary credentials and settings. 
- Install all dependencies from requirements.txt and renv.lock files. 
- Use the workflow directory as the current working directory. 
- Run the following command in the CLI for listing available tasks: pydoit list 
- Run all tasks and actions with pydoit command or individual - tasks using pydoit <task-name> command. 
- Parallel task execution can be enabled by running the command doit -n 4 (n defines the number of cores to attach to pydoit runtime).   

## Create Documentation

Run the following code to create Sphinx documentation.

```
cd docs
make html
```
