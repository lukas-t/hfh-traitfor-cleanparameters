package HTML::FormHandlerX::TraitFor::CleanParameters;

use Data::Clone;
use Moose::Role;

=head1 NAME

HTML::FormHandlerX::TraitFor::CleanParameters - Cleaning up parameters before L<HTML::FormHandler/process>

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    package YourForm;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::TraitFor::CleanParameters';

    has_field foo => ( ... );

    ... 

    use namespace::autoclean; 
    1;


=head1 DESCRIPTION

This trait hooks into the formhandler workflow before "setup_form" is called.
It loops over the parameters and removes all parameters which do not have a
corresponding field in the form.

Validation and further processing of the form is skipped, unless a parameters
which is realy ment to be processed by the form is given.

The parameter hash is cloned before modification. The original hash passed to
$form->process remains unchanged.

=head2 Note on repeatable and compound fields:

The current version of this module does not perform any  deep inspecton of the 
parameters.

If you pass parameters for repeatable or compound fields as a nested 
hashref:

	$form->process(params => {
		foo => [
			{ bar => 1, baz => 1},
			{ bar => 2, baz => 2},
		]
	});

extra parameters in the second (or deeper) level are not detected. Make sure to
pass your parameters as they yould be returned by $form->fif:

 	$form->process(params => {
		"foo.0.bar" => 1,
		"foo.0.baz" => 1,
		"foo.1.bar" => 2,
		"foo.1.baz" => 2,
	});

=cut

requires qw/
	setup_form
	field
/;

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
		my $params = clone($argshash{params});
		foreach my $name ( keys %$params ){
			delete $params->{$name} 
				unless $self->has_field_for_parameter($name);
		}
		$argshash{params}  = $params;
	}

	$self->$orig(%argshash);
};

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

=over

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

=over

=cut

sub get_field_for_parameter{
	my ($self, $paramname) = @_;
	return unless $paramname;
	my $cleaned_paramname = $paramname;
	$cleaned_paramname =~ s/(\.d+\.)/\./g;
 	return $self->field($cleaned_paramname);
}

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

See L<HTML::FormHandler/CONTRIBUTORS>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Lukas Thiemeier.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

no Moose::Role;
1; # End of HTML::FormHandlerX::TraitFor::CleanParameters
