package Sisimai::Group::UK::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in the United Kingdom
        'spidernetworks' => [
            # http://www.postmaster.co.uk/
            qr/\Apostmaster[.]co[.]uk\z/,
        ],
        'yipple' => [
            # http://www.yipple.com/
            qr/\Ayipple[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::UK::Web - Major web mail service provider's domains in The United Kingdom

=head1 SYNOPSIS

    use Sisimai::Group::UK::Web;
    print Sisimai::Group::UK::Web->find('postmaster.co.uk');    # spidernetworks

=head1 DESCRIPTION

Sisimai::Group::UK::Web has a domain list of major web mail service providers
in The United Kingdom.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
