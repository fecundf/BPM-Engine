
package BPM::Engine::API;
BEGIN {
    $BPM::Engine::API::VERSION   = '0.001';
    $BPM::Engine::API::AUTHORITY = 'cpan:SITETECH';
    }

use Moose::Role;
use namespace::autoclean;

requires qw(
  new
  new_with_config
  
  logger
  log_dispatch_conf

  log
  debug
  info
  notice
  warning
  error
  critical
  alert
  emergency

  schema
  storage
  connect_info

  callback

  list_packages
  create_package
  delete_package
  list_process_definitions
  get_process_definition

  list_process_instances
  create_process_instance
  get_process_instance
  start_process_instance
  terminate_process_instance
  abort_process_instance
  delete_process_instance
  process_instance_attribute
  change_process_instance_state

  list_activity_instances
  get_activity_instance
  change_activity_instance_state
  activity_instance_attribute

  _runner
);

no Moose::Role;

1;
__END__