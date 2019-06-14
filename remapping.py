#!/usr/bin/env python
# coding: utf-8

import pandas as pd

## Read in Illumina EPIC Manifest
# Drop columns that are not helpful
# Rename columns with "_on37" when the info holds true on GRCh37
ori = pd.read_csv("./anno/annotation_liftedOver_hg38.txt", sep="\t", dtype=str)
ori_drop = ["strand", "chr", "pos", "CpG_rs", "CpG_maf", "SBE_rs", "SBE_maf", "GencodeBasicV12_NAME", "GencodeBasicV12_Accession", "GencodeBasicV12_Group", "GencodeCompV12_NAME", "GencodeCompV12_Accession", "GencodeCompV12_Group", "Islands_Name", "Phantom4_Enhancers"]
ori = ori.drop(ori_drop, axis=1)
ori.columns = ['Locus', 'Name', 'Probe_rs', 'Probe_maf',
       'Relation_to_Island_on37', 'UCSC_RefGene_Group_on37', 'DMR_on37', 'X450k_Enhancer_on37',
       'Regulatory_Feature_Group_on37', 'DNase_Hypersensitivity_Evidence_Count_on37',
       'OpenChromatin_Evidence_Count_on37', 'TFBS_Evidence_Count_on37', 'Methyl27_Loci',
       'Methyl450_Loci', 'Random_Loci', 'Phantom5_Enhancers_on37', 'HMM_Island_on37',
       'Regulatory_Feature_Name_on37', 'DNase_Hypersensitivity_NAME_on37',
       'OpenChromatin_NAME_on37', 'TFBS_NAME_on37']


## Read in InfiniumAnnotation
new = pd.read_csv("./anno/EPIC.hg38.manifest.tsv.gz", sep="\t", dtype=str)
new_keep = ["CpG_chrm", "CpG_beg", "CpG_end", "probe_strand", "probeID", "gene", "gene_HGNC", "mapQ_A", "mapQ_B", "MASK_mapping", "MASK_typeINextBaseSwitch", "MASK_sub30_copy", "MASK_extBase", "MASK_snp5_GMAF1p", "MASK_general"]
new = new[new_keep]

## Read in InfiniumAnnotation-GencodeV22
gencode = pd.read_csv("./anno/EPIC.hg38.manifest.gencode.v22.tsv.gz", sep="\t", dtype=str)
gencode_drop = ["CpG_chrm", "CpG_beg", "CpG_end", "probe_strand"]
gencode = gencode.drop(gencode_drop, axis=1)


## Merge annotation to EPIC Manifest
add = new.merge(gencode, left_on="probeID", right_on="probeID")
final = ori.merge(add, left_on="Name", right_on="probeID")
final.to_csv("./anno/annotation_remap_hg38.txt", sep="\t", index=False)

