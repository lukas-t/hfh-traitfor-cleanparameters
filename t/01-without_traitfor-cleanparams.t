use strict;
use warnings;

use Data::Clone;

use Test::More;

use_ok "HTML::FormHandler";

my $form = new_ok "HTML::FormHandler" => [ field_list => 
	[ foo => { type => "Text" }],
];

my $params = { bar => "data" };

$form->process(params => $params);

ok $form->has_input, "form has no input";
ok $form->ran_validation, "form was validated";

done_testing;

