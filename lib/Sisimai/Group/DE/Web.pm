package Sisimai::Group::DE::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Germany(Bundesrepublik Deutschland)
        'gmx' => [
            # GMX - http://www.gmx.net/
            qr/\Agmx[.](?:com|net|org|info|biz|name)\z/,
            qr/\Agmx[.]co[.](?:in|uk)\z/,
            qr/\Agmx[.]com[.](?:br|my|tr)\z/,
            qr/\Agmx[.](?:at|ca|cc|ch|cn|co|de|es|eu|fr|hk|ie|it)\z/,
            qr/\Agmx[.](?:li|lu|ph|pt|ru|se|sg|tm|tw|us)\z/,
            qr/\Acaramail[.]com\z/, # GMX Caramail
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::DE::Web - Major web mail service provider's domains in Germany

=head1 SYNOPSIS

    use Sisimai::Group::DE::Web;
    print Sisimai::Group::DE::Web->find('gmx.de');    # gmx 

=head1 DESCRIPTION

Sisimai::Group::DE::Web has a domain list of major web mail service providers
in Germany.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
