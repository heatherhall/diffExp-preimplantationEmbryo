#!/usr/bin/perl
#TG

### this program looks through the read me file and determine which files correspond to what biological samples
### this program is specific to the formatting of E-GEOD-293797.README.txt
### will output filenames.txt containing the sample names and their associated files

use strict;
use warnings;

## enter variable for the README file
my $file = "E-GEOD-293797.README.txt";

### open the readme file, otherwise kill program
unless(open( FILE,$file)){
    die "read me $file wont open"
}
### remove header from the readme file
my $header = <FILE>;

### open the output file filenames.txt to contain the sample names and their datafiles, else die
open OUTPUTFILES,">filenames.txt" or die "cant open output filenames.txt file $!\n";

### Retrieve the file names for the embryonic stem cell samples
for my $lines (0..3){                                           # for the first 4 lines
    my $line = <FILE>;                                          # read in the file line
    chomp($line);                                               # remove the newline character
    my @linedetails = split(/\t/,$line);                        # split the line at tabs
    print OUTPUTFILES $linedetails[2],"\t",$linedetails[-6],"\n";    # print to output the sample name and the file name
}

### Retrieve the filenames for all other samples
while(defined(my $line = <FILE>)){                              # for the remaining lines in the file
    chomp($line);                                               # remove the newline character
    my @linedetails = split(/\t/,$line);                        # split the line at tabs
    print OUTPUTFILES $linedetails[-1],"\t",$linedetails[-6],"\n";   # print to output the sample name and the file name
}

### close the input and output files
close(FILE);
close(OUTPUTFILES);
