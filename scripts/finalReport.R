if(!is.element("snakemake",ls())){
  projFolder <- "/scratch/project_2001746/TestProject"
  pipelineFolder <- "/users/fischerd/git/Snakebite-LiftOver/"
  pipelineConfig.file <- "/scratch/project_2001746/TestProject/Snakebite-LiftOver_config.yaml"
}

last_n_char <- function(x, n=1){
  substr(x, nchar(x) - n + 1, nchar(x))
}

if(last_n_char(pipelineFolder)!="/") pipelineFolder <- paste0(pipelineFolder, "/")

createRMD.command <- paste0("cat ",pipelineFolder,"scripts/Rmodules/final-header.Rmd ",
                                   pipelineFolder,"scripts/Rmodules/helpFunctions.Rmd ",
                                   pipelineFolder,"scripts/Rmodules/generalWorkflow.Rmd ",
                                   pipelineFolder,"scripts/Rmodules/basicStats.Rmd ",
                                   "> ",projFolder,"/finalReport.Rmd")
cat(createRMD.command, "\n")

system(createRMD.command)

rmarkdown::render(file.path(projFolder,"finalReport.Rmd"), output_file=file.path(projFolder,"finalReport.html"))