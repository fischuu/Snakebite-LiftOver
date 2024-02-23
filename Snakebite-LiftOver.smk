import pandas as pd
from snakemake.utils import validate, min_version
from multiprocessing import cpu_count
import glob
import re
import os
import sys
import yaml

report: "report/workflow.rst"

##### Snakebite-LiftOver #####
##### Daniel Fischer (daniel.fischer@luke.fi)
##### Natural Resources Institute Finland (Luke)
##### Version: 0.1
version = "0.1"

##### set minimum snakemake version #####
#min_version("6.0")

##### load config and sample sheets #####

workdir: config["project-folder"]

##### Fill the configuration lines for relative paths
if config["project-folder"][-1] == '/':
   config["project-folder"]=config["project-folder"][:-1]
   
if(config["pipeline-config"][0]!='/'):
    config["pipeline-config"] = config["project-folder"] + '/' + config["pipeline-config"]

if(config["server-config"][0]!='/'):
    config["server-config"] = config["project-folder"] + '/' + config["server-config"]
    
##### Extract the cluster resource requests from the server config #####
cluster=dict()
if os.path.exists(config["server-config"]):
    with open(config["server-config"]) as yml:
        cluster = yaml.load(yml, Loader=yaml.FullLoader)

workdir: config["project-folder"]

##### Complete the input configuration
config["report-script"] = config["pipeline-folder"]+"/scripts/finalReport.R"

##### Singularity container #####
config["singularity"] = {}
config["singularity"]["fastp"] = "docker://fischuu/fastp:0.20.1"
config["singularity"]["r-gbs"] = "docker://fischuu/r-gbs:4.2.1-0.7"
config["singularity"]["star"] = "docker://fischuu/star:2.7.5a"

##### Print the welcome screen #####
print("#################################################################################")
print("##### Welcome to the Snakebite-LiftOver pipeline")
print("##### version: "+version)
print("#####")
print("##### Pipeline configuration")
print("##### --------------------------------")
print("##### project-folder       : "+config["project-folder"])
print("##### pipeline-folder      : "+config["pipeline-folder"])
print("##### pipeline-config      : "+config["pipeline-config"])
print("##### server-config        : "+config["server-config"])
print("#####")
print("##### Singularity configuration")
print("##### --------------------------------")
print("##### star      : "+config["singularity"]["star"])


##### run complete pipeline #####
rule all:
    input:
        "%s/finalReport.html" % (config["project-folder"])

##### load rules #####
include: "rules/Module1-Preparations"
