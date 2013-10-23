package WWW::Tumblr::Authentication;

use strict;
use warnings;

use parent 'WWW::Tumblr';

use WWW::Tumblr::Authentication::None;
use WWW::Tumblr::Authentication::APIKey;
use WWW::Tumblr::Authentication::OAuth;

1;
