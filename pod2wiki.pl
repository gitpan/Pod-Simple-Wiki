#!/usr/bin/perl -w

#######################################################################
#
# Simple pod2wiki filter demo.
#
# reverse('©'), May 2003, John McNamara, jmcnamara@cpan.org
#

use strict;
use Pod::Simple::Wiki;


my $parser = Pod::Simple::Wiki->new();


if (defined $ARGV[0]) {
    open IN, $ARGV[0]  or die "Couldn't open $ARGV[0]: $!\n";
} else {
    *IN = *STDIN;
}

if (defined $ARGV[1]) {
    open OUT, ">$ARGV[1]" or die "Couldn't open $ARGV[1]: $!\n";
} else {
    *OUT = *STDOUT;
}


$parser->output_fh(*OUT);
$parser->parse_file(*IN);


__END__
