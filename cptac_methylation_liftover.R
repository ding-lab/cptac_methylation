##########################################################################################
### author: Sunantha Sethuraman <s.sethuraman@wustl.edu>
### usage: Rscript cptac_methylation_liftover.R <input dir>
### created: 08/07/2018
### description: Lifts over processed methylation files from hg19 to hg38
#########################################################################################

###----Process arguments------------------------------------------------------------------

args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("At least one argument (input directory) must be supplied.n", call.=FALSE)
} else if (length(args)> 1) {
  # will ignore any additional arguments passed
  print("More than one argument passed, only the first one will be used")
}

###----Create a new directory-------------------------------------------------------------

WORKDIR <- args[1]
dir.create(file.path(WORKDIR, "../Processed_hg38_remap"))

###----Read in hg38 annotation -----------------------------------------------------------

ann <- read.csv("/diskmnt/Projects/Users/wliang/Methylome_CPTAC/04_Pipeline/00_Scripts/annotation_remap_hg38.txt", stringsAsFactors=F, sep= "\t")

###----Change annotation information for all output files --------------------------------

filenames <- list.files(WORKDIR, pattern="*.csv")
filenames <- filenames[filenames != "Probewise_pValues.csv"] # Remove the only non-sample file

for(filename in filenames) {
	temp <- read.csv(paste0(WORKDIR, "/", filename), stringsAsFactors=F)
	col_order <- colnames(ann)
	temp <- temp[,c("Locus", "Beta")]
	temp <- merge(temp, ann, by= "Locus")
	write.csv(temp, paste0(WORKDIR, "/../Processed_hg38_remap/", filename), row.names=F)
	}
