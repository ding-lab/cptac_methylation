##########################################################################################
### author: Sunantha Sethuraman <s.sethuraman@wustl.edu>
### usage: Rscript annotation_liftOver_hg19tohg38.R
### created: 08/07/2018
### description: Lifts over the annotation file for methylation data from hg19 to hg38
#########################################################################################

## ----Load libraries---------------------------------------------------------------------

library(rtracklayer)
library(GenomicRanges)
library(IlluminaHumanMethylationEPICanno.ilm10b2.hg19)
library(IlluminaHumanMethylationEPICmanifest)


## ----Fetch chain information------------------------------------------------------------

ch <- import.chain("hg19ToHg38.over.chain")


###----Define a new function--------------------------------------------------------------

grtodf <- function(gr) {
	df <- data.frame(chromosome=seqnames(gr),
	starts=start(gr),
	ends=end(gr),
	Locus=names(gr),
	strands=strand(gr),
	stringsAsFactors=F)
	return(df)
	}

## ----Read annotation and identify columns that need lift over---------------------------

annEPIC= as.data.frame(getAnnotation(IlluminaHumanMethylationEPICanno.ilm10b2.hg19))
annEPIC$Locus <- rownames(annEPIC)

no_coord <- c("Name", "Probe_rs", "Probe_maf", "CpG_rs", "CpG_maf", "SBE_rs", "SBE_maf", 
				"Relation_to_Island", "UCSC_RefGene_Group", "DMR", "X450k_Enhancer",
				"Regulatory_Feature_Group", "GencodeBasicV12_NAME",	"GencodeBasicV12_Accession",
				"GencodeBasicV12_Group", "GencodeCompV12_NAME", "GencodeCompV12_Accession", 
				"GencodeCompV12_Group", "DNase_Hypersensitivity_Evidence_Count", "OpenChromatin_Evidence_Count",
				"TFBS_Evidence_Count", "Methyl27_Loci", "Methyl450_Loci", "Random_Loci")

annEPIC_nocoord <- annEPIC[,c("Locus", no_coord)]

## ----Process all coordinate containing columns------------------------------------------

# Process the first few columns

primary <- annEPIC[,c("Locus", "chr", "pos", "pos", "strand")]
colnames(primary) <- c("Locus", "Chromosome", "Start", "End", "Strand")
temp <- makeGRangesFromDataFrame(primary)
names(temp) <- primary$Locus
genome(temp) <- "hg19"
seqlevelsStyle(temp) <- "UCSC"
temp <- unlist(liftOver(temp, ch))
temp <- grtodf(temp)
primary <- temp[,c("chromosome", "starts", "Locus", "strands")]
colnames(primary) <- c("chr", "pos", "Locus", "strand")

# Process other columns with coordinate information

coord_cols <- c("Islands_Name", "Phantom4_Enhancers", "Phantom5_Enhancers", "HMM_Island",
				"Regulatory_Feature_Name", "DNase_Hypersensitivity_NAME", "OpenChromatin_NAME", "TFBS_NAME")

liftcols <- function(column) {
	temp <- annEPIC[,c("Locus", "chr", column, "strand")]
	prefix <- gsub(":.*$", "", temp[,column])
	names(prefix) <- temp[,"Locus"]
	prefix <- prefix[prefix != ""]
	temp[,column] <- gsub("^.*:", "", temp[,column])
	temp$Start <- gsub("-.*$", "", temp[,column])
	temp$End <- gsub("^.*-", "", temp[,column])
	temp <- temp[temp$Start != "",]
	temp <- makeGRangesFromDataFrame(temp)
	names(temp) <- names(prefix)
	genome(temp) <- "hg19"
	seqlevelsStyle(temp) <- "UCSC"
	temp <- unlist(liftOver(temp, ch))
	temp <- grtodf(temp)
	prefix <- prefix[temp$Locus]
	temp$column <- paste0(prefix, ":", temp$starts, "-", temp$ends)
	temp <- temp[,c("Locus", "column")]
	colnames(temp)[2] <- column
	return(temp)
	}
	
lifted <- lapply(coord_cols, liftcols)


## ----Merge dataframes progressively-----------------------------------------------------


ann <- merge(primary, annEPIC_nocoord, by = "Locus", all.x=TRUE)

for(i in 1:length(lifted)) {
	ann <- merge(ann, lifted[[i]], by = "Locus", all.x=TRUE)
	}

write.table(ann, "annotation_liftedOver_hg38.txt", row.names=F, sep="\t", quote=F)
