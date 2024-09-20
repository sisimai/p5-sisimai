package Sisimai::Rhost;
use v5.26;
use strict;
use warnings;

state $RhostClass = {
    'Apple'     => ['.mail.icloud.com', '.apple.com', '.me.com'],
    'Cox'       => ['cox.net'],
    'FrancePTT' => ['.laposte.net', '.orange.fr', '.wanadoo.fr'],
    'GoDaddy'   => ['smtp.secureserver.net', 'mailstore1.secureserver.net'],
    'Google'    => ['aspmx.l.google.com', 'gmail-smtp-in.l.google.com'],
    'IUA'       => ['.email.ua'],
    'KDDI'      => ['.ezweb.ne.jp', 'msmx.au.com'],
    'Microsoft' => ['.prod.outlook.com', '.protection.outlook.com'],
    'Mimecast'  => ['.mimecast.com'],
    'NTTDOCOMO' => ['mfsmax.docomo.ne.jp'],
    'Spectrum'  => ['charter.net'],
    'Tencent'   => ['.qq.com'],
    'YahooInc'  => ['.yahoodns.net'],
};

sub get {
    # Detect the bounce reason from certain remote hosts
    # @param    [Sisimai::Fact] argvs   Decoded email object
    # @return   [String]                The value of bounce reason
    my $class = shift;
    my $argvs = shift || return undef;
    return undef unless length $argvs->{'diagnosticcode'};

    my $remotehost = lc $argvs->{'rhost'}       || '';
    my $domainpart = lc $argvs->{'destination'} || '';
    return undef unless length $remotehost.$domainpart;

    my $rhostmatch = undef;
    my $rhostclass = '';
    for my $e ( keys %$RhostClass ) {
        # Try to match with each value of RhostClass
        $rhostmatch   = 1 if grep { index($remotehost, $_) > -1 } $RhostClass->{ $e }->@*;
        $rhostmatch ||= 1 if grep { index($_, $domainpart) > -1 } $RhostClass->{ $e }->@*;
        next unless $rhostmatch;

        $rhostclass = __PACKAGE__.'::'.$e;
        last;
    }
    return undef unless $rhostclass;

    (my $modulepath = $rhostclass) =~ s|::|/|g;
    require $modulepath.'.pm';
    return $rhostclass->get($argvs);
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Rhost - Detect the bounce reason returned from certain remote hosts.

=head1 SYNOPSIS

    use Sisimai::Rhost;

=head1 DESCRIPTION

C<Sisimai::Rhost> detects the bounce reason from the content of C<Sisimai::Fact> object as an argument
of C<get()> method when the value of C<rhost> of the object is listed in C<$RhostClass> variable.
This class is called only C<Sisimai::Fact> class.

=head1 CLASS METHODS

=head2 C<B<get(I<Sisimai::Fact Object>)>>

C<get()> method detects the bounce reason.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2020,2022-2024 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

