CPTAC Methylation analysis
==========================

#### Author: Sunantha Sethuraman
#### Author: Wen-Wei Liang

Release
--------------

*Jun 19, 2019:* Version 1.1 released.
- Reannotated probe by `InfiniumAnnotation` (Ref 2).
- Improved filenaming: Adjacent normal were named as `.A`. Blood normal were named as `.N`.
- Improved filenaming: Unique sample ID were added.

*May 30, 2018:* Version 1.0 released.
- Probe annotation were liftover to hg38


Run pipeline
-----------------


```
## Get file description from github and set up environment 
wget https://raw.githubusercontent.com/ding-lab/CPTAC3.catalog/master/CPTAC3.Catalog.dat
wget https://raw.githubusercontent.com/ding-lab/CPTAC3.catalog/master/BamMap/katmai.BamMap.dat
conda env create -f methyl-pipeline.yml
conda activate methyl-pipeline

## Make input
python make_pipeline_input.py ${Path to processing folder} ${Batch_name} ${TXT with file names and UUID}

## Softlink IDAT files
for i in `cat ../katmai.BamMap.dat | grep Methylation | awk -F "\t" '{OFS="\t"; print $6}'`; do ln -s $i ${Path to processing folder}; done

## Pipeline
tmux new-session -d -s methylation "source activate methyl-pipeline; Rscript cptac_methylation_v1.1.R ${Path to processing folder} |& tee tmux.methylation.log"

tmux new-session -d -s remapping "source activate methyl-pipeline; Rscript cptac_methylation_liftover.R ${Path to processing folder}/Processed |& tee tmux.mapping.log"
```


Processing description
----------------------

The raw data from Illumina's EPIC methylation arrays were available as
IDAT files from the CPTAC consortium. The methylation analysis was
performed using the cross-package workflow [methylationArrayAnalysis](https://master.bioconductor.org/packages/release/workflows/html/methylationArrayAnalysis.html)
available on Bioconductor. In brief, the raw data files `IDAT files`
were processed to obtain the methylated (M) and unmethylated (U) signal
intensities for each locus. The processing step included an unsupervised
normalization step called functional normalization that has been
previously implemented for Illumina 450K methylation arrays (Ref 1). A detection p
value was also calculated for each locus, and this p value captured the
quality of detection at the locus with respect to negative control
background probes included in the array. Loci having common SNPs (with
MAF > 0.01), as per dbSNP build 132 through 147 via the UCSC
snp132common track through snp147common track, were removed from further
analysis. Beta values were calculated as `M/(M+U)`, that is equal to the
fraction methylated for each locus. Beta values of loci whose detection
p values were > 0.01 were assigned NA in the output file. All loci
are annotated with the EPIC Manifest from
`MethylationEPIC_v-1-0_B2.csv` from the zip archive
`infinium-methylationepic-v1-0-b2-manifest-file-csv.zip` from [Illumina](www.illumina.com) through the `IlluminaHumanMethylationEPICanno.ilm10b2.hg19` package on Bioconductor.

To map EPIC arrays to GRCh38 assembly, all probe are reannotated by annotation 
information from [InfiniumAnnotation](http://zwdzwd.github.io/InfiniumAnnotation) (Ref 2) through the following steps:

1. Getting the annotation information `anno/annotation_liftedOver_hg38.txt` from `IlluminaHumanMethylationEPICanno.ilm10b2.hg19` package using script `annotation_liftOver_hg19tohg38.R`.
2. Remapping the probes with GRCh38 information from `InfiniumAnnotation` using script `remapping.py`.
3. Replacing the annotation in output files with the new annotation `anno/annotation_remap_hg38.txt` generated in step 2. Refer to script cptac_methylation_liftover.R.


![flowchart](https://github.com/ding-lab/cptac_methylation/blob/master/flowchart.png)


Reference
---------
1. Fortin, JP, Aurélie Labbe, Mathieu Lemire, and BW Zanke. 2014. “Functional
normalization of 450k methylation array data improves replication in
large cancer studies.” Genome Biology 15 (503):1–17
2. Zhou W, Laird PW and Shen H. 2017. "Comprehensive characterization, annotation and innovative use of Infinium DNA Methylation BeadChip probes." Nucleic Acids Research 45 (4):e22


Sample nomenclature
-------------------

The samples follow the naming system `[SubjectID].[T , N, or A].[SampleID].csv`,
where T, N, or A specifies whether it is a tumor, blood normal or a tissue normal sample (for
example: C3N-01375.T.CPTXXXXXXXXXX.csv). SampleID is a unique
identifier of the sample.


Column headding
-------------------

Column headding of output file is listed below. 


| Column                                | Content from Illumina EPIC Manifest                                                               | Status  | Replacement              | Content from InfiniumAnnotation                                                                                                                      |
| ----                                  | ----                                                                                              | ----    | ---                      | ---                                                                                                                                                  |
| Locus                                 | The IlmnID                                                                                        | Keep    | -                        | -                                                                                                                                                    |
| chr                                   | Chromosome containing the CpG (Build 37)                                                          | Replace | CpG_chrm                 | Map to Build 38                                                                                                                                      |
| pos                                   | Chromosomal coordinates of the CpG (Build 37)                                                     | Replace | CpG_beg and CpG_end      | Map to build 38                                                                                                                                      |
| strand                                | The Forward (F) or Reverse (R) designation of the Design Strand                                   | Keep    | -                        | -                                                                                                                                                    |
| Probe_rs                              | rsid(s) of SNP(s) located in the probe                                                            | Keep    | -                        | -                                                                                                                                                    |
| Probe_maf                             | Minor allele frequency of SNP(s)                                                                  | Keep    | -                        | -                                                                                                                                                    |
| Random_Loci                           | CpG loci chosen randomly by consortium members during the design process are marked “True”        | Keep    | -                        | -                                                                                                                                                    |
| Methyl27_Loci                         | CpG’s carried over from the HumanMethylation27 array (92% carryover)                              | Keep    | -                        | -                                                                                                                                                    |
| Methyl450_Loci                        | CpG’s carried over from the HumanMethylation450 array (94% carryover)                             | Keep    | -                        | -                                                                                                                                                    |
| UCSC_RefGene_Group_on37                    | Gene region feature category describing the CpG position, from UCSC.                              | Keep    | -                        | -                                                                                                                                                    |
| Relation_to_Island_on37               | The location of the CpG relative to the CpG island                                                | Keep    | -                        | -                                                                                                                                                    |
| Phantom5_Enhancers_on37               | Classifications from the FANTOM 5 enhancers as a low- or high-CpG density region                  | Keep    | -                        | -                                                                                                                                                    |
| DMR_on37                              | Differentially methylated regions (experimentally determined)                                     | Keep    | -                        | -                                                                                                                                                    |
| X450k_Enhancer_on37                   | Predicted enhancer elements as annotated in the original 450K design                              | Keep    | -                        | -                                                                                                                                                    |
| HMM_Island_on37                       | Hidden Markov Model Islands. Chromosomal map coordinates of computationally predicted CpG islands | Keep    | -                        | -                                                                                                                                                    |
| Regulatory_Feature_Name_on37          | Chromosomal map coordinates of the regulatory feature                                             | Keep    | -                        | -                                                                                                                                                    |
| Regulatory_Feature_Group_on37         | Description of the regulatory feature referenced in “Regulatory_Feature_Name”                     | Keep    | -                        | -                                                                                                                                                    |
| GencodeBasicV12_NAME                  | Target gene name(s), from the basic GENECODE build                                                | Replace | geneNames                | Gene models follows GENCODE version 22 (hg38).                                                                                                       |
| GencodeBasicV12_Accession             | The basic GENECODE accession number(s) of the target transcript(s)                                | Replace | transcriptIDs            | Gene models follows GENCODE version 22 (hg38).                                                                                                       |
| GencodeBasicV12_Group                 | Gene region feature category describing the CpG position, from basic GENECODE                     | Remove  | -                        | -                                                                                                                                                    |
| GencodeCompV12_NAME                   | Target gene name(s), from the complete GENECODE build                                             | Remove  | -                        | -                                                                                                                                                    |
| GencodeCompV12_Accession              | The complete GENECODE accession number(s) of the target transcript(s)                             | Remove  | -                        | -                                                                                                                                                    |
| GencodeCompV12_Group                  | Gene region feature category describing the CpG position, from complete GENECODE                  | Remove  | -                        | -                                                                                                                                                    |
| DNase_Hypersensitivity_NAME_on37           | Chromosomal coordinates of the DNase hypersensitive region from ENCODE                            | Keep    | -                        | -                                                                                                                                                    |
| DNase_Hypersensitivity_Evidence_Count_on37 | Number of supporting experimental evidence for DNase hypersensitive region from ENCODE            | Keep    | -                        | -                                                                                                                                                    |
| OpenChromatin_NAME_on37                    | Chromosomal coordinates of open chromatin region from ENCODE                                      | Keep    | -                        | -                                                                                                                                                    |
| OpenChromatin_Evidence_Count_on37          | Number of supporting experimental evidence for open chromatin region from ENCODE                  | Keep    | -                        | -                                                                                                                                                    |
| TFBS_NAME_on37                             | Chromosomal coordinates of transcription factor binding site region from ENCODE                   | Keep    | -                        | -                                                                                                                                                    |
| TFBS_Evidence_Count_on37                   | Number of supporting experimental evidence for transcription factor bind site region from ENCODE  | Keep    | -                        | -                                                                                                                                                    |
| -                                     | -                                                                                                 | Add     | transcriptTypes          | gene annotation based on GENCODE v22                                                                                                                 |
| -                                     | -                                                                                                 | Add     | genesUniq                | gene annotation based on GENCODE v22                                                                                                                 |
| -                                     | -                                                                                                 | Add     | distToTSS                | gene annotation based on GENCODE v22                                                                                                                 |
| -                                     | -                                                                                                 | Add     | CGI                      | CpG island definition based on UCSC genome browser                                                                                                   |
| -                                     | -                                                                                                 | Add     | CGIposition              | CpG island definition based on UCSC genome browser                                                                                                   |
| -                                     | -                                                                                                 | Add     | mapQ_A                   | mapping quality score, 0-60, with 60 being the best.                                                                                                 |
| -                                     | -                                                                                                 | Add     | mapQ_B                   | mapping quality score, 0-60, with 60 being the best.                                                                                                 |
| -                                     | -                                                                                                 | Add     | MASK.mapping             | whether the probe is masked for mapping reason.                                                                                                      |
| -                                     | -                                                                                                 | Add     | MASK.typeINextBaseSwitch | whether the probe has a SNP in the extension base that causes a color channel switch from the official annotation                                    |
| -                                     | -                                                                                                 | Add     | MASK.sub30.copy          | whether the 30bp 3'-subsequence of the probe is non-unique.                                                                                          |
| -                                     | -                                                                                                 | Add     | MASK.extBase             | probes masked for extension base inconsistent with specified color channel (type-I) or CpG (type-II) based on mapping.                               |
| -                                     | -                                                                                                 | Add     | MASK.snp5.GMAF1p         | whether 5bp 3'-subsequence (including extension for typeII) overlap with any of the SNPs with global MAF >1%.                                        |
| -                                     | -                                                                                                 | Add     | MASK.general             | recommended general purpose masking merged from "MASK.sub30.copy", "MASK.mapping", "MASK.extBase", "MASK.typeINextBaseSwitch" and "MASK.snp5.GMAF1p" |

