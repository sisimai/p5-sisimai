package Sisimai::Group::MO::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Macau
        'ctm' => [
            # CTM; https://www.eservices.ctm.net/cportal/
            qr/\Actm[.]blackberry[.]com\z/,
        ],
        'smartone' => [
            # SmarTone Mobile Communications Limited; http://www.smartone.com.mo/
            qr/\Asmartonemo[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::MO::Phone - Major phone provider's domains in Macau

=head1 SYNOPSIS

    use Sisimai::Group::MO::Phone;
    print Sisimai::Group::MO::Phone->find('ctm.blackberry.com');   # ctm

=head1 DESCRIPTION

Sisimai::Group::MO::Phone has a domain list of major cellular phone providers
and major smart phone providers in Macau.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
