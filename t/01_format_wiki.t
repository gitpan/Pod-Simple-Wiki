#!/usr/bin/perl -w

###############################################################################
#
# A test for Pod::Simple::Wiki.
#
# Tests for I<>, B<>, C<> etc., formatting codes.
#
# reverse('©'), August 2004, John McNamara, jmcnamara@cpan.org
#


use strict;

use Pod::Simple::Wiki;
use Test::More tests => 6;

my $style = 'wiki';

# Output the tests for visual testing in the wiki.
# END{output_tests()};

my @tests  = (
                # Simple formatting tests
                [ "=pod\n\nI<Foo>"      => qq(''Foo''\n\n)      ],
                [ "=pod\n\nB<Foo>"      => qq('''Foo'''\n\n)    ],
                [ "=pod\n\nC<Foo>"      => qq("Foo"\n\n)        ],
                [ "=pod\n\nF<Foo>"      => qq(''Foo''\n\n)      ],

                # Nested formatting tests
                [ "=pod\n\nB<I<Foo>>"   => qq('''''Foo'''''\n\n)],
                [ "=pod\n\nI<B<Foo>>"   => qq('''''Foo'''''\n\n)],
             );


###############################################################################
#
#  Run the tests.
#
for my $test_ref (@tests) {

    my $parser  = Pod::Simple::Wiki->new($style);
    my $pod     = $test_ref->[0];
    my $target  = $test_ref->[1];
    my $wiki;

    $parser->output_string(\$wiki);
    $parser->parse_string_document($pod);


    is($wiki, $target, "\tTesting: " . encode_escapes($pod));
}


###############################################################################
#
# Encode escapes to make them visible in the test output.
#
sub encode_escapes {
    my $data = $_[0];

    for ($data) {
        s/\t/\\t/g;
        s/\n/\\n/g;
    }

    return $data;
}


###############################################################################
#
# Output the tests for visual testing in the wiki.
#
sub output_tests {

    my $test = 1;

    print "\n----\n\n";

    for my $test_ref (@tests) {

        my $parser  =  Pod::Simple::Wiki->new($style);
        my $pod     =  $test_ref->[0];
        my $pod2    =  encode_escapes($pod);
           $pod2    =~ s/^=pod\\n\\n//;

        print "Test ", $test++, ":\t", $pod2, "\n";
        $parser->parse_string_document($pod);
        print "\n----\n\n";
    }
}

__END__



