#!/usr/bin/perl/
#TG

### this file reformats the data for the differentially expressed genes' Go terms in a format
## that allows graphing by R studio
## Input: file of file names (with significant go terms), file of go terms,
## outputs file for each sample with Go term, depth, number genes for each of the possible GO terms found

### open up file that contains all the file names for the files containing the samples significant go terms
my $gofiles = "signif_go_files.txt";
unless(open(FILES,$gofiles)){         # open the file, else die
    die "couldnt open $gofiles"
}
my @files;                              # initialize array 
while(defined(my$line = <FILES>)){    # for each file name in the file
    chomp($line);                       # remove newline character
    push(@files,$line);                 # add filename to the array
}
close(FILES);                         # close the GO files file

my $gotermfiles = "allgoterms.txt";
unless(open(TERMS,$gotermfiles)){         # open the file, else die
    die "couldnt open $gotermfiles"
}
### make an array containing all the go terms
my %goterms;
while(defined(my $line = <TERMS>)){      # for each file name listed in the file
    chomp($line);                       # remove the newline
    my($term,$depth) = split(/\t/,$line);
    $goterms{$term} =$depth;                 # push the filename into the array
}
close(TERMS);    # close the file

### make an array containing all the file names
foreach my $file (@files) {             # for each of the go files (names stored in files)
    unless(open(FILE,$file)){           # open the file, else die
        die "cant open $file"
    }
    open OUTPUT,">new_$file" or die "cant open output $file file $!\n";     #open the output file, else die

    ### print out all possible go terms, depth and number of genes (necessary for plotting bcs R needs value)
    my %samplesgoterms;                     #make a hash with all the go terms for a given sample
    while(defined(my $line = <FILE>)){      # for each file name listed in the file
        chomp($line);                       # remove the newline
        my ($goterm,$depth,$numgenes) = split(/\t/,$line);      # split line and assign variables
        my $totalterms = "$goterm($depth)\t$depth\t$numgenes";  # assign variable for print statement
        $samplesgoterms{$goterm} = $totalterms;                 # make hash with go term as key and line as value
    }
    foreach my $terms (keys %goterms){          # for each of the go terms in all the samples
        if (exists $samplesgoterms{$terms}){                # if that go term exists for the given sample
            print OUTPUT $samplesgoterms{$terms},"\n";      # print the goterm, depth and gene number

        } else {                                            # if that go term doesnt exist for the given sample
            $depth = $goterms{$terms};                      # find the depth of that go term
            print OUTPUT "$terms($depth)\t$depth\t0\n";     # prin out go term depth and 0 (as number of genes)
        }
    }
    
    close(FILE);                            # close the file
    close(OUTPUT);
}

