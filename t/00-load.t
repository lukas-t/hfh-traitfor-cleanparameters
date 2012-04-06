#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'HTML::FormHandlerX::TraitFor::CleanParameters' ) || print "Bail out!\n";
}

diag( "Testing HTML::FormHandlerX::TraitFor::CleanParameters $HTML::FormHandlerX::TraitFor::CleanParameters::VERSION, Perl $], $^X" );
