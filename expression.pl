#!/usr/bin/perl
#TG

### The inputs for this file are: file containing all file names for each sample, baseline file (ESC), probe-entrez conversion file and a requested fold change
### It determines the fold difference btn the basline and each of the samples
### If the fold difference is greater than or equal to 2 then it converts the probeID to entrez ID
## it further converts the entrez IDs into official gene symbols from ncbi (to allow tracking gene expression if wanted)
## and outputs the data into a new file for each sample
## for each sample the output contains a list of differentially expressed genes (represented by official gene symbol)
## also outputs a file containing the filenames for each samples output file

#### things to note
# not all probeIDs are associated with an entrez ID (~1/3 of the probes are lost)
### conversion file found here : http://ailun.stanford.edu/platformAnnotation.php
# not all entrez IDs have gene symbols bcs they may be pseudo genes or unknown

###  bigfloat....

use strict;
use warnings;
use Math::BigFloat;
require "findgenelwp.pl";

#### make a list of the file names based on previous programs output
#my @files = ("2-cell_stage_human_embryo.txt","4-cell_stage_human_embryo.txt","6-cell_stage_human_embryo.txt","8_to_10-cell_stage_human_embryo.txt","blastocyst_stage_human_embryo.txt");

## enter in file containing all of the sample text file names
my $samplefiles = "samplenames.txt";
## open the file with sample file names, else die
unless(open(SAMPLES,$samplefiles)){
    die "cant open samplenames.txt file"
}
my @samples;                        # initialize an array to contain the sample file names
while(defined(my $line = <SAMPLES>)){         # for each line in the file
    chomp($line);                             # remove the newline character
    push(@samples,$line);                     # add the filename to the sample array
}
close(SAMPLES);     # close the file


### Define variable for the file containing the probeIDs and their associated entrez IDs
### this converstion file is specific to the Affy Array used in this experiment
my $idconversionfile = "GPL6244.annot";

## open the ID conversion file, else die
unless(open(IDCONVERSION,$idconversionfile)){
    die "cant open id conversion file"
}

### make a hash to convert probeID to entrez ID (probe as key and entrez as value)
my %probeconvert;                                               # initialize hash to store conversion pairs
while(defined(my $line = <IDCONVERSION>)){                      # for each line in the probeID-entrez gene conversion file
    chomp($line);                                               # remove the newline character
    my ($probeID,$entrezID,$name,$info) = split(/\t/,$line);    # split the line at tabs, define variables
    $probeconvert{$probeID} = $entrezID;                        # create hash: probeID as key, entrezID as value
}
close(IDCONVERSION);                                            # close the id conversion file

### Request sample file containing sample names and their corresponding files
print "Enter Baseline file name: ";             # print request to command line
my $baseline = <>;                              # request user to input the filename from the command line 
chomp($baseline);                               # remove the newline from the input

## open the baseline file, else die
unless(open(BASE,$baseline)){
    die "ES cell file wont open"
}

### make a hash to compare microarray intensities to a baseline (probe as key and intensity as value)
my %baseline;                                   # initialize a hash
while(<BASE>){                                  # for each line in the baseline microarray file 
    chomp;                                      # remove the newline character
    my ($probeID,$intensity) = split(/\t/);     # split the line at tabs, define variables
    $baseline{$probeID} = $intensity;           # create hash: probeID as key, avg intensity as value
}   
close(BASE);                                    # close the baseline file


## request fold difference looked for in the microarray data
print "Enter Fold Difference in Expression: ";        # request input from the command line
my $change = <>;                                # define variable for command line input
chomp($change);                                 # remove newline character

## define variables for under and overexpressed ratios
my $underexp = 1/$change;
my $overexp = $change;


### find the fold difference compared to baseline for each gene
print "Finding differentially expressed genes...\n\n";

sample: foreach my $file (@samples){            # for each of the samples
    if ($file eq $baseline){                    # if the sample is the baseline sample
        next sample;                            # skip and go to the next sample
    }
    unless(open(FILE,$file)){                   # open the file with microarray data for the sample, else die
        die "cant open $file file"
    }
    my $filename = "Diff_Exp_$file";            # Define a filename for the output (differentially expressed)
    open OUTPUT,">$filename" or die "cant open output $filename file $!\n";     # open the output, else die
    
    while(defined(my $line = <FILE>)){                          # for each line in the file aka for each gene
        chomp($line);                                           # remove the newline character
        my ($probeID,$intensity) = split(/\t/,$line);           # split the line at tabs, define variables
        my $baseline = $baseline{$probeID};                     # define variable for baseline expression intensity
        my $ratio = $intensity/$baseline;                       # define the ratio of gene intensity to baseline intensity
        if ($ratio <= $underexp || $ratio >= $overexp){         # if the gene is over/under expressed by the given amount
            if (exists $probeconvert{$probeID}){                # if the probe ID exists in the conversion file (for whatever reasion 1/3 probeIDs lack entrez geneID)
                my $entrez = $probeconvert{$probeID};           # determine the entrez ID for that probe 
                my $genename = findname($entrez);              # use the findname subroutine (and LWP) to find an official gene name (not all genes have official symbols)
                print OUTPUT "$genename\n";                       # print out the differentially expressed genes to sample outputfile (error for genes without official symbols)
            }
        } 
    }
    close(FILE);            # close the sample file
    close(OUTPUT);          # close the output file
}
