package Meguro::Logic::AddressExtract;
use strict;
use warnings;
use Geography::AddressExtract::Japan;
#use encoding "utf8", STDOUT => "utf8";
no encoding;
#use utf8;
use Exporter;
our @EXPORT_OK = qw(
    extract_address
);

sub new {
    return __PACKAGE__;
}

sub extract_address {
    my ($class, $text) = @_;
    $text =~ s/\s+//g;
    my $ex = Geography::AddressExtract::Japan->extract($text);
    if (defined($ex) && ref($ex) eq 'ARRAY' && defined($ex->[0])) {
        # 字がひらがなだと抽出できないので条件を緩和する
        #if ($ex->[0]->city && $ex->[0]->aza) {
        #    return $ex->[0]->address;
        #}
        if ($ex->[0]->city) {
            if ($ex->[0]->aza or length($ex->[0]->city) > 5) {
                return $ex->[0]->address;
            }
        }
    }
    return;
}

1;

