package Sisimai::Address;
use feature ':5.10';
use strict;
use warnings;
use Class::Accessor::Lite;
use Sisimai::RFC5322;

my $roaccessors = [
    'address',  # [String] Email address
    'user',     # [String] local part of the email address
    'host',     # [String] domain part of the email address
    'verp',     # [String] VERP
    'alias',    # [String] alias of the email address
];
Class::Accessor::Lite->mk_ro_accessors(@$roaccessors);

sub undisclosed { 
    # Return pseudo recipient or sender address
    # @param    [String] atype  Address type: 'r' or 's'
    # @return   [String, Undef] Pseudo recipient address or sender address or
    #                           Undef when the $argv1 is neither 'r' nor 's'
    my $class = shift;
    my $atype = shift || return undef;
    my $local = '';

    return undef unless $atype =~ m/\A(?:r|s)\z/;
    $local = $atype eq 'r' ? 'recipient' : 'sender';
    return sprintf("undisclosed-%s-in-headers%slibsisimai.org.invalid", $local, '@');
}

sub new {
    # Constructor of Sisimai::Address
    # @param <str>  [String] email            Email address
    # @return       [Sisimai::Address, Undef] Object or Undef when the email 
    #                                         address was not valid.
    my $class = shift;
    my $email = shift // return undef;
    my $thing = { 'address' => '', 'user' => '', 'host' => '', 'verp' => '', 'alias' => '' };

    if( $email =~ m/\A([^@]+)[@]([^@]+)\z/ ) {
        # Get the local part and the domain part from the email address
        my $lpart = $1;
        my $dpart = $2;

        # Remove MIME-Encoded comment part
        $lpart =~ s/\A=[?].+[?]b[?].+[?]=//;
        $lpart =~ y/`'"<>//d unless $lpart =~ m/\A["].+["]\z/;

        my $alias = 0;
        my $addr0 = sprintf("%s@%s", $lpart, $dpart);
        my $addr1 = __PACKAGE__->expand_verp($addr0);

        unless( length $addr1 ) {
            $addr1 = __PACKAGE__->expand_alias($addr0);
            $alias = 1 if $addr1;
        }

        if( length $addr1 ) {
            # The email address is VERP or alias
            my @addrs = split('@', $addr1);
            if( $alias ) {
                # The email address is an alias
                $thing->{'alias'} = $addr0;

            } else {
                # The email address is a VERP
                $thing->{'verp'}  = $addr0;
            }
            $thing->{'user'} = $addrs[0];
            $thing->{'host'} = $addrs[1];

        } else {
            # The email address is neither VERP nor alias.
            $thing->{'user'} = $lpart;
            $thing->{'host'} = $dpart;
        }
        $thing->{'address'} = sprintf("%s@%s", $thing->{'user'}, $thing->{'host'});

        return bless($thing, __PACKAGE__);

    } else {
        # The argument does not include "@"
        return undef unless Sisimai::RFC5322->is_mailerdaemon($email);
        if( $email =~ /[<]([^ ]+)[>]/ ) {
            # Mail Delivery Subsystem <MAILER-DAEMON>
            $thing->{'user'} = $1;
            $thing->{'address'} = $1;

        } else {
            return undef if $email =~ /[ ]/;

            # The argument does not include " "
            $thing->{'user'}    = $email;
            $thing->{'address'} = $email;
        }

        return bless($thing, __PACKAGE__);
    }
}

sub find {
    # Email address parser with a name and a comment
    # @param    [String] argvs  String including email address
    # @param    [Boolean] addrs 0 = Returns list including all the elements
    #                           1 = Returns list including email addresses only
    # @return   [Array, Undef]  Email address list or Undef when there is no 
    #                           email address in the argument
    # @example  Parse email address
    #   input:  find('Neko <neko@example.cat>')
    #   output: [{'address' => 'neko@example.cat', 'name' => 'Neko'}]
    my $class = shift;
    my $argvs = shift // return undef;
    my $addrs = shift // undef;
    $argvs =~ s/[\r\n]//g;

    my $emailtable = { 'address' => '', 'name' => '', 'comment' => '' };
    my $addrtables = [];
    my $readcursor = 0;
    my $delimiters = ['<', '>', '(', ')', '"', ','];
    my $indicators = {
        'email-address' => (1 << 0),    # <neko@example.org>
        'quoted-string' => (1 << 1),    # "Neko, Nyaan"
        'comment-block' => (1 << 2),    # (neko)
    };
    my $characters = [split('', $argvs)];
    my $readbuffer = [];

    my $v = $emailtable;   # temporary buffer
    my $p = '';            # current position

    for my $e ( @$characters ) {
        # Check each characters
        if( grep { $e eq $_ } @$delimiters ) {
            # The character is a delimiter character
            if( $e eq ',' ) {
                # Separator of email addresses or not
                if( $v->{'address'} =~ m/\A[<].+[@].+[>]\z/ ) {
                    # An email address has already been picked

                    if( $readcursor & $indicators->{'comment-block'} ) {
                        # The cursor is in the comment block (Neko, Nyaan)
                        $v->{'comment'} .= $e;

                    } elsif( $readcursor & $indicators->{'quoted-string'} ) {
                        # "Neko, Nyaan"
                        $v->{'name'} .= $e;

                    } else {
                        # The cursor is not in neither the quoted-string nor the comment block
                        $readcursor = 0;    # reset cursor position
                        push @$readbuffer, $v;
                        $v = { 'address' => '', 'name' => '', 'comment' => '' };
                        $p = '';
                    }
                } else {
                    # "Neko, Nyaan" <neko@nyaan.example.org> OR <"neko,nyaan"@example.org>
                    length $p ? ($v->{ $p } .= $e) : ($v->{'name'} .= $e);
                }
                next;
            } # End of if(',')

            if( $e eq '<' ) {
                # <: The beginning of an email address or not
                if( length $v->{'address'} ) {
                    length $p ? ($v->{ $p } .= $e) : ($v->{'name'} .= $e);

                } else {
                    # <neko@nyaan.example.org>
                    $readcursor |= $indicators->{'email-address'};
                    $v->{'address'} .= $e;
                    $p = 'address';
                }
                next;
            } # End of if('<')

            if( $e eq '>' ) {
                # >: The end of an email address or not
                if( $readcursor & $indicators->{'email-address'} ) {
                    # <neko@example.org>
                    $readcursor &= ~$indicators->{'email-address'};
                    $v->{'address'} .= $e;
                    $p = '';

                } else {
                    # a comment block or a display name
                    length $p ? ($v->{'comment'} .= $e) : ($v->{'name'} .= $e);
                }
                next;
            } # End of if('>')

            if( $e eq '(' ) {
                # The beginning of a comment block or not
                if( $readcursor & $indicators->{'email-address'} ) {
                    # <"neko(nyaan)"@example.org> or <neko(nyaan)@example.org>
                    if( $v->{'address'} =~ m/["]/ ) {
                        # Quoted local part: <"neko(nyaan)"@example.org>
                        $v->{'address'} .= $e;

                    } else {
                        # Comment: <neko(nyaan)@example.org>
                        $readcursor |= $indicators->{'comment-block'};
                        $v->{'comment'} .= $e;
                        $p = 'comment';
                    }
                } elsif( $readcursor & $indicators->{'comment-block'} ) {
                    # Comment at the outside of an email address (...(...)
                    $v->{'comment'} .= $e;

                } elsif( $readcursor & $indicators->{'quoted-string'} ) {
                    # "Neko, Nyaan(cat)", Deal as a display name
                    $v->{'name'} .= $e;

                } else {
                    # The beginning of a comment block
                    $readcursor |= $indicators->{'comment-block'};
                    $v->{'comment'} .= $e;
                    $p = 'comment';
                }
                next;
            } # End of if('(')

            if( $e eq ')' ) {
                # The end of a comment block or not
                if( $readcursor & $indicators->{'email-address'} ) {
                    # <"neko(nyaan)"@example.org> OR <neko(nyaan)@example.org>
                    if( $v->{'address'} =~ m/["]/ ) {
                        # Quoted string in the local part: <"neko(nyaan)"@example.org>
                        $v->{'address'} .= $e;

                    } else {
                        # Comment: <neko(nyaan)@example.org>
                        $readcursor &= ~$indicators->{'comment-block'};
                        $v->{'comment'} .= $e;
                        $p = 'address';
                    }
                } elsif( $readcursor & $indicators->{'comment-block'} ) {
                    # Comment at the outside of an email address (...(...)
                    $readcursor &= ~$indicators->{'comment-block'};
                    $v->{'comment'} .= $e;
                    $p = '';

                } else {
                    # Deal as a display name
                    $readcursor &= ~$indicators->{'comment-block'};
                    $v->{'name'} .= $e;
                    $p = '';
                }
                next;
            } # End of if(')')

            if( $e eq '"' ) {
                # The beginning or the end of a quoted-string
                if( length $p ) {
                    # email-address or comment-block
                    $v->{ $p } .= $e;

                } else {
                    # Display name
                    $v->{'name'} .= $e;
                    if( $readcursor & $indicators->{'quoted-string'} ) {
                        # "Neko, Nyaan"
                        unless( $v->{'name'} =~ m/\x5c["]\z/ ) {
                            # "Neko, Nyaan \"...
                            $readcursor &= ~$indicators->{'quoted-string'};
                            $p = '';
                        }
                    } else {
                        if( ! $readcursor & $indicators->{'email-address'} &&
                            ! $readcursor & $indicators->{'comment-block'} ) {
                            # Deal as the beginning of a display name
                            $readcursor |= $indicators->{'quoted-string'};
                            $p = 'name';
                        }
                    }
                }
                next;
            } # End of if('"')
        } else {
            # The character is not a delimiter
            length $p ? ($v->{ $p } .= $e) : ($v->{'name'} .= $e);
            next;
        }
    }

    if( length $v->{'address'} ) {
        # Push the latest values
        push @$readbuffer, $v;

    } else {
        # No email address like <neko@example.org> in the argument
        if( $v->{'name'} =~ m/[@]/ ) {
            # String like an email address will be set to the value of "address"
            if( $v->{'name'} =~ m/(["].+?["][@][^ ]+)/ ) {
                # "neko nyaan"@example.org
                $v->{'address'} = $1;

            } elsif( $v->{'name'} =~ m/([^\s]+[@][^\s]+)/ ) {
                # neko-nyaan@example.org
                $v->{'address'} = $1;
            }
        } elsif( Sisimai::RFC5322->is_mailerdaemon($v->{'name'}) ) {
            # Allow if the argument is MAILER-DAEMON
            $v->{'address'} = $v->{'name'};
        }

        if( length $v->{'address'} ) {
            # Remove the value of "name" and remove the comment from the address
            if( $v->{'address'} =~ m/(.*)([(].+[)])(.*)/ ) {
                # (nyaan)nekochan@example.org, nekochan(nyaan)cat@example.org or
                # nekochan(nyaan)@example.org
                $v->{'address'} = $1.$3;
                $v->{'comment'} = $2;
            }
            $v->{'name'} = '';
            push @$readbuffer, $v;
        }
    }

    for my $e ( @$readbuffer ) {
        unless( $e->{'address'} =~ m/\A.+[@].+\z/ ) {
            # Allow if the argument is MAILER-DAEMON
            next unless Sisimai::RFC5322->is_mailerdaemon($e->{'address'});
        }

        $e->{'address'} =~ s/\A[\[<{('`]//;
        $e->{'address'} =~ s/['`>})\]]\z//;

        unless( $e->{'address'} =~ m/\A["].+["][@]/ ) {
            # Remove double-quotations
            $e->{'address'} =~ s/\A["]//;
            $e->{'address'} =~ s/["]\z//;
        }

        if( $addrs ) {
            # Almost compatible with parse() method, returns email address only
            delete $e->{'name'};
            delete $e->{'comment'};

        } else {
            # Remove double-quotations, trailing spaces.
            for my $f ( 'name', 'comment' ) {
                $e->{ $f } =~ s/\A\s*//;
                $e->{ $f } =~ s/\s*\z//;
            }
            $e->{'name'} =~ s/\A["]//;
            $e->{'name'} =~ s/["]\z//;
        }
        push @$addrtables, $e;
    }

    return undef unless scalar @$addrtables;
    return $addrtables;
}

sub parse {
    # Email address parser
    # @param    [Array] argvs   List of strings including email address
    # @return   [Array, Undef]  Email address list or Undef when there is no 
    #                           email address in the argument
    # @example  Parse email address
    #   parse(['Neko <neko@example.cat>'])  #=> ['neko@example.cat']
    my $class = shift;
    my $argvs = shift // return undef;
    my $addrs = [];
    return undef unless ref($argvs) eq 'ARRAY';

    PARSE_ARRAY: for my $e ( @$argvs ) {
        # Parse each element in the array
        #   1. The element must include '@'.
        #   2. The element must not include character except from 0x20 to 0x7e.
        next unless defined $e;
        unless( $e =~ m/[@]/ ) {
            # Allow if the argument is MAILER-DAEMON
            next unless Sisimai::RFC5322->is_mailerdaemon($e);
        }
        next if $e =~ m/[^\x20-\x7e]/;

        my $v = __PACKAGE__->s3s4($e);
        if( length $v ) {
            # The element includes a valid email address
            push @$addrs, $v;
        }
    }
    return undef unless scalar @$addrs;
    return $addrs;
}

sub s3s4 {
    # Runs like ruleset 3,4 of sendmail.cf
    # @param    [String] input  Text including an email address
    # @return   [String]        Email address without comment, brackets
    # @example  Parse email address
    #   s3s4( '<neko@example.cat>' ) #=> 'neko@example.cat'
    my $class = shift;
    my $input = shift // return undef;

    return $input if ref $input;
    unless( $input =~ /[ ]/ ) {
        # There is no space characters
        # no space character between " and < .
        $input =~ s/(.)"</$1" </;       # "=?ISO-2022-JP?B?....?="<user@example.org>, 
        $input =~ s/(.)[?]=</$1?= </;   # =?ISO-2022-JP?B?....?=<user@example.org>

        # comment-part<localpart@domainpart>
        $input =~ s/[<]/ </ unless $input =~ m/\A[<]/;
        $input =~ s/[>]/> / unless $input =~ m/[>]\z/;
    }

    my $canon = '';
    my @addrs = ();
    my @token = split(' ', $input);

    for my $e ( @token ) {
        # Convert character entity; "&lt;" -> ">", "&gt;" -> "<".
        $e =~ s/&lt;/</g; 
        $e =~ s/&gt;/>/g;
        $e =~ s/,\z//g;
    }

    if( scalar(@token) == 1 ) {
        push @addrs, $token[0];

    } else {
        for my $e ( @token ) {
            chomp $e;
            unless( $e =~ m/\A[<]?.+[@][-.0-9A-Za-z]+[.]?[A-Za-z]{2,}[>]?\z/ ) {
                # Check whether the element is mailer-daemon or not
                next unless Sisimai::RFC5322->is_mailerdaemon($e);
            }
            push @addrs, $e;
        }
    }

    if( scalar(@addrs) > 1 ) {
        # Get the first element which is <...> format string from @addrs array.
        $canon = (grep { $_ =~ m/\A[<].+[>]\z/ } @addrs)[0];
        $canon = $addrs[0] unless $canon;

    } else {
        $canon = shift @addrs;
    }

    return '' if( ! defined $canon || $canon eq '' );
    $canon =~ y/<>[]():;//d;    # Remove brackets, colons

    if( $canon =~ m/\A["].+["][@].+\z/ ) {
        # "localpart..."@example.org
        $canon =~ y/{}'`//d;
    } else {
        # Remove brackets, quotations
        $canon =~ y/{}'"`//d;
    }
    return $canon;
}

sub expand_verp {
    # Expand VERP: Get the original recipient address from VERP
    # @param    [String] email  VERP Address
    # @return   [String]        Email address
    # @example  Expand VERP address
    #   expand_verp('bounce+neko=example.org@example.org') #=> 'neko@example.org'
    my $class = shift;
    my $email = shift // return undef;
    my $local = (split('@', $email, 2))[0];
    my $verp0 = '';

    if( $local =~ m/\A[-_\w]+?[+](\w[-._\w]+\w)[=](\w[-.\w]+\w)\z/ ) {
        # bounce+neko=example.org@example.org => neko@example.org
        $verp0 = $1.'@'.$2;
        return $verp0 if Sisimai::RFC5322->is_emailaddress($verp0);

    } else {
        return '';
    }
}

sub expand_alias {
    # Expand alias: remove from '+' to '@'
    # @param    [String] email  Email alias string
    # @return   [String]        Expanded email address
    # @example  Expand alias
    #   expand_alias('neko+straycat@example.org') #=> 'neko@example.org'
    my $class = shift;
    my $email = shift // return undef;
    my $alias = '';

    return '' unless Sisimai::RFC5322->is_emailaddress($email);

    my @local = split('@', $email);
    if( $local[0] =~ m/\A([-_\w]+?)[+].+\z/ ) {
        # neko+straycat@example.org => neko@example.org
        $alias = sprintf("%s@%s", $1, $local[1]);
    }
    return $alias;
}

sub TO_JSON {
    # Instance method for JSON::encode()
    # @return   [String] The value of "address" accessor
    my $self = shift;
    return $self->address;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Address - Email address object

=head1 SYNOPSIS

    use Sisimai::Address;

    my $v = Sisimai::Address->new('neko@example.org');
    print $v->user;     # neko
    print $v->host;     # example.org
    print $v->address;  # neko@example.org

=head1 DESCRIPTION

Sisimai::Address provide methods for dealing email address.

=head1 CLASS METHODS

=head2 C<B<new(I<email address>)>>

C<new()> is a constructor of Sisimai::Address

    my $v = Sisimai::Address->new('neko@example.org');

=head2 C<B<find(I<String>)>>

C<find()> is a new parser for getting only email address from text including
email addresses.

    my $r = 'Stray cat <cat@example.org>, nyaa@example.org (White Cat)',
    my $v = Sisimai::Address->find($r);

    warn Dumper $v;
    $VAR1 = [
              {
                'name' => 'Stray cat',
                'address' => 'cat@example.org',
                'comment' => ''
              },
              {
                'name' => '',
                'address' => 'nyaa@example.jp',
                'comment' => '(White Cat)'
              }
    ];

=head2 C<B<parse(I<Array-Ref>)>>

C<parse()> is a parser for getting only email address from text including email
addresses.

    my $r = [
        'Stray cat <cat@example.org>',
        'nyaa@example.org (White Cat)',
    ];
    my $v = Sisimai::Address->parse($r);

    warn Dumper $v;
    $VAR1 = [
                'cat@example.org',
                'nyaa@example.org'
            ];

=head2 C<B<s3s4(I<email address>)>>

C<s3s4()> works Ruleset 3, and 4 of sendmail.cf.

    my $r = [
        'Stray cat <cat@example.org>',
        'nyaa@example.org (White Cat)',
    ];

    for my $e ( @$r ) {
        print Sisimai::Address->s3s4($e);   # cat@example.org
                                            # nyaa@example.org
    }

=head2 C<B<expand_verp(I<email address>)>>

C<expand_verp()> gets the original email address from VERP

    my $r = 'nyaa+neko=example.org@example.org';
    print Sisimai::Address->expand_verp($r); # neko@example.org

=head2 C<B<expand_alias(I<email address>)>>

C<expand_alias()> gets the original email address from alias

    my $r = 'nyaa+neko@example.org';
    print Sisimai::Address->expand_alias($r); # nyaa@example.org

=head1 INSTANCE METHODS

=head2 C<B<user()>>

C<user()> returns a local part of the email address.

    my $v = Sisimai::Address->new('neko@example.org');
    print $v->user;     # neko

=head2 C<B<host()>>

C<host()> returns a domain part of the email address.

    my $v = Sisimai::Address->new('neko@example.org');
    print $v->host;     # example.org

=head2 C<B<address()>>

C<address()> returns the email address

    my $v = Sisimai::Address->new('neko@example.org');
    print $v->address;     # neko@example.org

=head2 C<B<verp()>>

C<verp()> returns the VERP email address

    my $v = Sisimai::Address->new('neko+nyaan=example.org@example.org');
    print $v->verp;     # neko+nyaan=example.org@example.org
    print $v->address;  # nyaan@example.org

=head2 C<B<alias()>>

C<alias()> returns the email address (alias)

    my $v = Sisimai::Address->new('neko+nyaan@example.org');
    print $v->alias;    # neko+nyaan@example.org
    print $v->address;  # neko@example.org

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2017 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
