use strict;
use warnings;

use Data::Clone;

use Test::More;

use_ok "HTML::FormHandler";

my $form = HTML::FormHandler->new_with_traits(
	traits => ["HTML::FormHandlerX::TraitFor::CleanParameters"], 
	field_list =>[foo => { type => "Text"}]);

my $params = { bar => "data" };
my $orig_params = clone($params);

$form->process(params => $params);

ok ! $form->has_input, "form has no input";
ok ! $form->ran_validation, "form was not validated";

is_deeply $orig_params, $params, "original parameters remain unchanged";

$form->clear;

$params = { foo => "data" };
$orig_params = clone($params);

$form->process(params => $params);

ok $form->has_input, "form has input";
ok $form->ran_validation, "form was validated";

is_deeply $orig_params, $params, "original parameters remain unchanged";


done_testing;

