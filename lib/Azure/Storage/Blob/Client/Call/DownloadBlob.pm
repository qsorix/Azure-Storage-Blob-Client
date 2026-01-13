package Azure::Storage::Blob::Client::Call::DownloadBlob;
use Moo;
use XML::LibXML;

has operation => (is => 'ro', init_arg => undef, default => 'DownloadBlob');
has endpoint_base => (is => 'ro', required => 1);
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

has account_name => (is => 'ro', required => 1);
has api_version => (is => 'ro', required => 1);
has if_none_match => (is => 'ro', required => 0);
has container => (is => 'ro', required => 1);
has blob_name => (is => 'ro', required => 1);

sub serialize_uri_parameters {
  my $self = shift;
  return {};
}

sub serialize_header_parameters {
  my $self = shift;
  my %headers = (
    'x-ms-version' => $self->api_version,
  );
  $headers{'If-None-Match'} = $self->if_none_match if defined $self->if_none_match;
  return \%headers;
}

sub serialize_body_parameters {
  my $self = shift;
  return {};
}

sub parse_response {
  my ($self, $response) = @_;
  # Download returns the whole HTTP::Response because to use etags the caller
  # needs to have access to headers and the status code.
  return $response;
}

1;
