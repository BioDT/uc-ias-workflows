require(renv)
renv::load(project = "iasdt-renv", quiet = FALSE, prompt = FALSE)

require(IASDT.R)

IASDT.R::InfoChunk(
  Message = "++++ PROCESSING CORINE LAND COVER DATA",
  Rep = 2, Char = "+", CharReps = 70, Extra2 = 2)

IASDT.R::CLC_Process(
	EnvFile = "/pfs/lustrep4/scratch/project_465000915/elgabbas/.env", FromHPC = TRUE, MinLandPerc = 15, PlotCLC = TRUE)