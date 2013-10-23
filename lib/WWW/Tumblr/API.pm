package WWW::Tumblr::API;

use strict;
use warnings;

use Moo;
use JSON 'decode_json';

use parent 'Exporter';

our @EXPORT = qw/tumblr_api_method/;
use WWW::Tumblr::ResponseError;

sub tumblr_api_method ($$) {
    my $class = caller;
    my $method_name = $_[0];
    my $method_spec = $_[1];

    no strict 'refs';
    *{"$class\::$method_name"} = sub {
        use strict 'refs';

        my $self = shift;
        my $args = { @_ };

        my ( $http_method, $auth_method, $req_params, $url_param ) = @{ $method_spec };
        my $kind = lc( pop( @{ [ split '::', ref $self ] }));
        my $response = $self->_tumblr_api_request({
            auth        => $auth_method,
            http_method => $http_method,
            url_path    => $kind . '/' . ( $kind eq 'blog' ? $self->base_hostname . '/' : '' ) .
                            join('/', split /_/, $method_name) .
                            ( defined $url_param && defined $args->{ $url_param } ?
                                '/' . delete( $args->{ $url_param } ) : ''
                            ),
            extra_args  => $args,
        });

        if ( $response->is_success || ( $response->code == 301 && $method_name eq 'avatar') ) {
            return decode_json($response->decoded_content)->{response};
        } else {
            $self->error( WWW::Tumblr::ResponseError->new(
                response => $response
            ) );
            return;
        }
    };
}

1;
