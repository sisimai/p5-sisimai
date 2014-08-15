package Sisimai::Group::AL::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Republic of Albania
        'primo' => [
            # primo webmail; http://mail.albaniaonline.net/
            qr{\Aalbaniaonline[.]net\z},
            qr{\Aalbmail[.]com\z},
            qr{\Aprimo[.]al\z},
            qr{\A(?:get|my)primo[.]al\z},
            qr{\Ashukelaw[.]com\z},
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::AL::Web - Major web mail service provider's domains in Albania

=head1 SYNOPSIS

    use Sisimai::Group::AL::Web;
    print Sisimai::Group::AL::Web->find('albmail.com');    # primo

=head1 DESCRIPTION

Sisimai::Group::AL::Web has a domain list of major web mail service providers
in Albania.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
