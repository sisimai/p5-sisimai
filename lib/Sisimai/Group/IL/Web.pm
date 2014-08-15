package Sisimai::Group::IL::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Israel
        'walla' => [
            # Walla! Communications: http://www.walla.co.il/
            # http://en.wikipedia.org/wiki/Walla!
            qr/\Awalla[.]co[.]il\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::IL::Web - Major web mail service provider's domains in Israel

=head1 SYNOPSIS

    use Sisimai::Group::IL::Web;
    print Sisimai::Group::IL::Web->find('walla.co.il');    # walla

=head1 DESCRIPTION

Sisimai::Group::IL::Web has a domain list of major web mail service providers
in Israel.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
