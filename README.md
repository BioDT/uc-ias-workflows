 <div align="center" style="text-align:center">
  <img width="30%" src="assets/biodt.png" />
  <br/>
  <b>Workflows for the Invasive Alien Species Digital Twin (IASDT), as part of the Horizon Europe project tiled <a href="https://biodt.eu">Biodiversity Digital Twin</a>.</b>  
</div>

> This is a collection of PyDoit workflows for data processing, data assimilation, state management, metadata management, data and HPC servicing, and job orchestration in the IASDT.

**Overview Paper:** [![DOI:10.1101/2024.07.23.604592](http://img.shields.io/badge/DOI-10.1101/2024.07.23.604592-323F23.svg)](https://doi.org/10.3897/rio.10.e124579) 

**Code DOI:** [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14756907.svg)](https://doi.org/10.5281/zenodo.14756907)



>[!CAUTION]
>This repository is under active development and is not yet ready for public use. Please contact the author for more information.

>[!TIP]
> The branching in this repository is named after each HPC system where the workflows are executed. For example, the `lumi` branch contains the workflows for the LUMI supercomputer, which is the main branch.

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Overview](#overview)
  - [Architectural overview](#architectural-overview)
  - [Study area \& geospatial projection](#study-area--geospatial-projection)
  - [Datasets](#datasets)
- [Folder Descriptions](#folder-descriptions)
- [Usage](#usage)
- [Create Documentation](#create-documentation)
- [Logging](#logging)
- [Environment Variables](#environment-variables)
  - [Workflow parameter naming convention](#workflow-parameter-naming-convention)
- [Model and Data processing](#model-and-data-processing)
- [Data Storage and Availability](#data-storage-and-availability)
- [Dashboard](#dashboard)
- [Metadata and RO-Crates](#metadata-and-ro-crates)
- [Containerization](#containerization)
- [License](#license)
- [Cite as](#cite-as)
- [Author](#author)
- [Contributors](#contributors)

## Overview

The Invasive Alien Species Digital Twin (IASDT) is a digital twin that uses dynamic data-driven workflows for joint species distribution modelling of invasive alien species (IAS) in continental Europe with Hierarchical Modelling of Species Communities ([HMSC](https://www.helsinki.fi/en/researchgroups/statistical-ecology/software/hmsc)) models. The IASDT uses biotic and abiotic datasets to estimate the current and forecast the future distribution of IAS in Europe under various climate scenarios. The IASDT is part of the [Biodiversity Digital Twin (BioDT)](https://biodt.eu) project, which is funded by the European Union.

The workflows are written in Python and R, and are automated using the [PyDoit](https://pydoit.org) build automation tool. These workflows are meant to be executed on HPC systems, mainly [LUMI](https://lumi-supercomputer.eu). The workflows are designed to be modular and scalable based on the [TwinEco](#architectural-overview) framework. These workflows are designed to be used with the [OPeNDAP Cloud Server](#data-storage-and-availability) to serve data to third-party applications.

A detailed overview can be found on the project wiki: https://wiki.eduuni.fi/x/Yg2cEw

### Architectural overview

The IASDT follows the **TwinEco framework for building DTs in ecology.

>Khan, T., de Koning, K., Endresen, D., Chala, D. and Kusch, E., 2024. TwinEco: A Unified Framework for Dynamic Data-Driven Digital Twins in Ecology. bioRxiv, pp.2024-07. [![DOI:10.1101/2024.07.23.604592](http://img.shields.io/badge/DOI-10.1101/2024.07.23.604592-323F23.svg)](https://doi.org/10.1101/2024.07.23.604592)

<br/>
<centre>
<img src="assets/IASDT-dataflow-components.png"  width="50%" style="align:center"/>
</centre>
<br/>


**Figure 1:** An overview of the Invasive Alien Species Digital Twin (IASDT) components. 1) Dynamic Data-Driven Application Systems (DDDAS) based workflows listen for changes in data sources (1.a. feedback loops), pull and process required data (1.b. data processing), merge and reconcile new and old data (1.c. data assimilation), version datasets and add metadata (1.d. state + FAIR metadata management), and transfer updated datasets (data + log files) to a data server (1.e. data servicing). 2) OPeNDAP Cloud Server services the datasets from the previous component and provides an interface to all IASDT data (input, output, metadata, and log files). The server also serves as an interface for third-party applications to access information contained in the IASDT. 3) IAS Joint Species Distribution Model is the modelling block of IASDT that uses input data to estimate gridded IAS numbers per habitat type. 4) IASDT dashboard presents aggregated results of IASDT in a simplified and intuitive manner to BioDT users and stakeholders and serves as a communication tool.

### Study area & geospatial projection

<centre>
<img src="assets/CHELSA-studyarea.jpeg" width="50%"/>
</centre>
<br/>

**Figure 2:** Study area is defined as the area of the [EEA Reference Grid](https://www.eea.europa.eu/en/datahub/datahubitem-view/3c362237-daa4-45e2-8c16-aaadfb1a003b). The study area is divided into 10x10 km grid cells. The grid cells are projected in the [ETRS89-LAEA projection](https://epsg.io/3035) (EPSG:3035).

### Datasets

| Data                                                                                         | Spatial resolution                                                           | Temporal resolution    | Details                                                                                                                                                                                                                                                                                                | Source                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| -------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Reference grid                                                                               | 10 km                                                                        | \---                   | The European Environment Agency's (EEA) reference grid at 10 km resolution at Lambert Azimuthal Equal Area projection (EPSG:3035). All data listed below were processed into this reference grid.                                                                                                      | https://www.eea.europa.eu/en/datahub/datahubitem-view/3c362237-daa4-45e2-8c16-aaadfb1a003b                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| Species observations                                                                         | Global Biodiversity Information Facility (GBIF)                              | points                 | \> 1981                                                                                                                                                                                                                                                                                                | The most up-to-date version of occurrence data is dynamically downloaded from GBIF using the rgbif R package (Chamberlain et al. 2023) (> 8 million occurrences, March 2024; Figure 2a). Doubtful occurrences and occurrences with high spatial uncertainty are excluded.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | https://www.gbif.org/ |
| European Alien Species Information Network (EASIN)                                           | points                                                                       | \> 1981                | EASIN provides spatial data on 14,000 alien species. Species occurrences were downloaded using EASIN's API. Thirty-four partners shared their data with EASIN (including GBIF). Only non-GBIF data from EASIN were considered in the models (> 692 K observations for 483 IAS; March 2024; Figure 2b). | European Commission - Joint Research Centre - European Alien Species Information Network (EASIN) https://easin.jrc.ec.europa.eu/                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| Integrated European Long-Term Ecosystem, Critical Zone and socio-ecological Research (eLTER) | points                                                                       | \> 1981                | eLTER is a network of sites collecting ecological data for long-term research within the EU. Vegetation data from 137 eLTER sites were processed and homogenised. The final eLTER dataset comprises 5,265 observations from 46 sites, representing 110 IAS (Figure 2c).                                | https://elter-ri.eu/                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| Habitat information                                                                          | Corine Land Cover (CLC)                                                      | 100 m                  | 2017-2018                                                                                                                                                                                                                                                                                              | CLC dataset is a pan-European land-cover and land-use inventory with 44 thematic classes, ranging from broad forested areas to individual vineyards. We are currently using V2020_20u1 of CLC data, but the data workflow is flexible to use future versions of CLC data.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | https://land.copernicus.eu/en/products/corine-land-cover |
| Climate data                                                                                 | Climatologies at high resolution for the Earth’s land surface areas (CHELSA) | 30 arc seconds; ~ 1 km | 1981–20102011–20402041–20702071–2100                                                                                                                                                                                                                                                                   | CHELSA provides global high-resolution data on various environmental variables currently and in different future climate scenarios. Six ecologically meaningful and low-correlated bioclimatic variables are used in the models-        temperature seasonality (bio4)-        mean daily minimum air temperature of the coldest month (bio6)-        mean daily mean air temperatures of the wettest quarter (bio8)-        annual precipitation amount (bio12)-        precipitation seasonality (bio15)-        mean monthly precipitation amount of the warmest quarter (bio18)In addition to current climate conditions, there are nine options for multiple climate CMIP6 models (3 shared socioeconomic pathways [ssp126 - ssp370 - ssp585] × 3 time slots [2011-2040 - 2041-2070 - 2071-2100]). | Karger et al. (2018), Karger et al. (2017)https://chelsa-climate.org/ |
|  Road intensity                                                                              | lines                                                                        | most recent            | The total length of roads per grid cell was computed from the most recent version of the GRIP (Global Roads Inventory Project) global roads database.                                                                                                                                                  | Meijer et al. (2018)https://www.globio.info/download-grip-dataset                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
|  Railway intensity                                                                           | lines                                                                        | most recent            | The total length of railways per grid cell was computed from the most recent version of OpenRailwayMap.                                                                                                                                                                                                | https://www.openrailwaymap.org/                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
|  Sampling bias                                                                               | points                                                                       | \> 1981                | The total number of vascular plant observations per grid cell in the GBIF database was computed (> 230 million occurrences, March 2024).                                                                                                                                                               | https://www.gbif.org/                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |

## Folder Descriptions

- assets/ --> static assets (images, videos, etc.)
- datasets/ --> datasets divided into `raw`, `interim`, and `processed` sub-folders
- docs/ --> software documentation
- logs/ --> logs for workflow runs
- notebooks/ --> jupyter notebooks as playground and testing environment
- references/ --> reference files
- workflows/ --> Pydoit workflows
  - feedbackloop --> feedback loop tasks for "listening" to data changes and downloading datasets
  - process --> data processing tasks
  - state --> state management tasks
  - service --> downstream data servicing and HPC management tasks
  - dodo.py --> Main entry point for Pydoit workflows

## Usage

- Clone the repository to your local or cloud development environment.
- Create and configure the `.env` file with the necessary credentials and settings.
- Install all dependencies from `requirements.txt` and `renv.lock` files.
- Use the workflow directory as the current working directory.
- Run the following command in the CLI for listing available tasks: `pydoit list`
- Run all tasks and actions with pydoit command or individual - tasks using `pydoit <task-name>` command in a shell.
- Parallel task execution can be enabled by running the command `doit -n 4` (n defines the number of cores to attach to pydoit runtime).

Alternatively, simply run the following command from the root fodler to run all tasks:

```bash
bash entry.sh
```

## Create Documentation

Run the following code to create Sphinx documentation.

```
cd docs
make html
```

## Logging

> LUMI timestamps are in Finnish time

IASDT Workflows use Unix styled logging with the following logging levels:

- Warning: Warning logs
- Info: Informational logs
- Debug: Debugging logs
- Error: Errors
- Critical: Critical errors

Logging is mostly done using the `logging` module in Python. However, some tasks use `R` where scripts are submitted to the HPC slurm queue. In such cases, the logs will be stored to `.out` and `.err` files in the `logs` directory.

## Environment Variables

### Workflow parameter naming convention

The IASDT workflows use environment variables to pass parameters to the workflows. This convention is defined in the `references/parameter_naming_conventions.txt`file. The naming convention for the environment variables is as follows:

**Workflow layers**

- FL=Feedback loop
- DP=Data Processing
- DA=Data Assimilation
- SM=State Management
- MM=Metadata Management
- DS=Data Servicing
- MC=Model Communication

**Programming languages and tools**

- R=R Lang
- Py=Python Lang
- Do=Docker
- PyDo=PyDoit

**Convention**

`<layer>_<programming tools>_<data source>_<parameter name>=<parameter value>`

**Example**

DP_R_CHELSA_Gridsize=10

All the required environment variables can be found in the [`references/env-var-list.csv`](references/env-var-list.csv) file.

## Model and Data processing

The model and data processing code is developed separately in a R package called `IASDT.R`. The R package can be found in the [IASDT.R](https://github.com/BioDT/IASDT.R) Github repository. 

**IASDT.R package:** https://github.com/BioDT/IASDT.R

## Data Storage and Availability

The IASDT uses a custom built and hosted Open-source Project for a Network Data Access Protocol (OPeNDAP) Catalog to serve data to any application. The OPeNDAP Catalog is hosted on a virtual machine (VM). The OPeNDAP Catalog is used to serve data to third-party applications, such as the IASDT [dashboard](#dashboard), and provides an interface for users to access input/output data stored in the IASDT.

The OPenDAP Catalog clones some defined data from the HPC into a VM using Docker and serves it using the Data Access Protocol (DAP), which is a defined data model for accessing remote scientific datasets. The magic here is that DAP allows users to query subsets of the data files, while automatically giving variable-level access ([see example](http://opendap.biodt.eu/sample/nc/coads_climatology.nc.html)), and automatically assigning metadata to the contents of each file ([see example](http://134.94.199.14/sample/nc/coads_climatology.nc.das)).

- **Opendap Catalog Link:** http://opendap.biodt.eu/
- **Opendap Catalog documentation:** https://khant.pages.ufz.de/opendap/chapters/concept/opendap.html
- **Opendap Catalog code:** https://git.ufz.de/khant/opendap

## Dashboard

The IASDT dashbaord is created using RShiny, and is linked to the DT OpenDAP server. The dashboard will be used to present the results of the IASDT to users and stakeholders in a simplified and intuitive manner. 

- **Dashboard code:** https://github.com/allantsouza/IAS-pDT-BioDT-web-app
- **Dashboard link:** https://allantsouza.shinyapps.io/IAS-pDT-BioDT-web-app/

**Sample screenshot:**

<centre>
<img src="assets/dashboard.png" width="70%"/>
</centre>


## Metadata and RO-Crates

The IASDT uses the Research Object Crate (RO-Crate) metadata standard to describe the data and workflows. The RO-Crate metadata standard is a community-driven specification for packaging research data with associated metadata. The RO-Crate metadata standard is designed to be machine-readable and human-readable, and it is designed to be used with a wide range of research data types, including datasets, software, and workflows.

We will use the [PyDidIt software](https://github.com/BioDT/pydidit) (developed in-house) for generating workflow crates and the RO-Crate Python library for generating RO-Crate metadata for the data. The RO-Crate metadata will be stored in the same directory as the data, and it will be used to describe the data and the workflows that generated the data.

- **RO-Crate documentation:** https://www.researchobject.org/ro-crate/
- **RO-Crate Python library:** https://pypi.org/project/ro-crate/

## Containerization 

Parts of the IASDT (specifically modelling) are containerized using Singularity containers. The containers are built using the Singularity containerization software and are used to package the IASDT modelling code and dependencies. The containers are used to run the IASDT modelling code on the HPC system, and they are used to ensure that the code runs in a consistent environment across different systems.

- **Singularity documentation:** https://sylabs.io/guides/3.7/user-guide/
- **Container template (HMSC-HPC)**: https://github.com/BioDT/hmsc-container
- **Container template (R)**: https://git.ufz.de/biodt/iasdt-modelling-containers

## License

## Cite as

```bibtex
@misc{biodt_iasdt_2025,
  author       = {Khan, Taimur},
  title        = {BioDT: Invasive Alien Species Digital Twin (IASDT) Workflows},
  year         = {2025},
  month        = {02},
  note         = {Biodiveristy Digital Twin (BioDT), Funded by the European Union }
}
```

## Author

- [Taimur Khan](mailto:taimur.khan@ufz.de), Helmholtz centre for environmental research - UFZ | **Workflows, Architecture, HPC, Data Processing, Containerization, Opendap server**

## Contributors

- [Ahmed El-Gabbas](mailto:ahmed.el-gabbas@ufz.de), Helmholtz centre for environmental research - UFZ | **IASDT.R, Modelling, Data Processing**
- [Dylan Kierans](), German Climate Computing Center (DKRZ)  | **Containerization**
- [Julian Lopez Gordillo](mailto:julian.lopezgordillo@naturalis.nl), Naturalis Biodiversity Center | **Metadata and RO-Crates**
- [Oliver Wooland](mailto:oliver.woolland@manchester.ac.uk), University of Manchester | **RO-Crates(Pydidit)**
- [Allan Souza](mailto:allan.souza@helsinki.fi), Institute for Atmospheric and Earth System Research INAR | **Dashboard**
- [Tuomas Rossi](mailto:tuomas.rossi@csc.fi) , CSC – IT Center for Science Ltd. | **HPC, Containerization**
- [Jakub Konvicka](mailto:jakub.konvicka@vsb.cz), IT4Innovations | **HPC (LEXIS)**




