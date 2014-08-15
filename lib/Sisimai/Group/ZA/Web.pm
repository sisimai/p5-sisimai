package Sisimai::Group::ZA::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in South Africa/Zuid-Afrika
        'mighty' => [
            # http://www.mighty.co.za/
            qr/\Amighty[.]co[.]za\z/,
        ],
        'webmail.co.za' => [
            # http://www.webmail.co.za/
            qr/\A(?:exclusive|executive|home|magic|rave|star|work|web)mail[.]co[.]za\z/,
            qr/\Athe(?:cricket|golf|pub|rugby)[.]co[.]za\z/,
            qr/\A(?:mailbox|websurfer)[.]co[.]za\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::ZA::Web - Major web mail service provider's domains in South Africa

=head1 SYNOPSIS

    use Sisimai::Group::ZA::Web;
    print Sisimai::Group::ZA::Web->find('mailbox.co.za');    # webmail.co.za

=head1 DESCRIPTION

Sisimai::Group::ZA::Web has a domain list of major web mail service providers
in South Africa.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
