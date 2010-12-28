
use strict;
use warnings;
use lib './t/lib';
use Test::More;
use Test::Moose;
use DateTime;

use BPM::Engine::TestUtils qw/setup_db teardown_db $dsn process_wrap/;

BEGIN { setup_db }
#END   { teardown_db }

my ($engine, $process) = process_wrap();
my $pi = $engine->create_process_instance($process);

#-- new activity

my $activity = $process->add_to_activities({
    activity_uid     => 1,
    activity_name    => 'work item',
    activity_type    => 'Implementation',
    start_mode => 'Manual'
    });
$activity->discard_changes;

#-- new activity_instance

my $ai = $activity->add_to_instances({ process_instance_id => $pi->id });
isa_ok($ai, 'BPM::Engine::Store::Result::ActivityInstance');
$ai->delete;

# the right way to do it
$ai = $activity->new_instance({
    process_instance_id => $pi->id,
    });
#$ai->discard_changes;
isa_ok($ai, 'BPM::Engine::Store::Result::ActivityInstance');

is($pi->activity_instances->count, 1, 'AI count matches');

# nullvalue test
ok(!$ai->tokenset);
$ai->update({ tokenset => 3 });
is($ai->tokenset, 3);

# setting a scalar does just that, requires discard_changes
$ai->update({ tokenset => \'NULL' });
like  ($ai->tokenset, qr/SCALAR/, 'local update');
$ai->discard_changes;
ok(!$ai->tokenset);

$ai->update({ tokenset => 4 });
is($ai->tokenset, 4);

# setting undef does not affect the db after discarding
$ai->tokenset(undef);
ok(!$ai->tokenset);
$ai->discard_changes;
ok($ai->tokenset);

$ai->update({ tokenset => 5 });

# using update() works, though, but doesn't in the program
$ai->update({ tokenset => undef });
ok(!$ai->tokenset);
$ai->discard_changes;
ok(!$ai->tokenset);

$ai->update({ tokenset => 6 })->discard_changes;


#-- activity_instance interface

is($ai->process_instance->id, $pi->id);
is($ai->activity->id, $activity->id);
ok(!$ai->transition);
ok(!$ai->prev);
ok(!$ai->next->count);
ok(!$ai->next_rs->count);
ok(!$ai->parent);

ok($ai->is_active);
ok(!$ai->completed);
ok(!$ai->is_deferred);

$ai->update({ deferred => DateTime->now }); #->discard_changes;
ok($ai->deferred);
ok($ai->is_deferred);
ok(!$ai->is_active);

$ai->update({ deferred => \'NULL' })->discard_changes;
#$ai->deferred(undef);
ok($ai->is_active);
ok(!$ai->deferred);
ok(!$ai->is_deferred);
ok(!$ai->is_completed);

$ai->update({ deferred => DateTime->now });
ok($ai->is_deferred);
ok(!$ai->is_completed);
ok(!$ai->is_active);

$ai->update({ deferred => \'NULL' })->discard_changes;
ok($ai->completed( DateTime->now() ));
ok($ai->completed);
ok($ai->is_completed);
ok(!$ai->is_active);
ok(!$ai->is_deferred);


isa_ok($ai->workflow_instance, 'BPM::Engine::Store::Result::ActivityInstanceState');
ok(!$ai->split);
isa_ok($ai->attributes, 'DBIx::Class::ResultSet');
#can_ok($ai, qw/join_should_fire/);

#-- workflow role

isa_ok($ai->workflow, 'Class::Workflow');
does_ok($ai->workflow_instance, 'Class::Workflow::Instance');
is($ai->workflow_instance->state->name, 'open.not_running.ready');
is($ai->state, 'open.not_running.ready');

done_testing();