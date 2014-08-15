package Sisimai::Group::RO::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Romania
        'posta.ro' => [
            # www.posta.ro - Romanias first free webmail since 1997!
            # http://www.posta.ro/
            qr/\A(?:posta|mac|ze)[.]ro\z/,
            qr/\Aroposta[.]com\z/,
            qr/\A(?:adresamea|scrisoare|scrisori)[.]net\z/,
            qr/\A(?:scrisoare|scris|mail|email|freemail|webmail)[.]co[.]ro\z/,
            qr/\A(?:eu|europa|ue|matrix|mobil|net|pimp|write|writeme)[.]co[.]ro\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::RO::Web - Major web mail service provider's domains in Romania

=head1 SYNOPSIS

    use Sisimai::Group::RO::Web;
    print Sisimai::Group::RO::Web->find('posta.ro');    # posta.ro

=head1 DESCRIPTION

Sisimai::Group::RO::Web has a domain list of major web mail service providers
in Romania.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
