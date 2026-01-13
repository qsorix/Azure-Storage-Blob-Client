#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;

use Test::Spec::Acceptance;
use Azure::Storage::Blob::Client::Call;

Feature 'serialize_uri_parameters' => sub {
  my ($call, $serialized_parameters);

  Scenario 'call class without parameter attributes' => sub {
    Given 'an object with no paramater attributes' => sub {
      $call = Azure::Storage::Blob::Client::Test::CallClassWithNoParameters->new(
        att1 => 1,
        att2 => 2,
        att3 => 3,
      );
    };

    When 'calling \'serialize_uri_parameters\' on it' => sub {
      $serialized_parameters = $call->serialize_uri_parameters();
    };

    Then 'it should return an empty hash' => sub {
      is_deeply($serialized_parameters, {});
    };
  };

  Scenario 'call class with URIParameter attributes' => sub {
    Given 'an object with URIParamater attributes' => sub {
      $call = Azure::Storage::Blob::Client::Test::CallClassWithURIParameters->new(
        att1 => 1,
        att2 => 2,
        att3 => 3,
      );
    };

    When 'calling \'serialize_uri_parameters\' on it' => sub {
      $serialized_parameters = $call->serialize_uri_parameters();
    };

    Then 'it should return the keys/values of URIParameter attributes' => sub {
      is_deeply($serialized_parameters, {
          att2 => 2,
          att3 => 3,
      });
    };
  };

  Scenario 'call class with all types of parameter attributes' => sub {
    Given 'an object with URIParamater, HeaderParameter & BodyParameter attributes' => sub {
      $call = Azure::Storage::Blob::Client::Test::CallClassWithAllParameters->new(
        att1 => 1,
        att2 => 2,
        att3 => 3,
        att4 => 4,
        att5 => 5,
      );
    };

    When 'calling \'serialize_uri_parameters\' on it' => sub {
      $serialized_parameters = $call->serialize_uri_parameters();
    };

    Then 'it should return the keys/values of URIParameter attributes' => sub {
      is_deeply($serialized_parameters, {
          att1 => 1,
          att4 => 4,
      });
    };
  };
};

Feature 'serialize_header_parameters' => sub {
  my ($call, $serialized_parameters);

  Scenario 'call class without parameter attributes' => sub {
    Given 'an object with no paramater attributes' => sub {
      $call = Azure::Storage::Blob::Client::Test::CallClassWithNoParameters->new(
        att1 => 1,
        att2 => 2,
        att3 => 3,
      );
    };

    When 'calling \'serialize_header_parameters\' on it' => sub {
      $serialized_parameters = $call->serialize_header_parameters();
    };

    Then 'it should return an empty hash' => sub {
      is_deeply($serialized_parameters, {});
    };
  };

  Scenario 'call class with HeaderParameter attributes' => sub {
    Given 'an object with HeaderParameter attributes' => sub {
      $call = Azure::Storage::Blob::Client::Test::CallClassWithHeaderParameters->new(
        att1 => 1,
        att2 => 2,
        att3 => 3,
      );
    };

    When 'calling \'serialize_header_parameters\' on it' => sub {
      $serialized_parameters = $call->serialize_header_parameters();
    };

    Then 'it should return the keys/values of HeaderParameter attributes' => sub {
      is_deeply($serialized_parameters, {
          h2 => 2,
          h3 => 3,
      });
    };
  };

  Scenario 'call class with all types of parameter attributes' => sub {
    Given 'an object with URIParamater, HeaderParameter & BodyParameter attributes' => sub {
      $call = Azure::Storage::Blob::Client::Test::CallClassWithAllParameters->new(
        att1 => 1,
        att2 => 2,
        att3 => 3,
        att4 => 4,
        att5 => 5,
      );
    };

    When 'calling \'serialize_header_parameters\' on it' => sub {
      $serialized_parameters = $call->serialize_header_parameters();
    };

    Then 'it should return the keys/values of HeaderParameter attributes' => sub {
      is_deeply($serialized_parameters, {
          h2 => 2,
          h4 => 4,
      });
    };
  };
};

Feature 'serialize_body_parameters' => sub {
  my ($call, $serialized_parameters);

  Scenario 'call class without parameter attributes' => sub {
    Given 'an object with no paramater attributes' => sub {
      $call = Azure::Storage::Blob::Client::Test::CallClassWithNoParameters->new(
        att1 => 1,
        att2 => 2,
        att3 => 3,
      );
    };

    When 'calling \'serialize_body_parameters\' on it' => sub {
      $serialized_parameters = $call->serialize_body_parameters();
    };

    Then 'it should return an empty hash' => sub {
      is_deeply($serialized_parameters, {});
    };
  };

  Scenario 'call class with BodyParameter attributes' => sub {
    Given 'an object with BodyParameter attributes' => sub {
      $call = Azure::Storage::Blob::Client::Test::CallClassWithBodyParameters->new(
        att1 => 1,
        att2 => 2,
        att3 => 3,
      );
    };

    When 'calling \'serialize_body_parameters\' on it' => sub {
      $serialized_parameters = $call->serialize_body_parameters();
    };

    Then 'it should return the keys/values of BodyParameter attributes' => sub {
      is_deeply($serialized_parameters, {
          att2 => 2,
          att3 => 3,
      });
    };
  };

  Scenario 'call class with all types of parameter attributes' => sub {
    Given 'an object with URIParamater, BodyParameter & BodyParameter attributes' => sub {
      $call = Azure::Storage::Blob::Client::Test::CallClassWithAllParameters->new(
        att1 => 1,
        att2 => 2,
        att3 => 3,
        att4 => 4,
        att5 => 5,
      );
    };

    When 'calling \'serialize_body_parameters\' on it' => sub {
      $serialized_parameters = $call->serialize_body_parameters();
    };

    Then 'it should return the keys/values of BodyParameter attributes' => sub {
      is_deeply($serialized_parameters, {
          att3 => 3,
          att4 => 4,
      });
    };
  };
};

package Azure::Storage::Blob::Client::Test::CallClassWithNoParameters {
  use Moo;
  with 'Azure::Storage::Blob::Client::Call';

  has att1 => (is => 'ro', required => 1);
  has att2 => (is => 'ro', required => 1);
  has att3 => (is => 'ro', required => 1);

  # required by Call role
  sub operation {}
  sub method {}
  sub endpoint {}

  sub serialize_uri_parameters { return {}; }
  sub serialize_header_parameters { return {}; }
  sub serialize_body_parameters { return {}; }
};

package Azure::Storage::Blob::Client::Test::CallClassWithURIParameters {
  use Moo;
  with 'Azure::Storage::Blob::Client::Call';

  has att1 => (is => 'ro', required => 1);
  has att2 => (is => 'ro', required => 1);
  has att3 => (is => 'ro', required => 1);

  # required by Call role
  sub operation {}
  sub method {}
  sub endpoint {}

  sub serialize_uri_parameters {
    my $self = shift;
    return {
      att2 => $self->att2,
      att3 => $self->att3,
    };
  }
  sub serialize_header_parameters { return {}; }
  sub serialize_body_parameters { return {}; }
};

package Azure::Storage::Blob::Client::Test::CallClassWithHeaderParameters {
  use Moo;
  with 'Azure::Storage::Blob::Client::Call';

  has att1 => (is => 'ro', required => 1);
  has att2 => (is => 'ro', required => 1);
  has att3 => (is => 'ro', required => 1);

  # required by Call role
  sub operation {}
  sub method {}
  sub endpoint {}

  sub serialize_uri_parameters { return {}; }
  sub serialize_header_parameters {
    my $self = shift;
    return {
      h2 => $self->att2,
      h3 => $self->att3,
    };
  }
  sub serialize_body_parameters { return {}; }
};

package Azure::Storage::Blob::Client::Test::CallClassWithBodyParameters {
  use Moo;
  with 'Azure::Storage::Blob::Client::Call';

  has att1 => (is => 'ro', required => 1);
  has att2 => (is => 'ro', required => 1);
  has att3 => (is => 'ro', required => 1);

  # required by Call role
  sub operation {}
  sub method {}
  sub endpoint {}

  sub serialize_uri_parameters { return {}; }
  sub serialize_header_parameters { return {}; }
  sub serialize_body_parameters {
    my $self = shift;
    return {
      att2 => $self->att2,
      att3 => $self->att3,
    };
  }
};

package Azure::Storage::Blob::Client::Test::CallClassWithAllParameters {
  use Moo;
  with 'Azure::Storage::Blob::Client::Call';

  has att1 => (is => 'ro', required => 1);
  has att2 => (is => 'ro', required => 1);
  has att3 => (is => 'ro', required => 1);
  has att4 => (is => 'ro', required => 1);
  has att5 => (is => 'ro', required => 1);

  # required by Call role
  sub operation {}
  sub method {}
  sub endpoint {}

  sub serialize_uri_parameters {
    my $self = shift;
    return {
      att1 => $self->att1,
      att4 => $self->att4,
    };
  }
  sub serialize_header_parameters {
    my $self = shift;
    return {
      h2 => $self->att2,
      h4 => $self->att4,
    };
  }
  sub serialize_body_parameters {
    my $self = shift;
    return {
      att3 => $self->att3,
      att4 => $self->att4,
    };
  }
};

runtests unless caller;
