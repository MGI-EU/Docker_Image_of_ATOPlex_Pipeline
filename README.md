# Docker Image of ATOPlex Pipeline

This image has been tested by MGI EU team on 2021-04-06 based on the pipeline with the original distribution [SARS-CoV-2_Multi-PCR_v1.0](https://github.com/MGI-tech-bioinformatics/SARS-CoV-2_Multi-PCR_v1.0), version 1.0 .

The latest version will be automatically followed when building the image.

## Introduction

This pipeline could accurately and efficiently identify SARS-CoV-2 reads from multiplex PCR sequencing data, and report the infection status of sequencing samples with positive/negative/uncertain label. The pipeline could also get the variant information such as SNP/INDEL and generate the consensus sequence. (From: [SARS-CoV-2_Multi-PCR_v1.0](https://github.com/MGI-tech-bioinformatics/SARS-CoV-2_Multi-PCR_v1.0))

![Image](https://github.com/MGI-EU/Docker_Image_of_ATOPlex_Pipeline/blob/main/assets/Pipeline.png)

## Requirements

- Docker: >=v20.10.5
- Sudo permission (for Docker)

### Supplementary

Normally, these requirements will be automatically installed after building dockerfile.

- Perl: >=v5.22.0
- Python: >=v3.4.3
  - Library: pysam, pandas, openpyxl
- R: >=v3.3.2
  - Packages: Cairo

- Softwares for data quality control:
  - seqtk v1.2 (<https://github.com/lh3/seqtk>)
  - SOAPnuke v1.5.6 (<https://github.com/BGI-flexlab/SOAPnuke>)

- Software for alignment and bam file statistics:
  - BWA v0.7.16 (<https://github.com/lh3/bwa>)
  - Samtools v1.3 (<https://github.com/samtools/samtools>)
  - bamdst v1.0.6 (<https://github.com/shiquan/bamdst>)

- Software for variant calling:
  - freebayes v1.3.0 (<https://github.com/ekg/freebayes>)

- Other required softwares:
  - bedtools v2.26.0 (<https://bedtools.readthedocs.io/en/latest/>)
  - bcftools v1.6 (<https://github.com/samtools/bcftools/>)
  - tabix v1.9 (<https://github.com/samtools/tabix/>)
  - bgzip v1.9 (<https://github.com/samtools/tabix/>)
  - mosdepth v0.2.9 (<https://github.com/brentp/mosdepth>)

## Installation

Users should install Docker and obtain the permission to build dockerfile before using this pipeline.

```shell
git clone https://github.com/MGI-EU/Docker_Image_of_ATOPlex_Pipeline.git
cd Docker_Image_of_ATOPlex_Pipeline
docker build -t cov2multipcr:v1.0 .
```

## Usage

### Resource

Required minimum memory: 6g

### Step 1. Prepare `input.json` and `sample.list` files

The example of `input.json` and `sample.list` files can be found in `config` folder in this repo.

- In `input.json` file, users should set following parameters:
  - FqType, sequencing type(PE100/SE50).
  - sample_list, sample list file(sample_name/barcode_information/data_path).
  - workdir, analysis result directory.
  - SplitData, downsampling size of each sample(1G/1M/1K).
  - SOAPnuke_param, param of SOAPnuke.
  - freebayes_param, param of freebayes.In particular,the parameter '-p 1' is necessary.
  - consensus_depth, threshold of point depth for consensus sequence.[1~30.Default:30]
  - python3, path to python3.
  - python3_lib, path to python3 library.
  - Rscript, path to Rscript.
  - R_lib, path to R library.
  - tools(bwa,samtools....), path to this tool.

- In `sample.list` file, the data path should be the sample folder location in docker environment. The sample file should end with `_<barcode>_1.fq.gz` and `_<barcode>_2.fq.gz`, or `_<barcode>.fq.gz`. Here is `sample.list` example (tab-delimited):

  ```Text
  Sample1	<barcode1>	/root/data/sample1_Data_Folder/
  Sample2	<barcode2>	/root/data/Sample2_Data_Folder/
  ```

**Note that different samples must have different data path or barcode.**

### Step 2. Enter docker env

```shell
sudo docker run -it -v your/data/path/:/root/data/ -v your/config/path/:/root/config/ -v your/result/path/:/root/result/ cov2multipcr:v1.0
```

### Step 3. Run analysis

After starting and entering docker environment, run follwing commands to do analysis.

```shell
python3 /root/repos/SARS-CoV-2_Multi-PCR_v1.0/bin/Main_SARS-CoV-2.py -i /root/config/input.json
#cd /root/result
nohup sh /root/result/main.sh &
```

### Step 4. Collect results

(Note that we've deleted large output and sensitive files from example in this repo.)

After running, exit docker environment. The results are stored in following files:

- uality control result

```text
your/result/path/*/05.Stat/QC.xlsx
```

- dentification result

```text
your/result/path/*/05.Stat/Identification.xlsx
```

- ariant calling result

```text
your/result/path/*/05.Stat/*.vcf.gz
your/result/path/*/05.Stat/*.vcf.anno
```

- TML report

```text
your/result/path/*/05.Stat/*.html
```

## Updates

April 12th, 2021

1. Update `input.json`. Use fixed file path.
2. Debug `Dockerfile`.
3. Update `README.md`.

April 6th, 2021

1. Create repository.

## FAQ

## Reference

- <https://github.com/MGI-tech-bioinformatics/SARS-CoV-2_Multi-PCR_v1.0>

## Contribution

## License
