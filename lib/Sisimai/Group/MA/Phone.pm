package Sisimai::Group::MA::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Kingdom of Morocco
        'meditel' => [
            # Méditel; http://www.meditelecom.ma/
            qr/\Ameditel[.]blackberry[.]com\z/,
        ],
        'maroctelecom' => [
            # Maroc Telecom; http://www.iam.ma/
            qr/\Aiam[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::MA::Phone - Major phone provider's domains in Morocco

=head1 SYNOPSIS

    use Sisimai::Group::MA::Phone;
    print Sisimai::Group::MA::Phone->find('iam.blackberry.com');   # maroctelecom

=head1 DESCRIPTION

Sisimai::Group::MA::Phone has a domain list of major cellular phone providers
and major smart phone providers in Morocco.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
