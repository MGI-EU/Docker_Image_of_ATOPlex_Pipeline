# Docker Image of ATOPlex Pipeline

This image has been tested by MGI EU team on 2021-05-20 based on the pipeline with the original distribution [SARS-CoV-2_Multi-PCR_v1.0](https://github.com/MGI-tech-bioinformatics/SARS-CoV-2_Multi-PCR_v1.0), version 1.0 .

The latest version will be automatically followed when building the image.

## 1. Introduction

This pipeline could accurately and efficiently identify SARS-CoV-2 reads from multiplex PCR sequencing data, and report the infection status of sequencing samples with positive/negative/uncertain label. The pipeline could also get the variant information such as SNP/INDEL and generate the consensus sequence. (From: [SARS-CoV-2_Multi-PCR_v1.0](https://github.com/MGI-tech-bioinformatics/SARS-CoV-2_Multi-PCR_v1.0))

![Pipeline](https://github.com/MGI-EU/Docker_Image_of_ATOPlex_Pipeline/blob/main/assets/Pipeline.png)

## 2. Overview

### 2.1. Demo

We've provided a demo in `example` folder.

- Demo data

  Inputs comprise of config files and input data, they are in `example/config` and `example/data` respectively. For demo, users should not change any content in any file in these two folders.
  
- Demo execution

  ```shell
  git clone https://github.com/MGI-EU/Docker_Image_of_ATOPlex_Pipeline.git;
  cd Docker_Image_of_ATOPlex_Pipeline;
  docker build -t cov2multipcr:v1.0 .;
  cd example;
  rm -rf results/*;
  sudo docker run -it -v data/:/root/data/ -v config/:/root/config/ -v results/:/root/result/ cov2multipcr:v1.0
  python3 /root/repos/SARS-CoV-2_Multi-PCR_v1.0/bin/Main_SARS-CoV-2.py -i /root/config/input.json
  sh /root/result/main.sh
  ```

- Demo output

  Users can find all intermediate files and final report files in `example/results` folder (or any other mounted resut's folder). There are also two files (unused) in `example` folder where we execute the docker image. (We've deleted `01.Clean/Raw_Sample1_*.fq.gz` in sample's result folder because they're linux softlink files and can't be recognized by github desktop)

  For assembled consensus genome FASTA file, users can find it in `example/resuts/result/Sample1/05.Stat/Sample1.Consensus.fa`.

  For HTML visualized report files, users can find them in `example/resuts/result/Sample1/05.Stat/Sample1_en.html`.

  ![DemoResutsShow](https://github.com/MGI-EU/Docker_Image_of_ATOPlex_Pipeline/blob/main/assets/DemoResutsShow.png)

### 2.2. Latest update

From [original repository](https://github.com/MGI-tech-bioinformatics/SARS-CoV-2_Multi-PCR_v1.0):

1. Use variant annotation excel instead of VCF file in HTML report
2. Optimized depth distribution SVG in HTML report.
3. Mark the primer base quality as 0 instead of removing primer sequence
4. Update primer sequence information
5. Reduce software running time
6. Upload a docker version of this software

## 3. Requirements

- Docker: >=v20.10.5
- Sudo permission (for Docker)

### 3.1. Supplementary

Normally, these requirements will be automatically installed after building dockerfile.

- Perl: >=v5.22.0
- Python: >=v3.4.3
  - Library: pysam, pandas, openpyxl
- R: >=v3.3.2
  - Packages: Cairo

- Softwares for data quality control:
  - seqtk 1.3-r117-dirty (<https://github.com/lh3/seqtk>)
  - SOAPnuke v1.5.6 (<https://github.com/BGI-flexlab/SOAPnuke>)

- Software for alignment and bam file statistics:
  - BWA v0.7.16 (<https://github.com/lh3/bwa>)
  - Samtools v1.3 (<https://github.com/samtools/samtools>)
  - bamdst v1.0.9 (<https://github.com/shiquan/bamdst>)

- Software for variant calling:
  - freebayes v1.3.4 (<https://github.com/ekg/freebayes>)

- Other required softwares:
  - bedtools v2.26.0 (<https://bedtools.readthedocs.io/en/latest/>)
  - bcftools v1.6 (<https://github.com/samtools/bcftools/>)
  - tabix 1.12-38-g818008a (<https://github.com/samtools/tabix/>)
  - bgzip v1.9 (<https://github.com/samtools/tabix/>)
  - mosdepth v0.2.9 (<https://github.com/brentp/mosdepth>)

## 4. Installation

Users should install Docker and obtain the permission to build dockerfile before using this pipeline.

```shell
git clone https://github.com/MGI-EU/Docker_Image_of_ATOPlex_Pipeline.git
cd Docker_Image_of_ATOPlex_Pipeline
docker build -t cov2multipcr:v1.0 .
```

## 5. Usage

### 5.1. Hardware Requirement

#### 5.1.1. Memory Requirement

Designed required minimum memory: 6GB

The actual necessary memory for each sample is 2GB for one sample with 3.2M PE100 reads. If users want higher degree of parallelism, they can modify the `--mem` parameter in `main.sh` (see usage [Step3](#step-3-run-analysis)) for pipeline step2 and step6.

#### 5.1.2. Threads and Parallelism

The pipeline comprises two levels of parallelism.

The first level is sample-level-parallelism, controlled by a customized Perl script. Users can provide any number of sample in the smaple list. The script will help manage the analysis automatically.

The second level is tool-level-parallelism, controlled by the parameters of each integrated software, such as BWA, samtools, mosdepth, etc. The thread number has been set to 3, a fixed value. Users can modify the generated shell script for each pipeline step, change the value according to their needs.

### 5.2. Operation

#### 5.2.1. Step 1. Prepare `input.json` and `sample.list` files

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

#### 5.2.2. Step 2. Enter docker env

```shell
sudo docker run -it -v /your/data/absolute/path/:/root/data/ -v /your/config/absolute/path/:/root/config/ -v /your/result/absolute/path/:/root/result/ cov2multipcr:v1.0
```

#### 5.2.3. Step 3. Run analysis

After starting and entering docker environment, run follwing commands to do analysis.

```shell
python3 /root/repos/SARS-CoV-2_Multi-PCR_v1.0/bin/Main_SARS-CoV-2.py -i /root/config/input.json
#cd /root/result
nohup sh /root/result/main.sh &
```

#### 5.2.4. Step 4. Collect results

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

- consensus genome sequence

```text
your/result/path/*/05.Stat/*.Consensus.fa
```

- HTML report

```text
your/result/path/*/05.Stat/*.html
```

## 6. Updates

May 20th, 2021

1. Provide full demo (comprises of input data, execution steps and output files) in README.
2. Add troubleshooting section in README.

Detailed updates from [original repository](https://github.com/MGI-tech-bioinformatics/SARS-CoV-2_Multi-PCR_v1.0):

1. Use variant annotation excel instead of VCF file in HTML report
2. Optimized depth distribution SVG in HTML report.
3. Mark the primer base quality as 0 instead of removing primer sequence
4. Update primer sequence information
5. Reduce software running time
6. Upload a docker version of this software

April 12th, 2021

1. Update `input.json`. Use fixed file path.
2. Debug `Dockerfile`.
3. Update `README.md`.

April 6th, 2021

1. Create repository.

## FAQ && Troubleshooting

1. Where can I obtain example data ?
  
    The example results are generated using real data. For the reason of data security, we cannot publish our real data as example. If users need samples for test, please leave us an issue or contact us directly.
    Our email: <MGI_BIT_EU@mgi-tech.com>.

2. `singularity` installed on ubuntu is a game instead of container.
  
  If users use `sudo apt install singularity` on ubuntu to install `singularity` container tool, they may install a game "singularity" instead of container `singularity`. `singularity` container tool" hasn't been publised in ubuntu's default software mirror (2021-05-27).
  
  We recommend users install [miniconda](https://docs.conda.io/en/latest/miniconda.html), and install `singularity` through conda environment manager: `conda install -c conda-forge singularity`

3. Execution of `singularity` version of ATOPlex pipeline gets stuck to step2 (bwa alignment)
  
  We've tested the singularity version (2021-05-27) of our pipeline on guest Ubuntu system in Windows10 host. We found that the execution may get stuck to step2, whhich is alignment step (`bwa mem`). When we increase the hardware resource (CPU, memory) allocated to the virtual OS, things go well again.

  If users get stuck to one step, users may consider checking the script error log file, or entering the container environment and manually run the step shell script. Or, user could just provide more hardware resource.

## Reference

- <https://github.com/MGI-tech-bioinformatics/SARS-CoV-2_Multi-PCR_v1.0>

## Contribution

(Alphabetical order)

- Bochen Cheng, MGI-Latvia
- Shixu He, MGI-Latvia
- Zhiying Mei, MGI

## License
