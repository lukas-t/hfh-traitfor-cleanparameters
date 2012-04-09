use strict;
use warnings;
use Test::More;

# NOTE: This file is a copy t/repeatable/nested.t (with HFH::TraitFor::CleanParameters applied to it

# This test uses roles to create forms and fields
# and nests the repeatables

{
    package Test::Form::Role::Employee;
    use HTML::FormHandler::Moose::Role;

    has_field 'first_name';
    has_field 'last_name';
    has_field 'email';
    has_field 'password';
}

{
    package Test::Form::Employee;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    with 'Test::Form::Role::Employee';
}

{
    package Test::Form::Field::Employee;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Compound';

    has_field 'id' => ( type => 'PrimaryKey' );
    with 'Test::Form::Role::Employee';
}

{
    package Test::Form::Role::Office;
    use HTML::FormHandler::Moose::Role;

    has_field 'address';
    has_field 'city';
    has_field 'state';
    has_field 'zip';
    has_field 'phone';
    has_field 'fax';
    has_field 'employees' => ( type => 'Repeatable' );
    has_field 'employees.contains' =>  ( type =>  '+Test::Form::Field::Employee' );

}

{
    package Test::Form::Field::Office;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Compound';

    has_field 'id' => ( type => 'PrimaryKey' );
    with 'Test::Form::Role::Office';

}

{
    package Test::Form::Office;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with qw/
    	Test::Form::Role::Office
	HTML::FormHandlerX::TraitFor::CleanParameters
    /;

}

{
    package Test::Form::Company;

    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with qw/
	HTML::FormHandlerX::TraitFor::CleanParameters
    /;

    has '+item_class' => (
        default => 'Company'
    );

    has_field 'name';
    has_field 'username';
    has_field 'tier';
    has_field 'type';

    has_field 'offices' => ( type => 'Repeatable' );
    has_field 'offices.contains' => ( type => '+Test::Form::Field::Office' );

}

my $field = Test::Form::Field::Employee->new( name => 'test_employee' );
ok( $field, 'field created' );
is( $field->num_fields, 5, 'right number of fields' );

my $form = Test::Form::Company->new;
my $params = {
    name => 'my_name',
    username => 'a_user',
    tier => 1,
    type => 'simple',
    offices => [
        {
            id => 1,
            address => '101 Main St',
            city => 'Smallville',
            state => 'CA',
            employees => [
                {
                    id => 1,
                    first_name => 'John',
                    last_name  => 'Doe',
                    email      => 'jdoe@gmail.com',
                },
                {
                    id => 2,
                    first_name => 'Jim',
                    last_name  => 'Doe',
                    email      => 'jimd@gmail.com',
                },
            ]
        },
        {
            id => 3,
            address => '101 Main St',
            city => 'Smallville',
            state => 'CA',
            employees => [
                {
                    id => 4,
                    first_name => 'Jim',
                    last_name  => 'Doe',
                    email      => 'jimd@gmail.com',
                },
            ]
        },
        {
            id => 2,
            address => '101 Main St',
            city => 'Smallville',
            state => 'CA',
            employees => [
                {
                    id => 1,
                    first_name => 'John',
                    last_name  => 'Doe',
                    email      => 'jdoe@gmail.com',
                },
                {
                    id => 2,
                    first_name => 'Jim',
                    last_name  => 'Doe',
                    email      => 'jimd@gmail.com',
                },
                {
                    id => 3,
                    first_name => 'Jim',
                    last_name  => 'Doe',
                    email      => 'jimd@gmail.com',
                },
            ]
        },
    ]
};
$form->process( params => $params );
ok( $form, 'form built' );
ok( $form->validated, "form validated");
my $fif = $form->fif;
my $value = $form->value;
my $expected = {
   'name' => 'my_name',
   'offices.0.address' => '101 Main St',
   'offices.0.city' => 'Smallville',
   'offices.0.employees.0.email' => 'jdoe@gmail.com',
   'offices.0.employees.0.first_name' => 'John',
   'offices.0.employees.0.id' => 1,
   'offices.0.employees.0.last_name' => 'Doe',
   'offices.0.employees.0.password' => '',
   'offices.0.employees.1.email' => 'jimd@gmail.com',
   'offices.0.employees.1.first_name' => 'Jim',
   'offices.0.employees.1.id' => 2,
   'offices.0.employees.1.last_name' => 'Doe',
   'offices.0.employees.1.password' => '',
   'offices.0.fax' => '',
   'offices.0.id' => 1,
   'offices.0.phone' => '',
   'offices.0.state' => 'CA',
   'offices.0.zip' => '',
   'offices.1.address' => '101 Main St',
   'offices.1.city' => 'Smallville',
   'offices.1.employees.0.email' => 'jimd@gmail.com',
   'offices.1.employees.0.first_name' => 'Jim',
   'offices.1.employees.0.id' => 4,
   'offices.1.employees.0.last_name' => 'Doe',
   'offices.1.employees.0.password' => '',
   'offices.1.fax' => '',
   'offices.1.id' => 3,
   'offices.1.phone' => '',
   'offices.1.state' => 'CA',
   'offices.1.zip' => '',
   'offices.2.address' => '101 Main St',
   'offices.2.city' => 'Smallville',
   'offices.2.employees.0.email' => 'jdoe@gmail.com',
   'offices.2.employees.0.first_name' => 'John',
   'offices.2.employees.0.id' => 1,
   'offices.2.employees.0.last_name' => 'Doe',
   'offices.2.employees.0.password' => '',
   'offices.2.employees.1.email' => 'jimd@gmail.com',
   'offices.2.employees.1.first_name' => 'Jim',
   'offices.2.employees.1.id' => 2,
   'offices.2.employees.1.last_name' => 'Doe',
   'offices.2.employees.1.password' => '',
   'offices.2.employees.2.email' => 'jimd@gmail.com',
   'offices.2.employees.2.first_name' => 'Jim',
   'offices.2.employees.2.id' => 3,
   'offices.2.employees.2.last_name' => 'Doe',
   'offices.2.employees.2.password' => '',
   'offices.2.fax' => '',
   'offices.2.id' => 2,
   'offices.2.phone' => '',
   'offices.2.state' => 'CA',
   'offices.2.zip' => '',
   'tier' => 1,
   'type' => 'simple',
   'username' => 'a_user',
};
is_deeply( $fif, $expected, 'fif is correct' );
is_deeply( $value, $params, 'value is correct' );

# following takes some pieces of above tests and tests using
# a Repeatable subclass
{

{
    package Test::Form::Field::RepEmployee;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Repeatable';

    has_field 'id' => ( type => 'PrimaryKey' );
    with 'Test::Form::Role::Employee';
}

{
    package Test::Form::Role::RepOffice;
    use HTML::FormHandler::Moose::Role;

    has_field 'address';
    has_field 'city';
    has_field 'state';
    has_field 'zip';
    has_field 'phone';
    has_field 'fax';
    has_field 'employees' => ( type => '+Test::Form::Field::RepEmployee' );

}

{
    package Test::Form::RepOffice;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with qw/
    	Test::Form::Role::RepOffice
	HTML::FormHandlerX::TraitFor::CleanParameters
    /;

}

my $field = Test::Form::Field::RepEmployee->new( name => 'test_employee' );
ok( $field, 'field created' );
is( $field->num_fields, 5, 'right number of fields' );

my $form = Test::Form::RepOffice->new;
my $params = {
    address => '101 Main St',
    city => 'Smallville',
    state => 'CA',
    employees => [
        {
            id => 1,
            first_name => 'John',
            last_name  => 'Doe',
            email      => 'jdoe@gmail.com',
        }
    ]
};
$form->process( params => $params );
ok( $form, 'form built' );
my $fif = $form->fif;
my $value = $form->value;
my $expected = {
   'address' => '101 Main St',
   'city' => 'Smallville',
   'employees.0.email' => 'jdoe@gmail.com',
   'employees.0.first_name' => 'John',
   'employees.0.id' => 1,
   'employees.0.last_name' => 'Doe',
   'employees.0.password' => '',
   'fax' => '',
   'phone' => '',
   'state' => 'CA',
   'zip' => '',
};
is_deeply( $fif, $expected, 'fif is correct' );
is_deeply( $value, $params, 'value is correct' );

}

{
    package MyForm;

    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with qw/
	HTML::FormHandlerX::TraitFor::CleanParameters
    /;

    has_field 'name' => ( type => 'Text' );
    has_field 'args' => ( type => '+MyForm::Args' );


    package MyForm::Args;

    use HTML::FormHandler::Moose;
    use namespace::autoclean;

    extends 'HTML::FormHandler::Field::Compound';

    has_field 'id'        => (type => 'Text');
    has_field 'data'      => (type => 'Repeatable');
    has_field 'data.type' => (type => 'Text');
    has_field 'data.links' => (type => 'Repeatable');
    has_field 'data.links.title' => (type => 'Text');
    has_field 'data.links.url'   => (type => 'Text');
}

$form = MyForm->new;
ok( $form, 'form built' );

$form->process( params => {} );

my $rendered = $form->render;
like( $rendered, qr/"args.data.0.links.0.title"/, 'form has args.data.link.title in Repeatable' );

done_testing;
