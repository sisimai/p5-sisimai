package Sisimai::Group::UG::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Republic of Uganda/Jamhuri ya Uganda
        'mtngroup' => [
            # MTN; http://www.mtn.co.ug/
            qr/\Amtninternet[.]blackberry[.]com\z/,
        ],
        'utl' => [
            # uganda telecom; http://www.utl.co.ug/
            qr/\Autl[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::UG::Phone - Major phone provider's domains in Uganda

=head1 SYNOPSIS

    use Sisimai::Group::UG::Phone;
    print Sisimai::Group::UG::Phone->find('utl.blackberry.com');   # utl

=head1 DESCRIPTION

Sisimai::Group::UG::Phone has a domain list of major cellular phone providers
and major smart phone providers in Uganda.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
