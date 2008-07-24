package Meguro::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

use YAML;
use URI;
use Digest::MD5 qw(md5_hex);
use TheSchwartz;
use DateTime;

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

Meguro::Controller::Root - Root Controller for Meguro

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 default

=cut

sub default : Private {
    my ($self, $c) = @_;
}

=head2 index

=cut

sub index : Private {
    my ($self, $c) = @_;

    my $kml = $c->model('DBIC::Kml')->search(undef, {
        order_by => 'created_at DESC',
        rows     => 10,
    });

    $c->stash->{kml} = $kml;
    $c->forward('Meguro::View::TT');
}

=head2 extract

=cut

sub extract : Local {
    my ($self, $c) = @_;

    my $url = $c->req->param('url');

    $c->stash->{text_of} = $c->model('ExtractTreeText')->extract_url($url);
    $c->stash->{template} = 'extract.tt2';

    $c->forward('Meguro::View::TT');
    $c->fillform();
}

=head2 scrape

=cut

sub scrape : Local {
    my ($self, $c) = @_;

    # assemble params for scraper
    my $scraper_args;
    my $params = $c->req->params();
    my @path_keys = grep { /path\.\d+/ } keys %$params;

    foreach my $path_key (@path_keys) {
        my ($id) = ($path_key =~ /path\.(\d+)/);
        my $categ = $c->req->param("categ.$id");
        $scraper_args->{$categ} = $c->req->param($path_key);
    }
    $c->log->debug('scraper_args: '.Dump($scraper_args));

    # validate(address and name are both necessary field)
    if (!exists($scraper_args->{address})) {
        $c->set_invalid_form(address => 'NOT_BLANK');
    }
    # 住所と名前のHTML構造が全く同じで判別できない場合があるので必須としない
    #if (!exists($scraper_args->{name})) {
    #    $c->set_invalid_form(name => 'NOT_BLANK');
    #}

    if ($c->form->has_error) {
        $c->detach('extract'); # never come back here!
    }

    my $scraper = $c->model('Scraper')->mk_scraper($scraper_args);

    # scrape
    my @items;
    my @urls = $c->req->param('url');

    foreach my $url (@urls) {
        my @sub_items;

        my $result = $scraper->scrape(URI->new($url));
        $c->log->debug('scraping result: '.Dump($result));

        my ($address_infos, $names, $comments) = @$result{qw(address name comment)};
        $names ||= [];
        $comments ||= [];

        # 経度緯度が取得できない住所情報は取り除く
        INFO:
        foreach my $address (@$address_infos) {
            next INFO unless $address;
            $c->log->debug($address);
            my $extracted = $c->model('AddressExtract')->extract_address($address);
            if ($extracted) {
                $c->log->debug("extracted: $extracted");
                my ($lat, $lng) = $c->model('Geocoder')->get_lat_lng($extracted);
                # 経度緯度が取れないこともある
                # (e.g.東京都 西多摩郡日の出町 大字平井字三吉野桜木557(TSUTAYAイオンモール日の出)
                #if ($lat and $lng) {
                    push @sub_items, {
                        address => $address,
                        extracted => $extracted,
                        lat     => $lat || 0,
                        lng     => $lng || 0,
                    };
                #}
            }
        }

        # 住所と名前の対応関係を結び付けているものは順番だけなので、
        # 住所抽出、経度緯度変換の結果、順番が狂うことがある

        if (@$names && @sub_items != @$names) {
            $c->log->debug(sprintf('items(%d): %s', scalar(@sub_items), Dump(\@sub_items)));
            $c->log->debug(sprintf('names(%d): %s', scalar(@$names), Dump($names)));
            $c->set_invalid_form(item => 'NOT_MATCH');
            $c->detach('extract');
        }

        for (my $i = 0; $i < @sub_items; $i++) {
            $sub_items[$i]->{url} = $url;
            $sub_items[$i]->{name} = $names->[$i] || $sub_items[$i]->{extracted};
            $sub_items[$i]->{comment} = $comments->[$i] || '';
        }

        push @items, @sub_items;
    }

    $c->stash->{items} = \@items;

    # output KML
    my $kml_data = $c->view('KML')->render($c, 'kml.tt2');
    my $kml_file = sprintf('%s.kml', md5_hex((0+\$kml_data).time));

    if (open my $fh, '>', $c->path_to(qw/root static kml/, $kml_file)) {
        print $fh $kml_data;
        close $fh;
    }
    else {
        Carp::croak "Cannot open $kml_file: $!";
    }

    $c->stash->{kml_url} = $c->uri_for("/static/kml/$kml_file");

    $c->forward('Meguro::View::TT');
}

=head2 scrape_async

=cut

sub scrape_async : Local {
    my ($self, $c) = @_;

    # assemble params for scraper
    my $scraper_args;
    my $params = $c->req->params();
    my @path_keys = grep { /path\.\d+/ } keys %$params;

    foreach my $path_key (@path_keys) {
        my ($id) = ($path_key =~ /path\.(\d+)/);
        my $categ = $c->req->param("categ.$id");
        $scraper_args->{$categ} = $c->req->param($path_key);
    }
    $c->log->debug('scraper_args: '.Dump($scraper_args));

    # validate(address and name are both necessary field)
    if (!exists($scraper_args->{address})) {
        $c->set_invalid_form(address => 'NOT_BLANK');
    }
    # 住所と名前のHTML構造が全く同じで判別できない場合があるので必須としない
    #if (!exists($scraper_args->{name})) {
    #    $c->set_invalid_form(name => 'NOT_BLANK');
    #}

    if ($c->form->has_error) {
        $c->detach('extract'); # never come back here!
    }

    my @urls = $c->req->param('url');

    my $handle = $c->model('TheSchwartz')->insert('TheSchwartz::Worker::KMLMaker', {
        scraper_args => $scraper_args,
        urls         => \@urls,
    });

    $c->stash->{handle} = $handle;

    $c->res->redirect($c->uri_for('result', {jobstr => $handle->as_string}));
}

=head2 result

=cut

sub result : Local {
    my ($self, $c) = @_;

    $c->stash->{jobstr} = $c->req->param('jobstr');
    $c->stash->{template} = 'result.tt2';

    $c->forward('Meguro::View::TT');
}

=head2 status

=cut

sub status : Local {
    my ($self, $c) = @_;

    my $jobstr = $c->req->param('jobstr');

    my $job = $c->model('TheSchwartz')->lookup_job($jobstr);
    if ($job) {
        $c->stash->{job_completed} = 0;
    }
    else {
        $c->stash->{job_completed} = 1;
        my ($jobid) = ($jobstr =~ /^.+-(\d+)$/);
        my $job_man = $c->model('DBIC::JobMan')->find($jobid);
        if ($job_man) {
            $c->stash->{kml_file} = sprintf('%s.kml', $job_man->uniqueid);
        }
    }

    $c->forward('Meguro::View::JSON');
    $c->res->header('Cache-Control' => 'no-cache');
}

=head2 save

=cut

sub save : Local {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        $c->form(
            title => ['NOT_BLANK', ['LENGTH', 0, 64]],
            f     => ['NOT_BLANK'],
        );

        unless ($c->form->has_error) {
            my $kml_file = $c->path_to(qw/root static kml/, $c->req->param('f'));
            if (-s $kml_file) {
                open my $fh, '<', $kml_file or die "Cannot open $kml_file: $!";
                my $kml_data = do { local $/; <$fh> };
                close $fh;
                $c->model('DBIC::Kml')->create({
                    title => $c->req->param('title'),
                    kml   => $kml_data,
                    created_at => DateTime->now(time_zone => 'Asia/Tokyo')->strftime('%Y-%m-%d %H:%M:%S'),
                });
                $c->res->redirect($c->uri_for('/'));
                $c->detach();
            }
            else {
                $c->set_invalid_form(f => 'NOT_EXIST');
            }
        }
    }

    $c->stash({
        template => 'save.tt2',
        f        => $c->req->param('f'),
    });

    $c->forward('Meguro::View::TT');
}

=head2 readme

=cut

sub readme : Local {
    my ($self, $c) = @_;

    $c->stash->{template} = 'readme.tt2';
    $c->forward('Meguro::View::TT');
}

=head2 kml

=cut

sub kml : Local {
    my ($self, $c) = @_;

    my $id = $c->req->param('id');
    my $kml = $c->model('DBIC::Kml')->find($id);

    $c->res->header(
        'Content-Type' => 'application/vnd.google-earth.kml+xml'
    );
    $c->res->body($kml->kml);
}

=head2 end

=cut

sub end : Private {
    my ($self, $c) = @_;
}

=head1 AUTHOR

ono takatoshi

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
