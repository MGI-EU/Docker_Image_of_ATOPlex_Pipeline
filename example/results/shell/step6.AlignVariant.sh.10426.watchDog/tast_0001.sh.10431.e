[M::bwa_idx_load_from_disk] read 0 ALT contigs
[M::process] read 40 sequences (4000 bp)...
[M::mem_pestat] # candidate unique pairs for (FF, FR, RF, RR): (0, 20, 0, 0)
[M::mem_pestat] skip orientation FF as there are not enough pairs
[M::mem_pestat] analyzing insert size distribution for orientation FR...
[M::mem_pestat] (25, 50, 75) percentile: (197, 197, 198)
[M::mem_pestat] low and high boundaries for computing mean and std.dev: (195, 200)
[M::mem_pestat] mean and std.dev: (197.08, 1.00)
[M::mem_pestat] low and high boundaries for proper pairs: (193, 201)
[M::mem_pestat] skip orientation RF as there are not enough pairs
[M::mem_pestat] skip orientation RR as there are not enough pairs
[M::mem_process_seqs] Processed 40 reads in 0.000 CPU sec, 0.002 real sec
[main] Version: 0.7.13-r1126
[main] CMD: /data/pipeline/SARS-CoV-2_Multi-PCR_v1.1/tools/bwa mem -Y -M -R @RG\tID:Sample1\tSM:Sample1 -t 1 /data/pipeline/SARS-CoV-2_Multi-PCR_v1.1/database/nCov.fasta /data/result/result/Sample1/04.CutPrimer/Sample1.notCombined_1.fastq /data/result/result/Sample1/04.CutPrimer/Sample1.notCombined_2.fastq
[main] Real time: 0.002 sec; CPU: 0.002 sec
[M::bwa_idx_load_from_disk] read 0 ALT contigs
[M::process] read 35 sequences (6376 bp)...
[M::mem_process_seqs] Processed 35 reads in 0.000 CPU sec, 0.002 real sec
[main] Version: 0.7.13-r1126
[main] CMD: /data/pipeline/SARS-CoV-2_Multi-PCR_v1.1/tools/bwa mem -Y -M -R @RG\tID:Sample1\tSM:Sample1 -t 1 /data/pipeline/SARS-CoV-2_Multi-PCR_v1.1/database/nCov.fasta /data/result/result/Sample1/04.CutPrimer/Sample1.extendedFrags.fastq
[main] Real time: 0.002 sec; CPU: 0.001 sec
During startup - Warning messages:
1: Setting LC_CTYPE failed, using "C" 
2: Setting LC_COLLATE failed, using "C" 
3: Setting LC_TIME failed, using "C" 
4: Setting LC_MESSAGES failed, using "C" 
5: Setting LC_MONETARY failed, using "C" 
6: Setting LC_PAPER failed, using "C" 
7: Setting LC_MEASUREMENT failed, using "C" 
Lines   total/split/realigned/skipped:	0/0/0/0
Traceback (most recent call last):
  File "/data/pipeline/SARS-CoV-2_Multi-PCR_v1.1/bin/get_anno_table.py", line 66, in <module>
    df_anno = pd.read_csv('%s/%s.snpEff.anno.txt'%(resultdir,sample), sep='\t')
  File "/data/pipeline/SARS-CoV-2_Multi-PCR_v1.1/lib/python3-packages/pandas/io/parsers.py", line 688, in read_csv
    return _read(filepath_or_buffer, kwds)
  File "/data/pipeline/SARS-CoV-2_Multi-PCR_v1.1/lib/python3-packages/pandas/io/parsers.py", line 454, in _read
    parser = TextFileReader(fp_or_buf, **kwds)
  File "/data/pipeline/SARS-CoV-2_Multi-PCR_v1.1/lib/python3-packages/pandas/io/parsers.py", line 948, in __init__
    self._make_engine(self.engine)
  File "/data/pipeline/SARS-CoV-2_Multi-PCR_v1.1/lib/python3-packages/pandas/io/parsers.py", line 1180, in _make_engine
    self._engine = CParserWrapper(self.f, **self.options)
  File "/data/pipeline/SARS-CoV-2_Multi-PCR_v1.1/lib/python3-packages/pandas/io/parsers.py", line 2010, in __init__
    self._reader = parsers.TextReader(src, **kwds)
  File "pandas/_libs/parsers.pyx", line 540, in pandas._libs.parsers.TextReader.__cinit__
pandas.errors.EmptyDataError: No columns to parse from file
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LANGUAGE = (unset),
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Note: the --sample option not given, applying all records regardless of the genotype
Applied 0 variants
