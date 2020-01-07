
## ----Load libraries----

library(limma)
library(minfi)
library(IlluminaHumanMethylationEPICanno.ilm10b2.hg19)
library(IlluminaHumanMethylationEPICmanifest)
library(RColorBrewer)
library(missMethyl)
library(matrixStats)
library(Gviz)
library(DMRcate)
library(stringr)

## ----Process arguments---------------------------------------------

## usage: Rscript cptac_methylation_v1.0.R <input dir>

args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("At least one argument (input directory) must be supplied.n", call.=FALSE)
} else if (length(args)> 1) {
  # will ignore any additional arguments passed
  print("More than one argument passed, only the first one will be used")
}

###----Read sample information---------------------------------------------

WORKDIR <- args[1]
dir.create(file.path(WORKDIR, "Processed"))
targets <- read.metharray.sheet(WORKDIR, pattern= "*SampleSheet\\.csv$")

## ----Prepare annotations---------------------------------------------
# get the EPIC annotation data
annEPIC= getAnnotation(IlluminaHumanMethylationEPICanno.ilm10b2.hg19)

## ----Read data------------------------------------------------------------
# read in the raw data from the IDAT files
rgSet <- read.metharray.exp(targets = targets)

# give the samples descriptive names
sampleNames(rgSet) <- targets$Sample_ID

## ----Calculate p-values------------------------------------------------------------
# calculate the detection p-values
detP <- detectionP(rgSet)

## ----Normalization----------------------------------------------------------------

## use preprocessFunnorm for tumor/normal pairs
# normalize the data; this results in a GenomicRatioSet object

mSetSq <- preprocessFunnorm(rgSet) 

## ----p-value filter---------------------------------------------------------
# ensure probes are in the same order in the mSetSq and detP objects
detP <- detP[match(featureNames(mSetSq),rownames(detP)),] 
mSetSqFlt <- mSetSq

## ----SNP filter-----------------------------------------------------------
# remove probes with SNPs at CpG site

mSetSqFlt <- dropLociWithSnps(mSetSqFlt, snps = c("CpG", "SBE"), maf = 0.01, snpAnno = NULL)
keep <- rownames(mSetSqFlt)
detP <- detP[keep,]

## ----getvals-------------------------------------------------------------
# calculate M-values for statistical analysis
mVals <- getM(mSetSqFlt)
#head(mVals[,1:5])

bVals <- getBeta(mSetSqFlt)
#head(bVals[,1:5])

# set values for loci with detection p value > 0.01 as NA

for(i in 1:ncol(detP)) {
	loci_na <- which(detP[,i] > 0.01)
	if(length(loci_na) >0) {
		mVals[loci_na,i] <- NA
		bVals[loci_na,i] <- NA
		}
	}

## ----Annotate and write separate files for each sample----------------------------------

annEPICSub <- annEPIC[match(rownames(bVals),annEPIC$Name),
                      c(1:4,12:19,24:ncol(annEPIC))]
                      
for (i in 1:ncol(bVals)) {
	temp <- as.data.frame(bVals[,i])
        print(temp)
	samp <- colnames(bVals)[i]
        print(samp)
	temp <- merge(temp, annEPICSub, by="row.names")
        print(temp)
	colnames(temp)[1:2] <- c("Locus", "Beta")
	index <- which(targets$Sample_ID == colnames(bVals)[i])
        print(index)
        print(targets$Sample_type[index])
	if (targets$Sample_type[index] == "tumor") {
		status = "T"} else if(targets$Sample_type[index] == "blood_normal") {
		status = "N"} else if (targets$Sample_type[index] == "tissue_normal") {
                status = "A"}
        filename <- paste0(WORKDIR, "/Processed/", targets$Subject_ID[index],".", status, ".", targets$Sample_ID ,".csv")[index]
        print(filename)
	write.csv(temp, file = filename, row.names=F)
	}

write.csv(detP, paste0(WORKDIR, "/Processed/", "Probewise_pValues.csv"))
	
