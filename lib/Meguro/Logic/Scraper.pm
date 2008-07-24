package Meguro::Logic::Scraper;
use strict;
use warnings;

our $VERSION = '0.01';

use Web::Scraper;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self;
}

sub mk_scraper {
    my ($self, $args) = @_;

    my @processes;
    if ($args->{address}) {
        push @processes, sub{ process($args->{address}, 'address[]' => 'TEXT') };
    }
    if ($args->{name}) {
        push @processes, sub{ process($args->{name}, 'name[]' => 'TEXT') };
    }
    if ($args->{comment}) {
        push @processes, sub{ process($args->{comment}, 'comment[]' => 'TEXT') };
    }

    Carp::croak "no processes to scrape" unless @processes;

    return scraper {
        $_->() for @processes;
    };
    #return scraper {
    #    process $args->{address}, address => 'TEXT';
    #    process $args->{name},    name    => 'TEXT';
    #    process $args->{comment}, comment => 'TEXT';
    #};
}

1;

