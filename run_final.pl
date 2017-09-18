#!/usr/bin/perl
#TG

### this program creates a pipeline that runs all of the files necessary for this project
## takes as input a file containing all of the program names
## this file itself has no explicit out put, but results in the creation of many files through its programs


use strict;
use warnings;

## enter variable for the file containing all of the program names
my $file = $ARGV[0];

### open the file, otherwise kill program
unless(open(FILE,$file)){
    die "read me $file wont open"
}

## this script uses system calls to run all of the programs associated with my 2013 genomics final
my @programs;
while(my $program = <FILE>){
    chomp($program);
    push(@programs,$program)
}

my $findfilenames = $programs[0]; ## enter find_sample_file.pl
my $averagefile = $programs[1];
my $diffexpfinder = $programs[2];
my $sortinggofile = $programs[3];
my $signifsorter = $programs[4];


## run the first program to find the microarray data files associated with each sample
system("perl $findfilenames");

## run the second program to find the average of the data from all the samples
system("perl $averagefile");

## run the third program to find the differentially expressed genes
## and to convert probe IDs to official gene symbols
system("perl $diffexpfinder");

### run the fourth program to isolate the GO terms that were significant
system("perl $sortinggofile");

### run the fifth program to obtain file for graphing the data
system("perl $signifsorter");