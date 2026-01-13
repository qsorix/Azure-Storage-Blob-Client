package Azure::Storage::Blob::Client::Call::GetBlobProperties;
use Moo;

has operation => (is => 'ro', init_arg => undef, default => 'GetBlobProperties');
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
has method => (is => 'ro', init_arg => undef, default => 'HEAD');

with 'Azure::Storage::Blob::Client::Call';

has account_name => (is => 'ro', required => 1);
has api_version => (is => 'ro', required => 1);
has container => (is => 'ro', required => 1);
has blob_name => (is => 'ro', required => 1);

sub serialize_uri_parameters {
  my $self = shift;
  return {};
}

sub serialize_header_parameters {
  my $self = shift;
  return {
    'x-ms-version' => $self->api_version,
  };
}

sub serialize_body_parameters {
  my $self = shift;
  return {};
}

sub parse_response {
  my ($self, $response) = @_;
  return { $response->headers->flatten() };
}

1;
