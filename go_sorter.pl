#!/usr/bin/perl
#TG

## input: file with list of go file names, requested pvalue cut off for go term significance
### The purpose of this program is to sort through the obtained GO terms for each sample and asks whether
## the term meets a p-value cut off for significance within the sample
## the program outputs a file containing all the go terms with pvalues meeting the cut off
## this program also outputs files for each sample containing significant go terms along with the depth and number of associated genes


use strict;
use warnings;

## print out to command line to inform user that they must manually find the go terms
print "Use gather.genome.duke.edu to find the GO terms for each sample and download the files\n";
print "Make a file containing all the GO-file file names\n";
print "Name it \"GO_files.txt\" and place it along with the files in this folder\n\n";

## continue with program when the user enters return
print "Hit Enter when finished";                                  
my $continue = <>;

### open up the file containing the GO file names
my $GO_files = "GO_files.txt";          # define variable with the name of the file
unless(open(GOFILES,$GO_files)){        # open the file, else die
    die "couldnt open GO_files.txt"
}
### create an array with all the GO file names
my @files;                              # initialize array 
while(defined(my$line = <GOFILES>)){    # for each file name in the file
    chomp($line);                       # remove newline character
    push(@files,$line);                 # add filename to the array
}
close(GOFILES);                         # close the GO files file
 

### Determine the ln(P-value) cutoff from command request
print "Enter P-Value Cutoff: ";             # request wanted pvalue from command line
my $wantedpvalue = <>;                      # variable to contain pvalue
chomp($wantedpvalue);
my $pvaluecutoff = abs(log($wantedpvalue));       # calculate ln(pvalue) to use as the cut off


### For each sample print out the GO term and number genes associated with that term
my %goterms;

foreach my $file (@files) {             # for each of the go files (names stored in files)
    unless(open(FILE,$file)){           # open the file, else die
        die "cant open $file"
    }
    my $header = <FILE>;                # remove the header from the file downloaded from gather

    my $filename = "signif_$file";                                             # define filename for each samples output file
    open OUTPUT,">$filename" or die "cant open output $filename file $!\n";     #open the output file, else die
    
    my %geneswithgo;                                # initialize a hash to contain all the genes for each sample(to determine total number for graphing later)
    my %geneswithcutoff;                            # initialize a hash to contain genes meeting cutoff for each sample
    while(defined(my $line = <FILE>)){              # for each line in the GO term containing file
        chomp($line);                               # remove newline character, (below) split by tab and define variables
        my($num,$GOannot,$thing,$geneannotated,$genesnoannot,$genomeannotated,$genomnoannot,$lnbayes,$neglnpvalue,$FEneglnpvalue,$FEnelnFDR,$genes) = split(/\t/,$line);
        my (undef,$numbers,$GOterm)= split(/\:/,$GOannot);      # split GO annotation to obtain name of GO term
        my @numbers = split(//,$numbers);                       # split again to find the depth of the term
        my $depth = $numbers[-2];                               # define depth
        my @gogenes = split(/ /,$genes);                        # split genes file at space to get array with all gene names
        foreach my $gene (@gogenes){                            # for each gene with a go term
            $geneswithgo{$gene} = ()                            # make that gene a hash name to count total number of genes
        }
        if ($neglnpvalue >= $pvaluecutoff){                     # if the ln(pvalue) is above the cutoff
            $goterms{$GOterm} = $depth;                         # create hash containing all go terms meeting cut off with key as goterm and value as the terms depth
            foreach my $gene (@gogenes){                        # for each gene for this go term
                $geneswithcutoff{$gene} = ();                   # add the gene to a hash containing all genes satisfying go term cut off
            }
            print OUTPUT "$GOterm\t$depth\t$geneannotated\n";           # print the go term and the number of genes with that term for each sample
        }
        
    }
    ## count total number of genes that have go terms
    my $numgogenes = 0;                     # set number of genes = 0
    foreach my $gene(keys %geneswithgo){    # for each of the genes with a go term
        $numgogenes++;                      # add one to the count
    }
    ## count total number of genes with go terms that meet the cutoff
    my $numcutoffgogenes = 0;                   # set number of genes = 0
    foreach my $gene(keys %geneswithcutoff){    # for each of the genes with a go term
        $numcutoffgogenes++;                      # add one to the count
    }
    ## find the number of genes with go terms that dont satisfy the cutoff
    my $othergenes = $numgogenes-$numcutoffgogenes;                     # calculate number of genes with "other" go terms
    print OUTPUT " other (P-Value > $wantedpvalue)\t0\t$othergenes\n";  # print out this value for each sample
    $goterms{" other (P-Value > $wantedpvalue)"} = 0;                   # add this as a go term to the goterms hash
    close(FILE);            # close file     
    close(OUTPUT);          # close output file
}

### print out all the possible go terms meeting the pvalue cut off and their associated depth values to a file
### this is for graphing later
open OUTPUTTWO,">allgoterms.txt" or die "cant open output allgoterms.txt file $!\n";     #open the output file, else die
foreach my $go (keys %goterms){                         # for each of the go terms meeting the pvalue cut off
    print OUTPUTTWO $go,"\t",$goterms{$go},"\n";        # print the go term along with its depth to a file
}

