
package BPM::Engine::Role::WithPersistence;
BEGIN {
    $BPM::Engine::Role::WithPersistence::VERSION   = '0.001';
    $BPM::Engine::Role::WithPersistence::AUTHORITY = 'cpan:SITETECH';
    }

use Moose::Role;
#use BPM::Engine::Types qw/ConnectInfo/;
use BPM::Engine::Store;
use namespace::autoclean -also => [qr/^_/];

has schema => (
    isa  => 'BPM::Engine::Store',
    is   => 'ro',
    lazy_build => 1,
    predicate => 'has_schema',
    );

sub storage { shift->schema(@_); }

sub _build_schema {
    my $self = shift;
    return BPM::Engine::Store->connect($self->connect_info)
        or die("Could not connect to Store");
    }

has 'connect_info' => (
    is     => 'rw',
    #isa    => ConnectInfo,
    #coerce => 1,
    required => 0,
    );

no Moose::Role;

1;
__END__
