#!/usr/bin/perl -w

###############################################################################
#
# A test for Pod::Simple::Wiki.
#
# Tests for I<>, B<>, C<> etc., formatting codes.
#
# reverse('�'), December 2005, John McNamara, jmcnamara@cpan.org
#


use strict;

use Pod::Simple::Wiki;
use Test::More tests => 7;

my $style = 'mediawiki';

# Output the tests for visual testing in the wiki.
# END{output_tests()};

my @tests  = (
  # Simple formatting tests
  [ "=pod\n\nI<Foo>"      => qq(''Foo''\n\n),       'Italic'     ],
  [ "=pod\n\nB<Foo>"      => qq('''Foo'''\n\n),     'Bold'       ],
  [ "=pod\n\nC<Foo>"      => qq(<tt>Foo</tt>\n\n),  'Monospace'  ],
  [ "=pod\n\nF<Foo>"      => qq(''Foo''\n\n),       'Filename'   ],

  # Nested formatting tests
  [ "=pod\n\nB<I<Foo>>"   => qq('''''Foo'''''\n\n), 'Bold Italic'],
  [ "=pod\n\nI<B<Foo>>"   => qq('''''Foo'''''\n\n), 'Italic Bold'],

  # Character escaping
  [ "=pod\n\nThis is neither ''italic'' nor '''bold'''" =>
    qq(This is neither '&#39;italic'&#39; nor '&#39;'bold'&#39;'\n\n),
    'Single quotes' ],


);



###############################################################################
#
#  Run the tests.
#
for my $test_ref (@tests) {

    my $parser  = Pod::Simple::Wiki->new($style);
    my $pod     = $test_ref->[0];
    my $target  = $test_ref->[1];
    my $name    = $test_ref->[2];
    my $wiki;

    $parser->output_string(\$wiki);
    $parser->parse_string_document($pod);

    is($wiki, $target, "\tTesting: $name");
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
        my $name    =  $test_ref->[2];

        $pod        =~ s/=pod\n\n//;
        $pod        = "=pod\n\n=head1 Test ". $test++ . " $name\n\n$pod";

        $parser->parse_string_document($pod);
    }
}


__END__

