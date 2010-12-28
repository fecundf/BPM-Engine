package BPM::Engine::Store::Result::Process;
BEGIN {
    $BPM::Engine::Store::Result::Process::VERSION   = '0.001';
    $BPM::Engine::Store::Result::Process::AUTHORITY = 'cpan:SITETECH';
    }
use namespace::autoclean;
use Moose;
extends qw/BPM::Engine::Store::Result/;
with    qw/BPM::Engine::Store::ResultBase::Process
           BPM::Engine::Store::ResultRole::WithAssignments
          /;

__PACKAGE__->table('wfd_process');
__PACKAGE__->add_columns(
    process_id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => { unsigned => 1 }
        },    
    process_uuid => {
        data_type         => 'CHAR',
        size              => 36,
        is_nullable       => 0,
        default_value     => 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
        },
    package_id => {
        data_type         => 'CHAR',
        size              => 36,
        is_nullable       => 0,
        is_foreign_key    => 1,       
        },
    process_uid => {
        data_type         => 'VARCHAR',
        size              => 64,
        is_nullable       => 1,
        },
    process_name => {
        data_type         => 'VARCHAR',
        size              => 255,
        is_nullable       => 1,
        default_value     => 'A Process',
        },    
    description => {
        data_type         => 'TEXT',
        is_nullable       => 1,
        },    
    priority => {
        data_type         => 'BIGINT',
        default_value     => 0,
        is_nullable       => 0,
        size              => 21
        },
    valid_from => {
        data_type         => 'DATETIME',
        is_nullable       => 1,
        timezone          => 'UTC',
        },
    valid_to => {
        data_type         => 'DATETIME',
        is_nullable       => 1,
        timezone          => 'UTC',
        },
    version => {
        data_type         => 'VARCHAR',
        size              => 8,
        is_nullable       => 0,
        default_value     => '0.01',
        },
    author => {
        data_type         => 'VARCHAR',
        size              => 255,
        is_nullable       => 1,
        },
    codepage => {
        data_type         => 'VARCHAR',
        size              => 255,
        is_nullable       => 1,
        },
    country_geo => {
        data_type         => 'VARCHAR',
        size              => 20,
        is_nullable       => 1,
        },
    publication_status => {
        data_type         => 'VARCHAR',
        size              => 20,
        is_nullable       => 1,
        },
    participant_list_id => {
        data_type         => 'INT',
        is_foreign_key    => 1,
        is_nullable       => 0,
        extras            => { unsigned => 1 }
        },    
    data_fields => {
        data_type         => 'TEXT',
        is_nullable       => 1,
        serializer_class  => 'JSON',
        },
    formal_params => {
        data_type         => 'TEXT',
        is_nullable       => 1,
        serializer_class  => 'JSON',
        },    
    assignments => {
        data_type         => 'TEXT',
        is_nullable       => 1,
        serializer_class  => 'JSON',
        },
    extended_attr => {
        data_type         => 'TEXT',
        is_nullable       => 1,
        serializer_class  => 'JSON',
        },     
    created => {
        data_type         => 'DATETIME',
        is_nullable       => 1,
        #timezone          => 'UTC',
        },    
    );

__PACKAGE__->set_primary_key('process_id');
__PACKAGE__->uuid_columns('process_uuid');
__PACKAGE__->add_unique_constraint( [qw/package_id process_uid version/] );

__PACKAGE__->might_have(
    'package' => 'BPM::Engine::Store::Result::Package',
    { 'foreign.package_id' => 'self.package_id' }
    );

__PACKAGE__->has_many(
    activities => 'BPM::Engine::Store::Result::Activity', 'process_id'
    );

__PACKAGE__->has_many(
    transitions => 'BPM::Engine::Store::Result::Transition', 'process_id'
    );

__PACKAGE__->has_many(
    instances => 'BPM::Engine::Store::Result::ProcessInstance','process_id'
    );

__PACKAGE__->belongs_to(
    participant_list => 'BPM::Engine::Store::Result::ParticipantList', 
    'participant_list_id', { cascade_delete => 1 }
    );

__PACKAGE__->has_many(
    participants => 'BPM::Engine::Store::Result::Participant',
    'participant_list_id'
    );

with 'BPM::Engine::Store::ResultRole::WithGraph';

sub new {
    my ($class, $attrs) = @_;

    $attrs->{process_name} ||= $attrs->{process_uid};
    
    return $class->next::method($attrs);
    }

sub insert {
    my ($self, @args) = @_;

    my $plist = $self->result_source->schema
        ->resultset('ParticipantList')->create({});
    $self->participant_list_id($plist->id);

    $self->next::method(@args);
    }

sub TO_JSON {
    my $self = shift;
    
    my %parms = map { $_ => $self->$_ } grep { $self->$_ }
        qw/process_name process_uid description package_id version formal_params
           data_fields assignments extended_attr created
          /;
    
    return \%parms;
    }

# not sure we need this
sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    if($sqlt_table->schema->translator->producer_type =~ /SQLite$/) {
        $sqlt_table->add_index(
            name => 'process_name', fields => ['process_uid', 'process_name']
            ) or die $sqlt_table->error;
        }
    }

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
__END__