import pandas as pd
from snakemake.utils import validate, min_version
from multiprocessing import cpu_count
import glob
import re
import os
import sys
import yaml

report: "report/workflow.rst"

##### Snakebite-LabQC #####
##### Daniel Fischer (daniel.fischer@luke.fi)
##### Natural Resources Institute Finland (Luke)
##### Version: 0.2
version = "0.2"

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

if(config["rawdata-folder"][0]!='/'):
    config["rawdata-folder"] = config["project-folder"] + '/' + config["rawdata-folder"]

if(config["samplesheet-file"][0]!='/'):
    config["samplesheet-file"] = config["project-folder"] + '/' + config["samplesheet-file"]

if config["sampleinfo-file"] == "":
    pass
else:
    if(config["sampleinfo-file"][0]!='/'):
        config["sampleinfo-file"] = config["project-folder"] + '/' + config["sampleinfo-file"]

if(config["genomes-folder"][0]!='/'):
    config["genomes-folder"] = config["project-folder"] + '/' + config["genomes-folder"]

if(config["tmp-folder"][0]!='/'):
    config["tmp-folder"] = config["project-folder"] + '/' + config["tmp-folder"]

##### load config and sample sheets #####
samplesheet = pd.read_table(config["samplesheet-file"]).set_index("rawsample", drop=False)
rawsamples=list(samplesheet.rawsample)
samples=list(set(list(samplesheet.sample_name)))
lane=list(samplesheet.lane)

# Get the basename fastq inputs
possible_ext = [".fastq", ".fq.gz", ".fastq.gz", ".fasta", ".fa", ".fa.gz", ".fasta.gz"]
ext = ".null"

reads1_tmp = list(samplesheet.read1)
reads1_trim = []
for r in reads1_tmp:
    for e in possible_ext:
        if r.endswith(e):
            addThis = r[:-len(e)]
            reads1_trim += [addThis]
            ext=e

reads2_tmp = list(samplesheet.read2)
reads2_trim = []
for r in reads2_tmp:
    for e in possible_ext:
        if r.endswith(e):
            addThis = r[:-len(e)]
            reads2_trim += [addThis] 
            ext=e

def get_raw_fastqs(wildcards):
    reads = samplesheet.loc[wildcards.rawsamples][["read1", "read2"]]
    path = config["rawdata-folder"]
    output = [path + "/" + x for x in reads]
    return output

def get_raw_fastqs_read1(wildcards):
    reads = samplesheet.loc[wildcards.rawsamples][["read1"]]
    path = config["rawdata-folder"]
    output = [path + "/" + x for x in reads]
    return output

def get_raw_fastqs_read2(wildcards):
    reads = samplesheet.loc[wildcards.rawsamples][["read2"]]
    path = config["rawdata-folder"]
    output = [path + "/" + x for x in reads]
    return output    
    
    
    
##### Extract the cluster resource requests from the server config #####
cluster=dict()
if os.path.exists(config["server-config"]):
    with open(config["server-config"]) as yml:
        cluster = yaml.load(yml, Loader=yaml.FullLoader)

workdir: config["project-folder"]

wildcard_constraints:
    rawsamples="|".join(rawsamples),
    samples="|".join(samples),
    reads1_trim="|".join(reads1_trim),
    reads2_trim="|".join(reads2_trim)
    
##### Complete the input configuration
config["report-script"] = config["pipeline-folder"]+"/scripts/finalReport.R"

##### Singularity container #####
config["singularity"] = {}
config["singularity"]["fastp"] = "docker://fischuu/fastp:0.20.1"
config["singularity"]["r-gbs"] = "docker://fischuu/r-gbs:4.2.1-0.7"
config["singularity"]["star"] = "docker://fischuu/star:2.7.5a"

##### Print the welcome screen #####
print("#################################################################################")
print("##### Welcome to the Snakebite-LabQC pipeline")
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
