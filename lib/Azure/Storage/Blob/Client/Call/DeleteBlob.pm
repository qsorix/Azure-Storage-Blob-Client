package Azure::Storage::Blob::Client::Call::DeleteBlob;
use Moo;
use Azure::Storage::Blob::Client::Exception;

has operation => (is => 'ro', init_arg => undef, default => 'DeleteBlob');
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
has method => (is => 'ro', init_arg => undef, default => 'DELETE');

with 'Azure::Storage::Blob::Client::Call';

has account_name => (is => 'ro', required => 1);
has api_version => (is => 'ro', required => 1);
has container => (is => 'ro', required => 1);
has blob_name => (is => 'ro', required => 1);
has delete_snapshots => (is => 'ro');

sub BUILD {
  my $self = shift;
  if ($self->delete_snapshots) {
    if ($self->delete_snapshots ne 'include' and $self->delete_snapshots ne 'only') {
      Azure::Storage::Blob::Client::Exception->throw({
        code => 'ValidationError',
        message => "'delete_snapshots' valid values are [include, only]",
      });
    }
  }
}

sub serialize_uri_parameters {
  my $self = shift;
  return {};
}

sub serialize_header_parameters {
  my $self = shift;
  my %headers = (
    'x-ms-version' => $self->api_version,
  );
  $headers{'x-ms-delete-snapshots'} = $self->delete_snapshots if defined $self->delete_snapshots;
  return \%headers;
}

sub serialize_body_parameters {
  my $self = shift;
  return {};
}

sub parse_response {
  my ($self, $response) = @_;
  return $response;
}

1;
