#!/usr/bin/perl
#TG

###this file looks through all of the sample tables and outputs new files with
### sample names that contain the probe IDs and the avg of that samples intensity values
### will output sample.txt for each sample containg average microarray intensity for each probe
## also outputs a file containing the outputs for each of the samples

use strict;
use warnings;

## define variable for file containing the sample names associated with microarray data files
my $samplefile = "filenames.txt";

### open the file containing the filenames for each sample, else die
unless(open(SAMPLES,$samplefile)){
    die "couldnt open sample to file conversion text"
}

##### make hash with a reference to an array containing all the file names for each sample
my %convert;                                              # initialize a hash
while(defined(my $line = <SAMPLES>)){                     # for each line in the file
    chomp($line);                                         # remove the newline character
    my ($sample,$filename) = split(/\t/,$line);           # split the line at tabs, assign variables
    push (@{$convert{$sample}},$filename)                 # make a hash with sample as key pointing to an array with the file names
}
close(SAMPLES);                                           # close the file with the sample names and associated files

### open a file to contain all of the sample file names
open OUTPUTSAMPLES,">samplenames.txt" or die "cant open output samplenames.txt file $!\n";

### finds the average microarray intensity for each probe in each sample
foreach my $sample (keys %convert){            # for each of the samples
    my %sampledata;                            # open an array to contain the sample data
    my $numberreplicates = 0;                            # initialize a counter for number of samples (to later average)
    foreach my $filename (@{$convert{$sample}}){      # for each of files for a given sample
        $numberreplicates ++;                            # add one to the number of sample
        unless(open(FILE,"$filename")){                     # open the file with that file name (ex. GSM726943_sample_table.txt)
           die "couldnt open sample to $filename"           # else die
        }
        my $header = <FILE>;                                # remove the header from the file
        unless (%sampledata){                               # if there is no data in the hash (ie no genes or intensities inputed)
            while(defined(my $line = <FILE>)){              # look at each gene/intensity in the file
                chomp($line);                                       # remove the newline character
                my ($probeID,$intensity) = split(/\t/,$line);       # split the line at tabes, define variables
                $sampledata{$probeID} = $intensity;                 # create a hash: probeID as key, intensity as value
            }   
        } else {                                                    # if there is already data in the hash (genes/intensities inputed)
            while(defined(my $line = <FILE>)){                      # look at each gene/intensity in the file
                chomp($line);                                       # remove the newline character
                my ($probeID,$intensity) = split(/\t/,$line);       # split the line at tabs, define variables
                my $oldintensity = $sampledata{$probeID};           # define variable containing the previous intensity stored in the hash
                my $sum = $oldintensity+$intensity;                 # store sum of old intensity and new intensity in a variable
                $sampledata{$probeID} = $sum;                       # replace old intensity value with the sum of the intensities
            }
        }
        close (FILE);                                               # close the file and go to next file or next sample
    }
    
    ## replace the spaces in the sample name with underscores for file names
    $sample =~ s/\s/_/g;
    
    ## print out the filenames for the averaged data into a file
    print OUTPUTSAMPLES $sample,".txt\n";   
    
    ### print out the averaged microarray data into new files for each sample
    ## open output file with samplename as file name, else die
    open OUTPUT,">$sample.txt" or die "cant open output $sample file $!\n";     
    foreach my $probe (keys %sampledata){           # for each probe for a given sample
        my $avg = $sampledata{$probe}/$numberreplicates;        # find the average of the microarray intensity
        print OUTPUT $probe,"\t",$avg,"\n";                     # print the probe and average to the output file
    }
    close(OUTPUT);                                              # close output
}

close (OUTPUTSAMPLES);                                          # close sample output
