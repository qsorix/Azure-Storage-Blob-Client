package Azure::Storage::Blob::Client::Call::ListBlobs;
use Moo;
use XML::LibXML;

has operation => (is => 'ro', init_arg => undef, default => 'ListBlobs');
has endpoint_base => (is => 'ro', required => 1);
has endpoint => (is => 'ro', init_arg => undef, lazy => 1, default => sub {
  my $self = shift;
  return sprintf(
    '%s/%s?restype=container&comp=list',
    $self->endpoint_base,
    $self->container,
  );
});
has method => (is => 'ro', init_arg => undef, default => 'GET');

with 'Azure::Storage::Blob::Client::Call';

has account_name => (is => 'ro', required => 1);
has api_version => (is => 'ro', required => 1);
has container => (is => 'ro', required => 1);
has prefix => (is => 'ro', required => 1);
has maxresults => (is => 'ro', required => 0);
has marker => (is => 'ro', required => 0);
has auto_retrieve_paginated_results => (is => 'ro', default => 0);

sub serialize_uri_parameters {
  my $self = shift;
  my %params = ();
  $params{prefix} = $self->prefix if defined $self->prefix;
  $params{maxresults} = $self->maxresults if defined $self->maxresults;
  $params{marker} = $self->marker if defined $self->marker;
  return \%params;
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
  my $dom = XML::LibXML->load_xml(string => $response->content);

  return {
    Blobs => [
      map { $_->to_literal() } $dom->findnodes('/EnumerationResults/Blobs/Blob/Name')
    ],
    $dom->findnodes('/EnumerationResults/NextMarker')
      ? ( NextMarker => shift @{[ map { $_->to_literal() } $dom->findnodes('/EnumerationResults/NextMarker') ]} )
      : (),
  };
}

1;
