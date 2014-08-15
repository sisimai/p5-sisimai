package Sisimai::Group::PT::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in R辿publique Fran巽aise/French Republic
        'sapo' => [
            # SAPO - Portugal Online!; http://www.sapo.pt/ 
            qr/\Asapo[.]pt\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::PT::Web - Major web mail service provider's domains in Portugal

=head1 SYNOPSIS

    use Sisimai::Group::PT::Web;
    print Sisimai::Group::PT::Web->find('sapo.pt');    # sapo

=head1 DESCRIPTION

Sisimai::Group::PT::Web has a domain list of major web mail service providers
in Portugal.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
