# IASDT-workflows

Data workflows for the IAS-DT, as part of BioDT.

![overview](assets/IASDT-Data Streams Overview.png)

## Project Organization


```
iasdt-workflows
├─ .gitignore
├─ LICENSE
├─ Makefile
├─ README.md
├─ datasets
│  ├─ interim
│  │  └─ .gitkeep
│  ├─ processed
│  │  └─ .gitkeep
│  └─ raw
│     ├─ .gitkeep
│     └─ chelsa
│        ├─ CHELSA_swb_2013_V.2.1.tif
│        ├─ CHELSA_swb_2014_V.2.1.tif
│        ├─ CHELSA_swb_2015_V.2.1.tif
│        ├─ CHELSA_swb_2016_V.2.1.tif
│        ├─ CHELSA_swb_2017_V.2.1.tif
│        └─ CHELSA_swb_2018_V.2.1.tif
├─ docs
│  ├─ Makefile
│  ├─ commands.rst
│  ├─ conf.py
│  ├─ getting-started.rst
│  ├─ index.rst
│  └─ make.bat
├─ logs
│  ├─ .gitkeep
│  └─ figures
│     └─ .gitkeep
├─ models
│  └─ .gitkeep
├─ notebooks
│  ├─ .gitkeep
│  ├─ .ipynb_checkpoints
│  └─ 1.0-chelsa.ipynb
├─ references
│  ├─ .gitkeep
│  └─ chelsa_paths.txt
├─ requirements.txt
├─ setup.py
├─ test_environment.py
├─ tox.ini
└─ workflows
   ├─ __init__.py
   ├─ assimilation
   │  ├─ .gitkeep
   │  ├─ __init__.py
   │  └─ chelsa.py
   ├─ data
   │  ├─ .gitkeep
   │  ├─ __init__.py
   │  ├─ __pycache__
   │  │  └─ chelsa.cpython-39.pyc
   │  └─ chelsa.py
   ├─ dodo.py
   ├─ feedbackloop
   │  ├─ .gitkeep
   │  ├─ __init__.py
   │  └─ check.py
   └─ service
      ├─ .gitkeep
      └─ __init__.py

```




## Create Documentation

```
cd docs
make html
```
