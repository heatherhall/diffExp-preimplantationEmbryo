#!/usr/bin/perl
#TG

## this file creates a subroutine that will accept a entrezgene id and return a official symbol name for the gene by using lwp
## the subroutine takes in a entrez gene ID and outputs a Official Gene Symbol from NCBI gene database
## the skeleton of this file was taken from cpan so commenting is limited
##  http://search.cpan.org/~gaas/libwww-perl-6.05/lib/LWP.pm

use strict;
use warnings;
# Create a user agent object
use LWP::UserAgent;
##creates an object
my $ua = LWP::UserAgent->new;
$ua->agent("MyApp/0.1 ");

### defines a subroutine to convert a single entrez gene to a gene symbol through ncbis gene data base
sub findname{
    my $gene = $_[0];
    
    # Create a request to NCBIs gene data base and return content for a given gene search
    my $req = HTTP::Request->new(POST => 'http://www.ncbi.nlm.nih.gov/gene/');
    $req->content_type('application/x-www-form-urlencoded');
    $req->content('term='.$gene.'&report=full_report&format=text');

    # Pass request to the user agent and get a response back
    my $res = $ua->request($req);
    sleep(1);                                       # stop for 1 second after execute this command

    # Check the outcome of the response
    if ($res->is_success) {                         # if the request was successful
        my $page = ($res->content);                 # define a variable with the contents of the webpage
        $page =~ m/Official Symbol: (.*?) /s;       # find "Official Symbol: " in the page, followed by anything, stopping at first space (nongreedy)
        return $1;                                  # return the first set of anythings found above
    } else {
        print $res->status_line, "\n";
    }
}