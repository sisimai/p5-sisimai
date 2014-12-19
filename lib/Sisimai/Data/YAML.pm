package Sisimai::Data::YAML;
use feature ':5.10';
use strict;
use warnings;
use Try::Tiny;
use Module::Load;

sub dump {
    # @Description  Data dumper(YAML)
    # @Param <obj>  (Sisimai::Data) Object
    # @Return       (String) Dumped data
    my $class = shift;
    my $argvs = shift // return undef;
    my $error = undef;

    return undef unless ref $argvs eq 'Sisimai::Data';
    my $damneddata = undef;
    my $yamlstring = '';

    try {
        Module::Load::load('YAML');
        $damneddata = $argvs->damn;
        $YAML::SortKeys = 1;
        $YAML::Stringify = 0;
        $YAML::UseHeader = 1;
        $YAML::UseBlock = 0;
        $YAML::CompressSeries = 0;
        $yamlstring = YAML::Dump( $damneddata );

    } catch {
        # YAML module is not installed
        $error = '*** ERROR: "YAML" module is not installed';
    };

    die $error if length $error;
    return $yamlstring;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Data::YAML - Dumps parsed data object as a YAML format

=head1 SYNOPSIS

    use Sisimai::Data;
    my $data = Sisimai::Data->make( 'data' => <Sisimai::Message> object );
    for my $e ( @$data ) {
        print $e->dump('yaml');
    }

=head1 DESCRIPTION

Sisimai::Data::YAML dumps parsed data object as a YAML format. This class and 
method should be called from the parent object "Sisimai::Data".

=head1 CLASS METHODS

=head2 C<B<dump( I<Sisimai::Data> )>>

C<dump> method returns Sisimai::Data object as a YAML formatted string.

    my $mail = Sisimai::Mail->new('/var/mail/root');
    while( my $r = $mail->read ) {
        my $mesg = Sisimai::Message->new( 'data' => $r );
        my $data = Sisimai::Data->make( 'data' => $mesg );
        for my $e ( @$data ) {
            print $e->dump('yaml');
        }
    }

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
