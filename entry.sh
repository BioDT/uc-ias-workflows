#!/bin/bash

cd /scratch/project_465001588/khantaim/iasdt-workflows

# Check if requirements.txt exists
if [ ! -f requirements.txt ]; then
    echo "requirements.txt not found!"
    exit 1
fi

# Check if iasdt-pyenv exists, if not then create it
if [ ! -d "iasdt-pyenv" ]; then
    python -m venv iasdt-pyenv
    # Install the packages listed in requirements.txt
    pip install -r requirements.txt
fi

# Check if the installation was successful
if [ $? -eq 0 ]; then
    echo "Packages installed successfully."
else
    echo "Failed to install packages."
    exit 1
fi

# Check if renv.lock exists
if [ ! -f iasdt-renv/renv.lock ]; then
    echo "renv.lock not found!"
    exit 1
fi

# Check if iasdt-renv exists, if not then create it
if [ ! -d "iasdt-renv" ]; then
    cd /scratch/project_465001588/khantaim/iasdt-workflows/iasdt-renv
    Rscript -e "if (!requireNamespace('renv', quietly = TRUE)) install.packages('renv'); renv::restore(lockfile = 'renv.lock')"

fi

# Check if the installation was successful
if [ $? -eq 0 ]; then
    echo "renv packages restored successfully."
else
    echo "Failed to restore renv packages."
    exit 1
fi

cd /scratch/project_465001588/khantaim/iasdt-workflows/workflows

# Trigger the PyDoit workflow
doit run