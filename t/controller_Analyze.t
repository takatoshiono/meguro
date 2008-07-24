use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Meguro' }
BEGIN { use_ok 'Meguro::Controller::Analyze' }

ok( request('/analyze')->is_success, 'Request should succeed' );


