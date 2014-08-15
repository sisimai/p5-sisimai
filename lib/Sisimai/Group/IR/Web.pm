package Sisimai::Group::IR::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Iran
        'iran.ir' => [
            # http://iran.ir/
            qr/\Airan[.]ir\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::IR::Web - Major web mail service provider's domains in Iran

=head1 SYNOPSIS

    use Sisimai::Group::IR::Web;
    print Sisimai::Group::IR::Web->find('iran.ir');    # iran.ir

=head1 DESCRIPTION

Sisimai::Group::IR::Web has a domain list of major web mail service providers
in Iran.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
