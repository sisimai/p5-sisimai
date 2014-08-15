package Sisimai::Group::ES::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Kingdom of Spain
        'terra' => [
            # Terra Networks, S. A.; http://www.terra.com/
            # Terra Mail; http://correo.terra.com/
            qr/\Aterra[.](?:cl|com)\z/,
            qr/\Aterra[.]com[.](?:ar|co|do|sv|gt|mx|pa|pe|uy|ve)\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::ES::Web - Major web mail service provider's domains in Kingdom of Spain

=head1 SYNOPSIS

    use Sisimai::Group::ES::Web;
    print Sisimai::Group::ES::Web->find('terra.com');    # terra

=head1 DESCRIPTION

Sisimai::Group::ES::Web has a domain list of major web mail service providers
in Kingdom of Spain.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
