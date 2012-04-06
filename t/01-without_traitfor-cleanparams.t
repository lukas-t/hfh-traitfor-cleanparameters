use strict;
use warnings;

use Data::Clone;

use Test::More;

{
	package MyTestForm;
	use HTML::FormHandler::Moose;
	extends qw/HTML::FormHandler/;

	has_field foo => ( type => "Text");

	no HTML::FormHandler::Moose;
	1;
}

my $form = new_ok "MyTestForm";

my $params = { bar => "data" };

$form->process(params => $params);

ok $form->has_input, "form has no input";
ok $form->ran_validation, "form was validated";

done_testing;

