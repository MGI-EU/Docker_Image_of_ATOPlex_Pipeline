#!/usr/bin/python3
# -*- coding: utf-8 -*-

'''
Filter SARS-CoV-2 consensus FASTA for downstream evolution analysis (NextStrain toolkit)

Criteria:

Consensus genome length >29000
N content < 5%
ambiguous nucleotide number < 10
'''

import argparse
import datetime
from genericpath import exists


import sys
import os
import re
import json
from subprocess import check_call
from subprocess import getoutput
from collections import defaultdict

def seqCheck(seq:str):
    seq = seq.upper()
    call = len(seq)
    cdict = dict()
    for c in seq:
        cdict[c] = cdict.get(c, 0) + 1
    cAm = call - cdict.get("N", 0) - cdict.get("A", 0) - cdict.get("T", 0) - cdict.get("C", 0) - cdict.get("G", 0)
    return (call, cdict.get("N", 0), cAm)

def fastaFscan(faFile, filtedFafile, seqLen = 29000, nRatio = 0.05, ambiguousNucNum = 10):
    id = ""
    seq = ""
    idset = set()
    with open(faFile, "rt") as _fqin, open(filtedFafile, "wt") as _fqout:
        id = _fqin.readline().rstrip()
        for line in _fqin:
            if line.startswith(">") and len(seq) > 0:
                seqProp = seqCheck(seq)
                if seqProp[0] < seqLen or seqProp[1]/seqProp[0] > nRatio or seqProp[2] > ambiguousNucNum:
                    pass
                else:
                    _fqout.write("{}\n{}]\n".format(id, seq))
                    idset.add(id.lstrip(">"))
                id = line.rstrip()
                seq = ""
                continue
            if (len(line) < 1):
                continue
            seq += line.rstrip()
        seqProp = seqCheck(seq)
        if seqProp[0] < seqLen or seqProp[1]/seqProp[0] > nRatio or seqProp[2] > ambiguousNucNum:
            pass
        else:
            _fqout.write("{}\n{}]n".format(id, seq))
            idset.add(id.lstrip(">"))
    return idset

def metadataManager(inMetaFile, outMetaFile, toolVer = "ATOPlex_ver1.0", validIDset = set()):
    timenow = datetime.datetime.now()
    today = "%04d-%02d-%02d" % (timenow.year, timenow.month, timenow.day)
    if (inMetaFile == None) or (not os.path.exists(inMetaFile)):
        # strain  virus   date    region  segment host
        # Sample1 ncov    2020-04-15      China mainland  genome  Homo sapiens
        with open(outMetaFile, "wt") as _omf:
            _omf.write("strain\tvirus\tdate\tregion\tsegment\thost\ttool_ver\tanalysis_time\n")
            for seqID in validIDset:
                _omf.write("{}\tncov\t{}\tGlobal\tgenome\tHuman\t{}\t{}\n".format(seqID.lstrip(">"),today,toolVer,today))
    else:
        with open(inMetaFile, "rt") as _imf, open(outMetaFile, "wt") as _omf:
            _omf.write("{}\ttool_ver\tanalysis_time\n".format(_imf.readline().rstrip()))
            for line in _imf:
                seqID = line.split("\t", maxsplit=1)[0]
                if seqID in validIDset:
                    _omf.write("{}\t{}\t{}\n".format(line.rstrip(), toolVer,today))
                else:
                    print("Sample {} is discarded becuse its consensus FASTA is invalid.".format(seqID))

def parseArguments():
    parser = argparse.ArgumentParser(description="Filter consensus FASTA file.", formatter_class=argparse.RawTextHelpFormatter)

    parser.add_argument(
        "-i",
        required=True,
        type=str,
        default=None,
        help="Config file input.json"
    )

    parser.add_argument(
        "--input-fasta",
        required=False,
        default=None,
        type=str,
        help="Input consensus FASTA file. Contains one or multiple FASTA sequence."
    )

    parser.add_argument(
        "--output-fasta",
        required = False,
        type=str,
        default="filtered.consensus.fa",
        help="Output file name of filtered FASTA sequence."
    )

    parser.add_argument(
        "--min-len",
        required=False,
        default = 29000,
        type=int,
        help="Minimum length of read to retain."
    )

    parser.add_argument(
        "--max-Nratio",
        required=False,
        default = 0.05,
        type=float,
        help="Max percentage of unknown nucleotide (N) to retain."
    )

    parser.add_argument(
        "--max-ambiguous",
        required=False,
        default = 10,
        type=int,
        help="Maximum number of ambiguous nucleotide to retain."
    )

    parser.add_argument(
        "--input-meta",
        required=False,
        default=None,
        type=str,
        help="Metadata of all samples. It's better users can provide metadata of all samples and we will help discard unused samples. Or we will generate default table according to available consensus sequence."
    )

    parser.add_argument(
        "--output-meta",
        required=False,
        default="filtered.metadata.tsv",
        type=str,
        help="New metadata of all valid consensus sequence."
    )

    parser.add_argument(
        "--tool-version",
        required=False,
        default="ATOPlex_ver1.0",
        type=str,
        help="The version information of tool to be added to metadata 'tool_ver' field."
    )

    return parser.parse_args()

def main():
    args = parseArguments()
    infasta = args.input_fasta
    oufasta = args.output_fasta
    inmeta = args.input_meta
    oumeta = args.output_meta
    if ((args.i != None) and (os.path.exists(args.i))):
        file_json = open(args.i,'rt')
        jsonobj = json.load(file_json)
        file_json.close()
        sampleList = list()
        with open(jsonobj["sample_list"], "rt") as _saml:
            for line in _saml:
                sampleList.append(re.split(r"\s+", line, maxsplit=1)[0])
        result_dir = os.path.abspath(jsonobj["workdir"])+"/result"
        infasta = result_dir + "/tmp.All_Samples.Consensus.fa"
        inmeta = jsonobj["sample_meta"] if os.path.exists(jsonobj["sample_meta"]) else None
        oufasta = result_dir + "/All_Samples.Consensus.filtered.fa"
        oumeta = result_dir + "/All_Samples.metadata.filtered.tsv"

        check_call("cat {} > {}".format(" ".join([result_dir + "/" + sample + "/05.Stat/*.Consensus.fa" for sample in sampleList]), infasta), shell=True)
        seqIDset = fastaFscan(infasta, oufasta, seqLen = args.min_len, nRatio = args.max_Nratio, ambiguousNucNum = args.max_ambiguous)
        metadataManager(inmeta , oumeta, toolVer = args.tool_version, validIDset=seqIDset)
        check_call("rm {}".format(infasta), shell=True)
    elif (infasta != None):
        print("Warning: The script is called directly. Please provide proper arguments to organize input and output files.")
        seqIDset = fastaFscan(infasta, oufasta, seqLen = args.min_len, nRatio = args.max_Nratio, ambiguousNucNum = args.max_ambiguous)
        metadataManager(inmeta , oumeta, validIDset=seqIDset)

if __name__ == "__main__":
    main()
