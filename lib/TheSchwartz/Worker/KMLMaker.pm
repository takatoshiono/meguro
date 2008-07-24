package TheSchwartz::Worker::KMLMaker;

use strict;
use warnings;

our $VERSION = '0.01';

use base qw(TheSchwartz::Worker);

use FindBin::libs;
use FindBin;
use URI;
use Digest::MD5 qw(md5_hex);
use Template;

use Meguro::Logic::AddressExtract;
use Meguro::Logic::Scraper;
use Meguro::Logic::Geocoder;

use Meguro::Schema;

sub work {
    my ($class, $job) = @_;

    my $urls = $job->arg->{urls};
    my $scraper_args = $job->arg->{scraper_args};

    my $scraper = Meguro::Logic::Scraper->mk_scraper($scraper_args);
    my $geocoder = Meguro::Logic::Geocoder->new();

    my @items;
    foreach my $url (@$urls) {
        my @sub_items;

        my $result = $scraper->scrape(URI->new($url));

        my ($address_infos, $names, $comments) = @$result{qw(address name comment)};
        $names ||= [];
        $comments ||= [];

        # 経度緯度が取得できない住所情報は取り除く
        INFO:
        foreach my $address (@$address_infos) {
            next INFO unless $address;
            my $extracted = Meguro::Logic::AddressExtract->extract_address($address);
            if ($extracted) {
                my ($lat, $lng) = $geocoder->get_lat_lng($extracted);
                # 経度緯度が取れないこともある
                # (e.g.東京都 西多摩郡日の出町 大字平井字三吉野桜木557(TSUTAYAイオンモール日の出)
                push @sub_items, {
                    address   => $address,
                    extracted => $extracted,
                    lat       => $lat || 0,
                    lng       => $lng || 0,
                };
            }
        }

        # 住所と名前の対応関係を結び付けているものは順番だけなので、
        # 住所抽出、経度緯度変換の結果、順番が狂うことがある

        if (!@$names or @sub_items == @$names) {
            for (my $i = 0; $i < @sub_items; $i++) {
                my $sub = $sub_items[$i];
                if ($sub->{lat} && $sub->{lng}) {
                    $sub->{url} = $url;
                    $sub->{name} = $names->[$i] || $sub->{extracted};
                    $sub->{comment} = $comments->[$i] || '';
                    push @items, $sub;
                }
            }
        }
    }

    if (@items) {
        # Make KML file
        my $unique_id = md5_hex((0+$scraper).time);
        my $kml_file = sprintf("$FindBin::Bin/../root/static/kml/%s.kml", $unique_id);

        my $tt = Template->new({
            INCLUDE_PATH       => "$FindBin::Bin/../root/templates",
            TEMPLATE_EXTENSION => '.tt2',
        });

        $tt->process('kml.tt2', {
            items => \@items,
        }, $kml_file);

        my $schema = Meguro::Schema->connect('dbi:mysql:meguro', 'root', undef,
            { AutoCommit => 1, RaiseError => 1 }
        );

        $schema->resultset('JobMan')->create({
            jobid    => $job->jobid,
            uniqueid => $unique_id,
        });
    }

    $job->completed();
}

1;

