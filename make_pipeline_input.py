import sys
import pandas as pd

path = sys.argv[1]
out = sys.argv[2]

df = pd.read_csv("../09_Pipeline/CPTAC3.Catalog.dat", sep="\t")
df = df[df["data_format"]=="IDAT"]
df["Sentrix_ID"] = df["filename"].str.split("_").str[0]
df["Sentrix_Position"] = df["filename"].str.split("_").str[1]
df = df.rename(columns = {"aliquot":"Sample_ID", "case":"Subject_ID", "disease":"Tumor_Type", "short_sample_type":"Sample_type"})
df = df[["Sentrix_ID", "Sentrix_Position", "Sample_ID", "Subject_ID", "Tumor_Type", "Sample_type"]]
df = df.drop_duplicates()
df.to_csv(path+"Input_"+out+"_SampleSheet.csv", index=False)
