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
##### Version: 0.1.3
version = "0.1.3"

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
    
if(config["start-genome"][0]!='/'):
    config["start-genome"] = config["project-folder"] + '/' + config["start-genome"]
    
if(config["start-bed"][0]!='/'):
    config["start-bed"] = config["project-folder"] + '/' + config["start-bed"]
    
if(config["end-genome"][0]!='/'):
    config["end-genome"] = config["project-folder"] + '/' + config["end-genome"]
    
if(config["end-bed"][0]!='/'):
    config["end-bed"] = config["project-folder"] + '/' + config["end-bed"]
    
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
config["singularity"]["r-gbs"] = "docker://fischuu/r-gbs:4.2.1-0.7"
config["singularity"]["fatotwobit"] = "docker://quay.io/biocontainers/ucsc-fatotwobit:357--h446ed27_4"
config["singularity"]["pblat"] = "docker://icebert/pblat"
config["singularity"]["pslToChain"] = "docker://icebert/docker_ucsc_genome_browser"
config["singularity"]["liftover"] = "docker://quay.io/biocontainers/ucsc-liftover:357--h446ed27_4"

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
print("##### start-genome         : "+config["start-genome"])
print("##### end-genome           : "+config["end-genome"])
print("##### start-bed            : "+config["start-bed"])
print("##### end-bed              : "+config["end-bed"])
print("#####")
print("##### Singularity configuration")
print("##### --------------------------------")
print("##### R          : "+config["singularity"]["r-gbs"])
print("##### FaToTwoBit : "+config["singularity"]["fatotwobit"])
print("##### PBlat       : "+config["singularity"]["pblat"])
print("##### PSL2Chain  : "+config["singularity"]["pslToChain"])
print("##### LiftOver   : "+config["singularity"]["liftover"])

##### run complete pipeline #####
rule all:
    input:
        "%s/CHAIN/over.chain" % (config["project-folder"])

rule blat:
    input:
        "%s/CHAIN/chain_oldToNew.psl" % (config["project-folder"]),
        "%s/CHAIN/chain_newToOld.psl" % (config["project-folder"])

##### load rules #####
include: "rules/Module1-Preparations"
include: "rules/Module2-liftOver"
