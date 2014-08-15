package Sisimai::Group::CN::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in China
        'netease' => [
            # NetEase http://www.163.com/
            qr/\A(?:163|126|188)[.]com\z/,
            qr/\Avip[.]163[.]com\z/,
            qr/\Ayeah[.]net\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::CN::Web - Major web mail service provider's domains in China

=head1 SYNOPSIS

    use Sisimai::Group::CN::Web;
    print Sisimai::Group::CN::Web->find('163.com');    # netease

=head1 DESCRIPTION

Sisimai::Group::CN::Web has a domain list of major web mail service providers
in China.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
