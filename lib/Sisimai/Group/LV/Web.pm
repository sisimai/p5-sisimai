package Sisimai::Group::LV::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Republic of Latvia
        'inbokss' => [
            # http://www.inbox.lv/
            qr/\Ainbox[.]lv\z/,
        ],
        'mail.lv' => [
            # http://www.mail.lv/
            qr/\Amail[.]lv\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::LV::Web - Major web mail service provider's domains in Latvia

=head1 SYNOPSIS

    use Sisimai::Group::LV::Web;
    print Sisimai::Group::LV::Web->find('mail.lv');    # mail.lv

=head1 DESCRIPTION

Sisimai::Group::LV::Web has a domain list of major web mail service providers
in Latvia.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
