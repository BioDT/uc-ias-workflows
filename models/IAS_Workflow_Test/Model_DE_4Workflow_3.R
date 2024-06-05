source("_Scripts/AlwaysLoad.R")

# Change the path of the environment variables file
EnvFile <- "/pfs/lustrep4/users/elgabbas/BioDT_IAS/.env"

# Change path
readRenviron(EnvFile)
setwd(Sys.getenv("Path_LUMI_Scratch"))

IASDT.R::Mod_MergeChains(
  Path_Model = "IAS_Workflow_Test/Model",
  EnvFile = EnvFile, NCores = 4, PrintIncomplete = TRUE, FromJSON = TRUE)
