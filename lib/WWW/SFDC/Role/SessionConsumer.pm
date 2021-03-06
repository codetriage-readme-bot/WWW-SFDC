package WWW::SFDC::Role::SessionConsumer;
# ABSTRACT: Provides a transparent interface to WWW::SFDC::SessionManager

use 5.12.0;
use strict;
use warnings;

# VERSION

use Moo::Role;
use Module::Loaded;

requires qw'_extractURL';

=attr session

This is a WWW::SFDC object, and is required when this module is constructed.

=cut

has 'session',
  is => 'ro',
  required => 1;

=attr url

The API endpoint URL for the consuming module. For instance, for the metadata
API, this will contain C</m/>, and for the tooling API will contain C</T/>.
This is constructed using the _extractURL method in the consuming object,
which is required.

=cut

has 'url',
  is => 'ro',
  lazy => 1,
  builder => '_buildURL';

sub _buildURL {
  my $self = shift;
  return $self->_extractURL($self->session->loginResult());
}

=method _call

The consuming class can use C<$self->_call(@params);> - this will handle
calling the underlying session with the correct URI and URL. The URI is
defined in the  consuming class.

=cut

sub _call {
  my $self = shift;
  return $self->session->call(
    $self->url(),
    $self->uri(),
    @_
  );
}

sub _sleep {
  my $self = shift;
  sleep $self->session->pollInterval;
}

1;

__END__

=head1 SYNOPSIS

    package Example;
    use Moo;
    with "WWW::SFDC::Role::Session";

    sub _extractURL {
      # this is a required method. $_[0] is self, as normal.
      # $_[1] is the loginResult hash, which has a serverUrl as
      # well as a metadataServerUrl defined.
      return $_[1]->{serverUrl};
    }

    # uri is a required property, containing the default namespace
    # for the SOAP request.
    has 'uri', is => 'ro', default => 'urn:partner.soap.salesforce.com';

    sub doSomething {
      my $self = shift;
      # this uses the above-defined uri and url, and generates
      # a new sessionId upon an INVALID_SESSION_ID error:
      return $self->_call('method', @_);
    }

    1;

=head1 BUGS

Please report any bugs or feature requests at L<https://github.com/sophos/WWW-SFDC/issues>.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::SFDC::Role::Session

You can also look for information at L<https://github.com/sophos/WWW-SFDC>
