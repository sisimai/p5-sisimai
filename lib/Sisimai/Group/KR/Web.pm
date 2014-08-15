package Sisimai::Group::KR::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in South Korea
        # http://japan.cnet.com/sp/column_korea/story/0,3800105540,20333168,00.htm
        'daum' => [
            # http://www.daum.net/, Lycos?
            qr/\Ahanmail[.]net\z/,
        ],
        'empas' => [
            # http://www.empas.com/
            qr/\A(?:nate|empas|netsgo)[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::KR::Web - Major web mail service provider's domains in South Korea

=head1 SYNOPSIS

    use Sisimai::Group::KR::Web;
    print Sisimai::Group::KR::Web->find('nate.com');    # empas

=head1 DESCRIPTION

Sisimai::Group::KR::Web has a domain list of major web mail service providers
in South Korea.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
