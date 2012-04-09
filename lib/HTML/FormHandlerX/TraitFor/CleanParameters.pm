package HTML::FormHandlerX::TraitFor::CleanParameters;

use Data::Clone;
use Carp qw/croak/;
use Moose::Role;

=head1 NAME

HTML::FormHandlerX::TraitFor::CleanParameters - remove unwanted parameters on "process" and "run"

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

in your form class:

	package YourForm;
	use HTML::FormHandler::Moose;
	extends 'HTML::FormHandler';
	with 'HTML::FormHandler::TraitFor::CleanParameters';

	has_field foo => ( ... );

	... 

	use namespace::autoclean; 
	1;

or in your code:

	my $form = My::Form::Class->new_with_traits(
		traits => HTML::FormHanderX::TraitFor::CleanParameters
	);

and then:

	$form->process(params => { bar => 1});


=head1 DESCRIPTION

This trait removes unwanted parameters from the parameters hash. 

The default behaviour of HTML::FormHandler is to validate a form on process or
run if was posted and it has input. Parameters which do not have corresponding 
fields in the form are ignored. An Example:

	package ExampleForm;

	use HTML::FormHandler::Moose;
	extends "HTML::FormHandler";

	has_field foo => ( type => "Text");

	no HTML::FormHandler::Moose;
	1;

	# and somewhere else
	
	my $form = ExampleForm->new;
	$form->process(params => { bar => 1 });

	print $form->has_input 		# prints "1"
	print $form->ran_validation # prints "1"

The form is validated and processed. If the "foo" field is required, 
validation would fail. This behaviour is correct in most situations, but 
there are rare cases where it is required to skip validation completely 
if the parameters hash is not empty, but none of the input parameters belongs 
to any of the forms fields. 

HTML::FormHandlerX::TraitFor::CleanParameters jumps in here. It hooks into the 
setup process and loops over the parameters. All parameters which do not have a 
corresponding field in the form are removed from the hash. 

The parameters hash is cloned before modification. This ensures that the request
parameters stay the same, before and after $form->process.

Another Example:

	package YourForm;
	use HTML::FormHandler::Moose;
	extends 'HTML::FormHandler';
	with 'HTML::FormHandler::TraitFor::CleanParameters';

	has_field foo => ( ... );

	... 

	use namespace::autoclean; 
	1;


	# and somewhere else
	
	my $form = YourForm->new;
	my $params = { bar => 1 };
	$form->process(params => $params); # $params remains unchanged
	
	print $form->has_input 		# prints "0"
	print $form->ran_validation # prints "0"

=cut

=head1 ATTRIBUTES

=head2 fields_by_parameter

A HashRef which stores Fields by their parameter name

=over

=item isa: HashRef[HTML::FormHandler::Field]

=item is: rw

=item required: yes

=item default: Empty HashRef

=back

=cut

has fields_by_parameter => (
	isa => "HashRef[HTML::FormHandler::Field]",
	is => 'rw',
	required => 1,
	default => sub{{}},
);

=head1 METHODS

=head2 has_field_for_parameter

=head3 parameters

=over 

=item  $parameter_name: String

=back

=head3 returns

=over

=item * 1 - if the form contains a field for the given parameter name

=item * 0 - if not

=back

=cut

sub has_field_for_parameter{
	my ($self, $paramname) = @_;
	my $field = $self->get_field_for_parameter($paramname);
	return $field ? 1 : 0;
}

=head2 get_field_for_parameter

=head3 parameters

=over 

=item  $parameter_name: String

=back

=head3 returns

=over

=item * The L<HTML::FormHandler::Field> for the given parameter name - if 
available

=item * undef - if not

=back

=cut

sub get_field_for_parameter{
	my ($self, $paramname) = @_;
	return unless $paramname;
	my $cleaned_paramname = $paramname;
	$cleaned_paramname =~ s/(\.\d+\.)/\./g;
	return $self->fields_by_parameter->{$cleaned_paramname}
		if $self->fields_by_parameter->{$cleaned_paramname};
 	my $field =  $self->field($cleaned_paramname);
	return $field if $field;
	# if repeatable fields are defined using the "contains" field,
	# the simple check will not work. 
	my @fields = (split /\./, $cleaned_paramname);
	my $fieldname = shift @fields;
	return unless $self->field($fieldname);
	while (@fields){
		my $curname = $fields[0];
		if($field = $self->field("$fieldname.$curname")){
			$fieldname = "$fieldname.$curname";
			shift @fields;
		}
		elsif($field = $self->field("$fieldname.contains")){
			$fieldname = "$fieldname.contains";
		}
		else{ return; }
	}
	if($field){
	$self->fields_by_parameter->{$cleaned_paramname} = $field;
	return $field;
	}
	return;
}

=head1 FUNCTIONS

=head2 values_to_fif 

Transforms a hashref as it would be returned by L<HTML::FormHandler/values>
to a hashref as it would be returned by L<HTML::FormHandler/fif>

=head3 parameters

=over 

=item $input: A HashRef suitable for L<HTML::FormHandler/values>

=item $name?: optional string, used for to recursively build parameter names

=back

=head3 returns

A HashRef suitable for L<HTML::FormHandler/fif>

=cut

sub values_to_fif{
	my ($input, $name) = @_;
	croak "values_to_fif expects a hashref" 
			unless $input && ref($input) && ref($input) eq "HASH";
	my $output = {};
	foreach my $key (keys %$input){
		my $data = $input->{$key};
		my $paramname = $name ? "$name.$key" : $key;
		if(ref($data) && ref($data) eq "HASH"){
			$output = {
				%$output, 
				%{values_to_fif($data, $paramname)}
			};
		}
		elsif(ref($data) && ref($data) eq "ARRAY"){
			my $count = 0;
			foreach (@$data){
			if(ref($_) && ref($_) eq "HASH"){
					my $result = values_to_fif($_, $paramname . "." . $count++);
				$output = {
					%$output, 
					%$result,
				};
			}else{
				$output->{$paramname . "." . $count++} = $_;
			}

			}
		}
		else{
			$output->{$paramname} = $data;
			
		}
	}
	use Data::Dumper;
	return $output;
}

=head1 INTERNALS

=head2 REQUIRED METHODS

The following methods have to be available in the consuming class:

=over

=item * field

=item * setup_form

=back

=cut

requires qw/
	setup_form
	field
/;

=head2 METHOD MODIFIERS

=over

=item around: setup_form

=back

=cut

around setup_form => sub{
	my ($orig, $self, @args) = @_;
	my %argshash;
	if(@args == 1){
		$argshash{params} = $args[0];
	}
	else{
		%argshash = @args;
	}
	if($argshash{params}){
		my $params = values_to_fif(clone($argshash{params}));
		foreach my $name ( keys %$params ){
			delete $params->{$name} 
				unless $self->has_field_for_parameter($name);
		}
		$argshash{params}  = $params;
	}

	$self->$orig(%argshash);
};

=head1 AUTHOR

Lukas Thiemeier, C<< <lukast at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-html-formhandlerx-traitfor-cleanparameters at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HTML-FormHandlerX-TraitFor-CleanParameters>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc HTML::FormHandlerX::TraitFor::CleanParameters


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=HTML-FormHandlerX-TraitFor-CleanParameters>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/HTML-FormHandlerX-TraitFor-CleanParameters>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/HTML-FormHandlerX-TraitFor-CleanParameters>

=item * Search CPAN

L<http://search.cpan.org/dist/HTML-FormHandlerX-TraitFor-CleanParameters/>

=back

=head1 ACKNOWLEDGEMENTS

All FormHandler contributers. See L<HTML::FormHandler/CONTRIBUTORS>.

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Lukas Thiemeier.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

no Moose::Role;
1; # End of HTML::FormHandlerX::TraitFor::CleanParameters
