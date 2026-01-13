package Azure::Storage::Blob::Client::Call;
use Moo::Role;

requires 'endpoint';
requires 'method';
requires 'operation';
requires 'serialize_uri_parameters';
requires 'serialize_header_parameters';
requires 'serialize_body_parameters';

1;
