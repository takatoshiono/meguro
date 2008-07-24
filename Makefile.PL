use inc::Module::Install;

name 'Meguro';
all_from 'lib/Meguro.pm';

requires 'HTML::TreeBuilder';
requires 'Class::Accessor::Fast';
requires 'Geo::Coder::Google';
requires 'TheSchwartz';
requires 'Geography::AddressExtract::Japan'; # NOT IN CPAN!!
requires 'Web::Scraper';
requires 'DBIx::Class';
requires 'Template';

requires 'Catalyst::Runtime' => '5.7011';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'YAML'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
requires 'Catalyst::View::TT::ForceUTF8';
requires 'Catalyst::View::JSON';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Catalyst::Plugin::FormValidator::Simple';
requires 'Catalyst::Plugin::FillInForm';
requires 'Catalyst::Plugin::Unicode';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
