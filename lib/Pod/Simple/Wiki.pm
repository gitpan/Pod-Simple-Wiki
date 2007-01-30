package Pod::Simple::Wiki;

###############################################################################
#
# Pod::Simple::Wiki - A class for creating Pod to Wiki filters.
#
#
# Copyright 2003-2007, John McNamara, jmcnamara@cpan.org
#
# Documentation after __END__
#

use strict;
#use Pod::Simple::Debug (5);
use Pod::Simple;
use vars qw(@ISA $VERSION);

@ISA     = qw(Pod::Simple);
$VERSION = '0.06';

my $_debug = 0;


###############################################################################
###############################################################################
#
# The tag mappings for various Wiki text formats
#

my %tags = (
                'wiki' =>       {
                                    '<b>'    => "'''",
                                    '</b>'   => "'''",
                                    '<i>'    => "''",
                                    '</i>'   => "''",
                                    '<tt>'   => '"',
                                    '</tt>'  => '"',
                                    '<pre>'  => '',
                                    '</pre>' => "\n\n",

                                    '<h1>'   => "\n----\n'''",
                                    '</h1>'  => "'''\n\n",
                                    '<h2>'   => "\n'''''",
                                    '</h2>'  => "'''''\n\n",
                                    '<h3>'   => "\n''",
                                    '</h3>'  => "''\n\n",
                                    '<h4>'   => "\n",
                                    '</h4>'  => "\n\n",
                                },

                'kwiki' =>      {
                                    '<b>'    => '*',
                                    '</b>'   => '*',
                                    '<i>'    => '/',
                                    '</i>'   => '/',
                                    '<tt>'   => '[=',
                                    '</tt>'  => ']',
                                    '<pre>'  => '',
                                    '</pre>' => "\n\n",

                                    '<h1>'   => "\n----\n= ",
                                    '</h1>'  => " =\n\n",
                                    '<h2>'   => "\n== ",
                                    '</h2>'  => " ==\n\n",
                                    '<h3>'   => "\n=== ",
                                    '</h3>'  => " ===\n\n",
                                    '<h4>'   => "==== ",
                                    '</h4>'  => "\n\n",
                                },

                'usemod' =>     {
                                    '<b>'    => '<b>',
                                    '</b>'   => '</b>',
                                    '<i>'    => '<i>',
                                    '</i>'   => '</i>',
                                    '<tt>'   => '<tt>',
                                    '</tt>'  => '</tt>',
                                    '<pre>'  => "\n<pre>\n",
                                    '</pre>' => "\n</pre>\n\n",

                                    '<h1>'   => "\n= ",
                                    '</h1>'  => " =\n\n",
                                    '<h2>'   => "\n== ",
                                    '</h2>'  => " ==\n\n",
                                    '<h3>'   => "\n=== ",
                                    '</h3>'  => " ===\n",
                                    '<h4>'   => "\n==== ",
                                    '</h4>'  => " ====\n\n",
                                },

                'usemod_classic' => {
                                    '<b>'    => "'''",
                                    '</b>'   => "'''",
                                    '<i>'    => "''",
                                    '</i>'   => "''",
                                    '<tt>'   => '<tt>',
                                    '</tt>'  => '</tt>',
                                    '<pre>'  => "\n<pre>\n",
                                    '</pre>' => "\n</pre>\n\n",

                                    '<h1>'   => "\n= ",
                                    '</h1>'  => " =\n\n",
                                    '<h2>'   => "\n== ",
                                    '</h2>'  => " ==\n\n",
                                    '<h3>'   => "\n=== ",
                                    '</h3>'  => " ===\n",
                                    '<h4>'   => "\n==== ",
                                    '</h4>'  => " ====\n\n",
                                },


               'twiki'       => {
                                    '<b>'    => "*",
                                    '</b>'   => "*",
                                    '<i>'    => "_",
                                    '</i>'   => "_",
                                    '<tt>'   => '=',
                                    '</tt>'  => '=',
                                    '<pre>'  => "\n<verbatim>\n",
                                    '</pre>' => "\n</verbatim>\n\n",

                                    '<h1>'   => "---+ ",
                                    '</h1>'  => "\n\n",
                                    '<h2>'   => "---++ ",
                                    '</h2>'  => "\n\n",
                                    '<h3>'   => "---+++ ",
                                    '</h3>'  => "\n\n",
                                    '<h4>'   => "---++++ ",
                                    '</h4>'  => "\n\n",
                                },
                'wikipedia' =>  {
                                    '<b>'    => "'''",
                                    '</b>'   => "'''",
                                    '<i>'    => "''",
                                    '</i>'   => "''",
                                    '<tt>'   => '<tt>',
                                    '</tt>'  => '</tt>',
                                    '<pre>'  => "\n<code>\n",
                                    '</pre>' => "\n</code>\n",

                                    '<h1>'   => "==",
                                    '</h1>'  => "==\n",
                                    '<h2>'   => "===",
                                    '</h2>'  => "===\n",
                                    '<h3>'   => "====",
                                    '</h3>'  => "====\n",
                                    '<h4>'   => "=====",
                                    '</h4>'  => "=====\n",
                                },


                'moinmoin' =>   {
                                    '<b>'    => "'''",
                                    '</b>'   => "'''",
                                    '<i>'    => "''",
                                    '</i>'   => "''",
                                    '<tt>'   => '`',
                                    '</tt>'  => '`',
                                    '<pre>'  => "\n{{{\n",
                                    '</pre>' => "\n}}}\n",


                                    '<h1>'   => "\n== ",
                                    '</h1>'  => " ==\n\n",
                                    '<h2>'   => "\n=== ",
                                    '</h2>'  => " ===\n\n",
                                    '<h3>'   => "\n==== ",
                                    '</h3>'  => " ====\n\n",
                                    '<h4>'   => "\n===== ",
                                    '</h4>'  => " =====\n\n",
                                },
);


###############################################################################
#
# new()
#
# Simple constructor inheriting from Pod::Simple.
#
sub new {

    my $class                   = shift;
    my $format                  = lc shift || 'wiki';
       $format                  = 'wikipedia' if $format eq 'mediawiki';
       $format                  = 'moinmoin'  if $format eq 'moin';
       $format                  = 'wiki' unless exists $tags{$format};

    my $self                    = Pod::Simple->new(@_);
       $self->{_wiki_text}      = '';
       $self->{_format}         = $format;
       $self->{_tags}           = $tags{$format};
       $self->{output_fh}     ||= *STDOUT{IO};
       $self->{_item_indent}    = 0;

    bless  $self, $class;
    return $self;
}


###############################################################################
#
# _append()
#
# Appends some text to the buffered Wiki text.
#
sub _append {

    my $self = shift;

    $self->{_wiki_text} .= $_[0];
}


###############################################################################
#
# _output()
#
# Appends some text to the buffered Wiki text and then emits it. Also resets
# the buffer.
#
sub _output {

    my $self = shift;
    my $text = $_[0];

    $text = '' unless defined $text;

    print {$self->{output_fh}} $self->{_wiki_text}, $text;

    $self->{_wiki_text} = '';
}


###############################################################################
#
# _indent_item()
#
# Indents an "over-item" to the correct level.
#
sub _indent_item {

    my $self         = shift;
    my $item_type    = $_[0];
    my $item_param   = $_[1];
    my $indent_level = $self->{_item_indent};

    if ($self->{_format} eq 'wiki') {

        if    ($item_type eq 'bullet') {
             $self->_append("*" x $indent_level);
             # This was the way C2 Wiki used to define a bullet list
             # $self->_append("\t" x $indent_level . '*');
        }
        elsif ($item_type eq 'number') {
             $self->_append("\t" x $indent_level . $item_param);
        }
        elsif ($item_type eq 'text') {
             $self->_append("\t" x $indent_level);
        }
    }
    elsif ($self->{_format} eq 'kwiki') {

        if    ($item_type eq 'bullet') {
             $self->_append('*' x $indent_level . ' ');
        }
        elsif ($item_type eq 'number') {
             $self->_append('0' x $indent_level . ' ');
        }
        elsif ($item_type eq 'text') {
             $self->_append(";" x $indent_level . ' ');
        }
    }
    elsif ($self->{_format} eq 'usemod') {

        if    ($item_type eq 'bullet') {
             $self->_append('*' x $indent_level);
        }
        elsif ($item_type eq 'number') {
             $self->_append('#' x $indent_level);
        }
        elsif ($item_type eq 'text') {
             $self->_append(";" x $indent_level);
        }
    }
    elsif ($self->{_format} eq 'twiki') {

        if    ($item_type eq 'bullet') {
             $self->_append('   ' x $indent_level . "* ");
        }
        elsif ($item_type eq 'number') {
             $self->_append('   ' x $indent_level . $item_param . ". ");
        }
        elsif ($item_type eq 'text') {
             $self->_append('   ' x $indent_level . '$ ' );
        }
    }
    elsif ($self->{_format} eq 'wikipedia') {

        if    ($item_type eq 'bullet') {
             $self->_append('*' x $indent_level . ' ');
        }
        elsif ($item_type eq 'number') {
             $self->_append('#' x $indent_level . ' ');
        }
        elsif ($item_type eq 'text') {
             $self->_append(";" x $indent_level . ' ');
        }
    }
    elsif ($self->{_format} eq 'moinmoin') {


        if    ($item_type eq 'bullet') {
             $self->_append(' ' x $indent_level . "* ");
        }
        elsif ($item_type eq 'number') {
             $self->_append(' ' x $indent_level . "1. ");
        }
        elsif ($item_type eq 'text') {
             $self->_append(' ' x $indent_level);
        }

        $self->{_moinmoin_list} = 1;

    }
}


###############################################################################
#
# _skip_headings()
#
# Formatting in headings doesn't look great or is ignored in some formats.
#
sub _skip_headings {

    my $self = shift;

    return (
            $self->{_format} eq 'kwiki' and
            ($self->{_in_head1} or
             $self->{_in_head2} or
             $self->{_in_head3} or
             $self->{_in_head4})
           );
}


###############################################################################
#
# _append_tag()
#
# Add an open or close tag to the current text.
#
sub _append_tag {

    my $self = shift;
    my $tag  = $_[0];

    $self->_append($self->{_tags}->{$tag});
}


###############################################################################
###############################################################################
#
# The methods in the following section are required by Pod::Simple to handle
# Pod directives and elements.
#
# The methods _handle_element_start() _handle_element_end() and _handle_text()
# are called by Pod::Simple in response to Pod constructs. We use
# _handle_element_start() and _handle_element_end() to generate calls to more
# specific methods. This is basically a long-hand version of Pod::Simple::
# Methody with the addition of location tracking.
#


###############################################################################
#
# _handle_element_start()
#
# Call a method to handle the start of a element if one has been defined.
# We also set a flag to indicate that we are "in" the element type.
#
sub _handle_element_start {

    my $self    = shift;
    my $element = $_[0];

    $element =~ tr/-/_/;

    print '    ' x  $self->{_item_indent}, "<$element>\n" if $_debug;

    $self->{"_in_". $element}++;

    if (my $method = $self->can('_start_' . $element)) {
        $method->($self, $_[1]);
    }
}


###############################################################################
#
# _handle_element_end()
#
# Call a method to handle the end of a element if one has been defined.
# We also set a flag to indicate that we are "out" of the element type.
#
sub _handle_element_end {

    my $self    = shift;
    my $element = $_[0];

    $element =~ tr/-/_/;

    if (my $method = $self->can('_end_' . $element)) {
        $method->($self);
    }

    $self->{"_in_". $element}--;

    print "\n", '    ' x  $self->{_item_indent}, "</$element>\n\n" if $_debug;
}


###############################################################################
#
# _handle_text()
#
# Perform any necessary transforms on the text. This is mainly used to escape
# inadvertent CamelCase words.
#
sub _handle_text {

    my $self = shift;
    my $text = $_[0];

    # Only escape CamelCase in Kwiki paragraphs
    if ($self->{_format} eq 'kwiki' and not $self->{_in_Para}) {
        $self->{_wiki_text} .= $text;
        return;
    }

    # Split the text into tokens but maintain the whitespace
    my @tokens = split /(\s+)/, $text;

    if ($self->{_format} eq 'wiki') {
        for (@tokens) {
            next unless /\S/;                    # Ignore the whitespace
            next if m[^(ht|f)tp://];             # Ignore URLs
            s/([A-Z][a-z]+)(?=[A-Z])/$1''''''/g  # Escape with 6 single quotes

        }
    }
    elsif ($self->{_format} eq 'kwiki') {
        for (@tokens) {
            next unless /\S/;                    # Ignore the whitespace
            next if m[^(ht|f)tp://];             # Ignore URLs
            s/([A-Z][a-z]+[A-Z]\w+)/!$1/g;       # Escape with !
        }
    }
    # TODO: Add usemod <nowiki> escapes

    # Rejoin the tokens and whitespace.
    $self->{_wiki_text} .= join '', @tokens;
}


###############################################################################
#
# Functions to deal with the I<>, B<> and C<> formatting codes.
#
sub _start_I  {$_[0]->_append_tag('<i>')   unless $_[0]->_skip_headings()}
sub _start_B  {$_[0]->_append_tag('<b>')   unless $_[0]->_skip_headings()}
sub _start_C  {$_[0]->_append_tag('<tt>')  unless $_[0]->_skip_headings()}
sub _start_F  {$_[0]->_start_I}

sub _end_I    {$_[0]->_append_tag('</i>')  unless $_[0]->_skip_headings()}
sub _end_B    {$_[0]->_append_tag('</b>')  unless $_[0]->_skip_headings()}
sub _end_C    {$_[0]->_append_tag('</tt>') unless $_[0]->_skip_headings()}
sub _end_F    {$_[0]->_end_I}


###############################################################################
#
# Functions to deal with the Pod =head directives
#
sub _start_head1 {$_[0]->_append_tag('<h1>')}
sub _start_head2 {$_[0]->_append_tag('<h2>')}
sub _start_head3 {$_[0]->_append_tag('<h3>')}
sub _start_head4 {$_[0]->_append_tag('<h4>')}

sub _end_head1   {$_[0]->_append_tag('</h1>'); $_[0]->_output()}
sub _end_head2   {$_[0]->_append_tag('</h2>'); $_[0]->_output()}
sub _end_head3   {$_[0]->_append_tag('</h3>'); $_[0]->_output()}
sub _end_head4   {$_[0]->_append_tag('</h4>'); $_[0]->_output()}


###############################################################################
#
# Functions to deal with verbatim paragraphs. We emit the text "as is" for now.
# TODO: escape any Wiki formatting in text such as ''code''.
#
sub _start_Verbatim {$_[0]->_append_tag('<pre>')}
sub _end_Verbatim   {$_[0]->_append_tag('</pre>'); $_[0]->_output()}


###############################################################################
#
# Functions to deal with =over ... =back regions for
#
# Bulleted lists
# Numbered lists
# Text     lists
# Block    lists
#
sub _start_over_bullet {$_[0]->{_item_indent}++}
sub _start_over_number {$_[0]->{_item_indent}++}
sub _start_over_text   {$_[0]->{_item_indent}++}

sub _end_over_bullet   {$_[0]->{_item_indent}--;
                        $_[0]->_output("\n") unless $_[0]->{_item_indent}}

sub _end_over_number   {$_[0]->{_item_indent}--;
                        $_[0]->_output("\n") unless $_[0]->{_item_indent}}

sub _end_over_text     {$_[0]->{_item_indent}--;
                        $_[0]->_output("\n") unless $_[0]->{_item_indent}}

sub _start_item_bullet {$_[0]->_indent_item('bullet')}
sub _start_item_number {$_[0]->_indent_item('number', $_[1]->{number})}
sub _start_item_text   {$_[0]->_indent_item('text')}

sub _end_item_bullet   {$_[0]->_output("\n")}
sub _end_item_number   {$_[0]->_output("\n")}
sub _end_item_text     {$_[0]->_output(":\t") if $_[0]->{_format} eq 'wiki';
                        $_[0]->_output(" ; ") if $_[0]->{_format} eq 'kwiki';
                        $_[0]->_output(":"  ) if $_[0]->{_format} eq 'usemod';
                        $_[0]->_output(": " ) if $_[0]->{_format} eq 'twiki';
                        $_[0]->_output(" : ") if $_[0]->{_format} eq 'wikipedia';
                        $_[0]->_output(":: ") if $_[0]->{_format} eq 'moinmoin';
                        $_[0]->{_moinmoin_list} = 0
                       }

sub _start_over_block  {$_[0]->{_item_indent}++}
sub _end_over_block    {$_[0]->{_item_indent}--}


###############################################################################
#
# _start_Para()
#
# Special handling for paragraphs that are part of an "over" block.
#
sub _start_Para {

    my $self         = shift;
    my $indent_level = $self->{_item_indent};

    if ($self->{_in_over_block}) {

        if ($self->{_format} eq 'wiki') {
            $self->_append(("\t" x $indent_level) . " :\t");
        }
        elsif ($self->{_format} eq 'usemod') {
            $self->_append(":" x $indent_level);
        }
        elsif ($self->{_format} eq 'moinmoin') {
            $self->_append(' ' x $indent_level);
        }
    }


    if ($self->{_moinmoin_list}) {
        if (not $self->{_in_over_text} and $self->{_moinmoin_list} == 1) {
             $self->_append("\n");
        }

        if ($self->{_in_over_text} and $self->{_moinmoin_list} == 2) {
             $self->_append("\n");
        }

        if (not ($self->{_in_over_text} and $self->{_moinmoin_list} == 1)) {
             $self->_append(' ' x $indent_level);
        }

        $self->{_moinmoin_list}++;
    }
}


###############################################################################
#
# _end_Para()
#
# Special handling for paragraphs that are part of an "over_text" block.
# This is mainly required  be Kwiki.
#
sub _end_Para {

    my $self = shift;

    # Only add a newline if the paragraph isn't part of a text
    if ($self->{_in_over_text}) {
        # Workaround for the fact that Kwiki doesn't have a definition block
        #$self->_output("\n") if $self->{_format} eq 'kwiki';
    }
    else {
        $self->_output("\n");
    }

    $self->_output("\n")
}


1;


__END__

=head1 NAME

Pod::Simple::Wiki - A class for creating Pod to Wiki filters.

=head1 SYNOPSIS

To create a simple C<pod2wiki> filter:

    #!/usr/bin/perl -w

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


=head1 DESCRIPTION

The C<Pod::Simple::Wiki> module is used for converting Pod text to Wiki text.

Pod (Plain Old Documentation) is a simple markup language used for writing Perl documentation.

A Wiki is a user extensible web site. It uses very simple mark-up that is converted to Html.

For an introduction to Wikis see: http://en.wikipedia.org/wiki/Wiki


=head1 METHODS

=head2 new()

The C<new> method is used to create a new L<Pod::Simple::Wiki> object. It is also used to set the output Wiki format.

  my $parser1 = Pod::Simple::Wiki->new('wiki');
  my $parser2 = Pod::Simple::Wiki->new('kwiki');
  my $parser3 = Pod::Simple::Wiki->new(); # Defaults to 'wiki'

The currently supported formats are:

=over 4

=item wiki

This is the original Wiki format as used on Ward Cunningham's Portland repository of Patterns. The formatting rules are given at http://c2.com/cgi/wiki?TextFormattingRules

=item kwiki

This is the format as used by Brian Ingerson's CGI::Kwiki: http://search.cpan.org/dist/CGI-Kwiki/

=item usemod

This is the format used by the Usemod wikis. See: http://www.usemod.com/cgi-bin/wiki.pl?WikiFormat

=item twiki

This is the format used by TWiki wikis.  See: http://www.twiki.org/

=item wikipedia or mediawiki

This is the format used by Wikipedia and MediaWiki wikis.  See: http://www.wikipedia.org/

=item moinmoin

This is the format used by MoinMoin wikis.  See: http://moinmoin.wikiwikiweb.de/

=back

If no format is specified the parser defaults to C<wiki>.

Any other parameters in C<new> will be passed on to the parent L<Pod::Simple> object. See L<Pod::Simple> for more details.


=head2 Other methods

Pod::Simple::Wiki inherits all of the methods of L<Pod::Simple>. See L<Pod::Simple> for more details.


=head1 TODO

=over 4

=item *

Add more code, more tests and a few more users if possible.

=item *

Add other Wiki formats. Send requests or patches.

=item *

Fix some of the C<=over> edge cases. See the TODOs in the test programs.

=back



=head1 SEE ALSO

This module also installs a C<pod2wiki> command line utility. See C<pod2wiki --help> for details.


=head1 ACKNOWLEDGEMENTS

Thanks to Sean M. Burke for C<Pod::Simple>. It may not be simple but sub-classing it is. C<:-)>

Thanks to Sam Tregar for TWiki support.

Thanks Tony Sidaway for Wikipedia/MediaWiki support.

Thanks to Michael Matthews for MoinMoin support.


=head1 AUTHOR

John McNamara jmcnamara@cpan.org


=head1 COPYRIGHT

© MMIII-MMVII, John McNamara.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as Perl itself.
