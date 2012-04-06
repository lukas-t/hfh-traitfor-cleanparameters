use strict;
use warnings;

use Data::Clone;

use Test::More;

{
	package MyTestForm;
	use HTML::FormHandler::Moose;
	extends qw/HTML::FormHandler/;
	with qw/HTML::FormHandlerX::TraitFor::CleanParameters/;

	has_field foo => ( type => "Text");

	no HTML::FormHandler::Moose;
	1;
}

my $form = new_ok "MyTestForm";

my $params = { bar => "data" };
my $orig_params = clone($params);

$form->process(params => $params);

ok ! $form->has_input, "form has no input";

is_deeply $orig_params, $params, "original parameters remain unchanged";

$form->clear;

$params = { foo => "data" };
$orig_params = clone($params);

$form->process(params => $params);

ok $form->has_input, "form has input";

is_deeply $orig_params, $params, "original parameters remain unchanged";


done_testing;

