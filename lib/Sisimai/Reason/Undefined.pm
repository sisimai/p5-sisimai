package Sisimai::Reason::Undefined;
use v5.26;
use strict;
use warnings;

sub text  { 'undefined' }
sub description { 'Sisimai could not detect an error reason' }
sub match { return undef }
sub true  { return undef }
1;

__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::Undefined - Sisimai could not detect the error reason.

=head1 SYNOPSIS

    use Sisimai::Reason::Undefined;
    print Sisimai::Reason::Undefined->text; # undefined

=head1 DESCRIPTION

C<Sisimai::Reason::Undefined> is for only returning the text and the description.
This class is called only from C<Sisimai->reason()> method.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> method returns the fixed string C<undefined>.

    print Sisimai::Reason::Undefined->text;  # undefined

=head2 C<B<match(I<string>)>>

C<match()> method always return C<undef>

=head2 C<B<true(I<Sisimai::Fact>)>>

C<true()> method always return C<undefZ>

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2016,2020,2021,2024 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

