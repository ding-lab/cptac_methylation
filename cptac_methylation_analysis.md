CPTAC Methylation analysis
==========================

### Sunantha Sethuraman

------------------------------------------------------------------------

Processing description
----------------------

The raw data from Illumina's EPIC methylation arrays were available as
IDAT files from the CPTAC consortium. The methylation analysis was
performed using the cross-package workflow “methylationArrayAnalysis”
(<https://master.bioconductor.org/packages/release/workflows/html/methylationArrayAnalysis.html>)
available on Bioconductor. In brief, the raw data files (IDAT files)
were processed to obtain the methylated (M) and unmethylated (U) signal
intensities for each locus. The processing step included an unsupervised
normalization step called functional normalization that has been
previously implemented for Illumina 450K methylation arrays (Fortin, JP,
Aurélie Labbe, Mathieu Lemire, and BW Zanke. 2014. “Functional
normalization of 450k methylation array data improves replication in
large cancer studies.” Genome Biology 15 (503):1–17). A detection p
value was also calculated for each locus, and this p value captured the
quality of detection at the locus with respect to negative control
background probes included in the array. Loci having common SNPs (with
MAF &gt; 0.01), as per dbSNP build 132 through 147 via the UCSC
snp132common track through snp147common track, were removed from further
analysis. Beta values were calculated as M/(M+U), that is equal to the
fraction methylated for each locus. Beta values of loci whose detection
p values were &gt; 0.01 were assigned NA in the output file. All loci
are annotated with the annotation information from
‘MethylationEPIC\_v-1-0\_B2.csv’ from the zip archive
‘infinium-methylationepic-v1-0-b2-manifest-file-csv.zip’ from
www.illumina.com through the
IlluminaHumanMethylationEPICanno.ilm10b2.hg19 package on Bioconductor.

------------------------------------------------------------------------

Data with hg19 annotaion
------------------------

During the initial analysis, **annotation steps used hg19 coordinates**
(Bioconductor package:IlluminaHumanMethylationEPICanno.ilm10b2.hg19).
This data is available in the following URLs:

1.  Pilot:
    <https://cptc-xfer.uis.georgetown.edu/aspera/user/?B=%2FMethylation_CPTAC3%2Fpilot_CPTAC3_Epic_Methylation>
2.  Batch 2 and Batch 3:
    <https://cptc-xfer.uis.georgetown.edu/aspera/user/?B=%2FMethylation_CPTAC3%2FCPTAC3_Epic_Methylation_Batch2-Batch3>
3.  Batch 4:
    <https://cptc-xfer.uis.georgetown.edu/aspera/user/?B=%2FMethylation_CPTAC3%2FCPTAC3_Epic_Methylation_Batch4>

------------------------------------------------------------------------

Data with hg38 annotation
-------------------------

For subsequent analysis, the **annotation coordinates were lifted over
from the hg19 build to the hg38 build**. It is important to note that
the data was not re-processed to make this change. This change was
effected using two steps:

1.  Editing the annotation information from the
    IlluminaHumanMethylationEPICanno.ilm10b2.hg19 package using the
    script *annotation\_liftOver\_hg19tohg38.R*.
2.  Replacing the annotation in the output files from the initial
    analysis with the new annotation generated in step 1. Refer to
    script *cptac\_methylation\_liftover.R*.

Only the coordinates were lifted over in step 1. Therefore, it is
possible that some of the annotations (for example: DNase
hypersensitivity sites, CpG islands) might no longer hold true in hg38.

------------------------------------------------------------------------
