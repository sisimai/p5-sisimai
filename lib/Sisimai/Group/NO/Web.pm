package Sisimai::Group::NO::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Norway
        'runbox' => [
            # http://www.runbox.com/
            qr/\Arunbox[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::NO::Web - Major web mail service provider's domains in Norway

=head1 SYNOPSIS

    use Sisimai::Group::NO::Web;
    print Sisimai::Group::NO::Web->find('runbox.com');    # runbox

=head1 DESCRIPTION

Sisimai::Group::NO::Web has a domain list of major web mail service providers
in Norway.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
