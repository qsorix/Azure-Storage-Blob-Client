package Azure::Storage::Blob::Client::Exception;
use Moo;
extends 'Throwable::Error';

has code => (is => 'ro', required => 1);

1;
