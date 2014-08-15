package Sisimai::Group::NZ::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in New Zealand
        'coolkiwi' => [
            # Cool Kiwi http://coolkiwi.com/
            qr/\Acoolkiwi[.](?:co[.]nz|com)\z/,
        ],
        'orcon' => [
            # http://www.orcon.net.nz/
            qr/\Aorcon[.]net[.]nz\z/,
        ],
        'vodafone' => [
            # https://webmail.vodafone.co.nz/vfwebmail/
            qr/\A(?:vodafone|es|ihug|pcconnect|quik|wave)[.]co[.]nz\z/,
            qr/\Avodafone[.]net[.]nz\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::NZ::Web - Major web mail service provider's domains in New Zealand

=head1 SYNOPSIS

    use Sisimai::Group::NZ::Web;
    print Sisimai::Group::NZ::Web->find('vodafone.net.nz');    # vodafone

=head1 DESCRIPTION

Sisimai::Group::NZ::Web has a domain list of major web mail service providers
in New Zealand.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
