package Sisimai::Address;
use feature ':5.10';
use strict;
use warnings;
use Class::Accessor::Lite;
use Sisimai::RFC5322;

my $roaccessors = [
    'address',  # (String) Email address
    'user',     # (String) local part of the email address
    'host',     # (String) domain part of the email address
    'verp',     # (String) VERP
    'alias',    # (String) alias of the email address
];
Class::Accessor::Lite->mk_ro_accessors( @$roaccessors );

sub new {
    # @Description  Constructor of Sisimai::Address
    # @Param <str>  (String) Email address
    # @Return       (Sisimai::Address) Object
    #               (undef) Undef when the email address was not valid.
    my $class = shift;
    my $email = shift // return undef;
    my $argvs = { 'address' => '', 'user' => '', 'host' => '', 'verp' => '', 'alias' => '' };

    if( $email =~ m{\A([^@]+)[@]([^@]+)\z} ) {
        # Get the local part and the domain part from the email address
        my $lpart = $1;
        my $dpart = $2;

        # Remove MIME-Encoded comment part
        $lpart =~ s{\A=[?].+[?]b[?].+[?]=}{};
        $lpart =~ y{`'"<>}{}d unless $lpart =~ m/\A["].+["]\z/;

        my $alias = 0;
        my $addr0 = sprintf( "%s@%s", $lpart, $dpart );
        my $addr1 = __PACKAGE__->expand_verp( $addr0 );
        my $addrL = undef;

        unless( length $addr1 ) {
            $addr1 = __PACKAGE__->expand_alias( $addr0 );
            $alias = 1 if $addr1;
        }

        if( length $addr1 ) {
            # The email address is VERP or alias
            $addrL = [ split( '@', $addr1 ) ];
            if( $alias ) {
                # The email address is an alias
                $argvs->{'alias'} = $addr0;

            } else {
                # The email address is a VERP
                $argvs->{'verp'}  = $addr0;
            }
            $argvs->{'user'} = $addrL->[0];
            $argvs->{'host'} = $addrL->[1];

        } else {
            # The email address is neither VERP nor alias.
            $argvs->{'user'} = $lpart;
            $argvs->{'host'} = $dpart;
        }
        $argvs->{'address'} = sprintf( "%s@%s", $argvs->{'user'}, $argvs->{'host'} );

        return bless( $argvs, __PACKAGE__ );

    } else {
        return undef;
    }
}

sub parse {
    # @Description  Email address parser
    # @Param <ref>  (Ref->Array) [ String including email address ]
    # @Return       (Ref->Array) Email address list
    #               (undef) Undef when there is no email address in the argument
    my $class = shift;
    my $argvs = shift // return undef;
    my $email = undef;
    my $addrs = [];

    return undef unless ref( $argvs ) eq 'ARRAY';

    PARSE_ARRAY: for my $e ( @$argvs ) {

        next unless defined $e;
        next unless $e =~ m{[@]};
        next if $e =~ m{[^\x20-\x7e]};

        my $v = __PACKAGE__->s3s4( $e );
        if( length $v ) {
            push @$addrs, $v;
        }
    }

    return undef unless scalar @$addrs;
    return $addrs;
}

sub s3s4 {
    # @Description  Ruleset 3, and 4 of sendmail.cf
    # @Param <str>  (String) Text including an email address
    # @Return       (String) Email address without comment, brackets
    my $class = shift;
    my $input = shift // return undef;

    return $input if ref $input;

    # "=?ISO-2022-JP?B?....?="<user@example.jp>
    # no space character between " and < .
    $input =~ s{(.)"<}{$1" <};

    my $canon = '';
    my $addrs = [];
    my $token = [ split( ' ', $input ) ];

    # Convert character entity; "&lt;" -> ">", "&gt;" -> "<".
    map { $_ =~ s/&lt;/</g; $_ =~ s/&gt;/>/g; } @$token;
    map { $_ =~ s/,\z//g; } @$token;

    if( scalar(@$token) == 1 ) {
        push @$addrs, $token->[0];

    } else {
        for my $e ( @$token ) {
            chomp $e;
            next unless $e =~ m{\A[<]?.+[@][-.0-9A-Za-z]+[.][A-Za-z]{2,}[>]?\z};
            push @$addrs, $e;
        }
    }

    if( scalar( @$addrs ) > 1 ) {
        $canon = [ grep { $_ =~ m{\A[<].+[>]\z} } @$addrs ]->[0];
        $canon = $addrs->[0] unless $canon;

    } else {
        $canon = shift @$addrs;
    }

    return '' if( ! defined $canon || $canon eq '' );
    $canon =~ y{<>[]():;}{}d;   # Remove brackets, colons

    if( $canon =~ m/\A["].+["][@].+\z/ ) {
        # "localpart..."@example.jp
        $canon =~ y/{}'`//d;
    } else {
        # Remove brackets, quotations
        $canon =~ y/{}'"`//d;
    }
    return $canon;
}

sub expand_verp {
    # @Description  Expand VERP: Get the original recipient address from VERP
    # @Param        (String) VERP
    # @Return       (String) Email address
    my $class = shift;
    my $email = shift // return undef;
    my $local = [ split( '@', $email ) ]->[0];
    my $verp0 = '';

    if( $local =~ m/\A[-_\w]+?[+](\w[-._\w]+\w)[=](\w[-.\w]+\w)\z/ ) {
        $verp0 = $1.'@'.$2;
        return $verp0 if Sisimai::RFC5322->is_emailaddress( $verp0 );

    } else {
        return '';
    }
}

sub expand_alias {
    # @Description  Expand alias: remove from '+' to '@'
    # @Param        (String) Email address
    # @Return       (String) Expanded email address
    my $class = shift;
    my $email = shift // return undef;
    my $local = undef;
    my $alias = '';

    return '' unless Sisimai::RFC5322->is_emailaddress( $email );
    $local = [ split( '@', $email ) ];
    if( $local->[0] =~ m/\A([-_\w]+?)[+].+\z/ ) {
        $alias = sprintf( "%s@%s", $1, $local->[1] );
    }
    return $alias;
}
1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Address - Email address object

=head1 SYNOPSIS

    use Sisimai::Address;

    my $v = Sisimai::Address->new( 'neko@example.jp' );
    print $v->user;     # neko
    print $v->host;     # example.jp
    print $v->address;  # neko@example.jp

=head1 DESCRIPTION

Sisimai::Address provide methods for dealing email address.

=head1 CLASS METHODS

=head2 C<B<new( I<email address> )>>

C<new()> is a constructor of Sisimai::Address

    my $v = Sisimai::Address->new( 'neko@example.jp' );

=head2 C<B<parse( I<Array-Ref> )>>

C<parse()> is a parser for getting only email address from text including email
addresses.

    my $r = [
        'Stray cat <cat@example.jp>',
        'nyaa@example.jp (White Cat)',
    ];
    my $v = Sisimai::Address->parse( $r );

    warn Dumper $v;
    $VAR1 = [
                'cat@example.jp',
                'nyaa@example.jp'
            ];

=head2 C<B<s3s4( I<email address> )>>

C<s3s4()> works Ruleset 3, and 4 of sendmail.cf.

    my $r = [
        'Stray cat <cat@example.jp>',
        'nyaa@example.jp (White Cat)',
    ];

    for my $e ( @$r ) {
        print Sisimai::Address->s3s4( $e );    # cat@example.jp
                                                # nyaa@example.jp
    }

=head2 C<B<expand_verp( I<email address> )>>

C<expand_verp()> gets the original email address from VERP

    my $r = 'nyaa+neko=example.jp@example.org';
    print Sisimai::Address->expand_verp( $r ); # neko@example.jp

=head2 C<B<expand_alias( I<email address> )>>

C<expand_alias()> gets the original email address from alias

    my $r = 'nyaa+neko@example.jp';
    print Sisimai::Address->expand_alias( $r ); # nyaa@example.jp

=head1 INSTANCE METHODS

=head2 C<B<user()>>

C<user()> returns a local part of the email address.

    my $v = Sisimai::Address->new( 'neko@example.jp' );
    print $v->user;     # neko

=head2 C<B<host()>>

C<host()> returns a domain part of the email address.

    my $v = Sisimai::Address->new( 'neko@example.jp' );
    print $v->host;     # example.jp

=head2 C<B<address()>>

C<address()> returns the email address

    my $v = Sisimai::Address->new( 'neko@example.jp' );
    print $v->address;     # neko@example.jp

=head2 C<B<verp()>>

C<verp()> returns the VERP email address

    my $v = Sisimai::Address->new( 'neko+nyaa=example.jp@example.org' );
    print $v->verp;     # neko+nyaa=example.jp@example.org
    print $v->address;  # nyaa@example.jp

=head2 C<B<alias()>>

C<alias()> returns the email address (alias)

    my $v = Sisimai::Address->new( 'neko+nyaa@example.jp' );
    print $v->alias;    # neko+nyaa@example.jp
    print $v->address;  # neko@example.jp

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
