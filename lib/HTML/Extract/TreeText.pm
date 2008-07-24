package HTML::Extract::TreeText;
use strict;
use warnings;
use HTML::TreeBuilder;
use List::Util qw(first);
use Carp;

our $VERSION = '0.01';

sub new {
    my ($class) = @_;
    bless {}, $class;
}

sub extract_file {
    my ($self, $file) = @_;

    if (open my $fh, '<', $file) {
        my $content = do {local $/; <$fh>};
        close $fh;
        return $self->extract($content);
    }
    else {
        Carp::croak "Cannot open $file: $!";
    }
}

sub extract_url {
    my ($self, $url) = @_;

    use LWP::UserAgent;

    my $ua = LWP::UserAgent->new();
    my $res = $ua->get($url);

    require Encode;
    require HTTP::Response::Encoding;

    if ($res->is_success) {
        # Encoding code from Web::Scraper
        my @encoding = (
            $res->encoding,
            # could be multiple because HTTP response and META might be diffrent
            ($res->header('Content-Type') =~ /charset =~ ([\w\-]+)/g),
            'latin-1',
        );
        my $encoding = first { defined $_ && Encode::find_encoding($_) } @encoding;
        my $content = Encode::decode($encoding, $res->content);
        return $self->extract($content);
    }
    else {
        Carp::croak "Cannot get $url: " . $res->status_line();
    }
}

sub extract {
    my ($self, $content) = @_;

    my $tree = HTML::TreeBuilder->new();
    $tree->parse_content($content);
    $self->guts_recursive($tree);
    $tree->delete();

    return $self->{text};
}

sub guts_recursive {
    my ($self, $el, @parents) = @_;
    if (ref $el) {
        return if $el->is_empty();
        my $tag = $el->tag();
        if (my $id = $el->attr('id')) {
            $tag .= sprintf('[@id="%s"]', $id);
        }
        elsif (my $class = $el->attr('class')) {
            $tag .= sprintf('[@class="%s"]', $class);

            # for tenya
            #if ($tag !~ /^(table|tr)$/i) {
            #    $tag .= sprintf('[@class="%s"]', $class);
            #}
        }
        push @parents, $tag;
        if ($el->can('content_list')) {
            $self->guts_recursive($_, @parents) for $el->content_list();
        }
    }
    else {
        #print "@parents > $el", "\n";
        my $xpath = '//' . join q{/}, @parents;
        no warnings 'uninitialized';
        $self->{text}{$xpath} .= $el;
    }
}

sub dump {
    my $self = shift;
    my $text_of = $self->{text};

    foreach my $xpath (sort keys %$text_of) {
        print "$xpath : $text_of->{$xpath}\n";
    }
}

1;

__END__

