package Azure::Storage::Blob::Client::Call::DownloadBlob;
use Moose;
use Azure::Storage::Blob::Client::Meta::Attribute::Custom::Trait::URIParameter;
use Azure::Storage::Blob::Client::Meta::Attribute::Custom::Trait::HeaderParameter;
use XML::LibXML;

has operation => (is => 'ro', init_arg => undef, default => 'DownloadBlob');
has endpoint_base => (is => 'ro', isa => 'Str', required => 1);
has endpoint => (is => 'ro', init_arg => undef, lazy => 1, default => sub {
  my $self = shift;
  return sprintf(
    '%s/%s/%s',
    $self->endpoint_base,
    $self->container,
    $self->blob_name,
  );
});
has method => (is => 'ro', init_arg => undef, default => 'GET');

with 'Azure::Storage::Blob::Client::Call';

has account_name => (is => 'ro', isa => 'Str', required => 1);
has api_version => (is => 'ro', isa => 'Str', traits => ['HeaderParameter'], header_name => 'x-ms-version', required => 1);
has if_none_match => (is => 'ro', isa => 'Maybe[Str]', traits => ['HeaderParameter'], header_name => 'If-None-Match');
has container => (is => 'ro', isa => 'Str', required => 1);
has blob_name => (is => 'ro', isa => 'Str', required => 1);

sub parse_response {
  my ($self, $response) = @_;
  # Download returns the whole HTTP::Response because to use etags the caller
  # needs to have access to headers and the status code.
  return $response;
}

__PACKAGE__->meta->make_immutable();

1;
