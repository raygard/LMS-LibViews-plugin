package Plugins::LibViews::Plugin;

# Modified by Ray Gardner 2020-01-07
# Logitech Media Server Copyright 2001-2014 Logitech.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License,
# version 2.

use strict;

use base qw(Slim::Plugin::Base);

use Slim::Menu::BrowseLibrary;
# use Slim::Music::Import;
# use Slim::Utils::Log;

sub initPlugin {
	my $class = shift;

	# Define some virtual libraries.
	# - id:        the library's ID. Use something specific to your plugin to prevent dupes.
	# - name:      the user facing name, shown in menus and settings
	# - sql:       a SQL statement which creates the records in library_track
	# - scannerCB: a sub ref to some code creating the records in library_track. Use scannerCB
	#              if your library logic is a bit more complex than a simple SQL statement.
	foreach ( {
		id => 'DebsFavTracks',
		name => 'Deb\'s Favs',
		# %s is being replaced with the library's ID
		sql => qq{
			INSERT OR IGNORE INTO library_track (library, track)
				SELECT '%s', tracks.id 
				FROM tracks 
				WHERE tracks.url LIKE '%%DebFavs%%'
		}
	},{
		id => 'RaysFavTracks',
		name => 'Ray\'s Favs',
		# %s is being replaced with the library's ID
		sql => qq{
			INSERT OR IGNORE INTO library_track (library, track)
				SELECT '%s', tracks.id 
				FROM tracks 
				WHERE tracks.url LIKE '%%RayFavs%%'
		}
	} ) {
		Slim::Music::VirtualLibraries->registerLibrary($_);
	}
	
	my @menus = ( {
		name => 'PLUGIN_LIB_VIEWS_DEB_ARTISTS',
		icon => 'html/images/artists.png',
		feed => \&Slim::Menu::BrowseLibrary::_artists,
		id   => 'DebsFavTracksByArtist',
		weight => 15,
		virtualID => 'DebsFavTracks',

	},{
		name => 'PLUGIN_LIB_VIEWS_DEB_ALBUMS',
		icon => 'html/images/albums.png',
		feed => \&Slim::Menu::BrowseLibrary::_albums,
		id   => 'DebsFavTracksByAlbum',
		weight => 25,
		virtualID => 'DebsFavTracks',
	},{
		name => 'PLUGIN_LIB_VIEWS_RAY_ARTISTS',
		icon => 'html/images/artists.png',
		feed => \&Slim::Menu::BrowseLibrary::_artists,
		id   => 'RaysFavTracksByArtist',
		weight => 15,
		virtualID => 'RaysFavTracks',
	},{
		name => 'PLUGIN_LIB_VIEWS_RAY_ALBUMS',
		icon => 'html/images/albums.png',
		feed => \&Slim::Menu::BrowseLibrary::_albums,
		id   => 'RaysFavTracksByAlbum',
		virtualID => 'RaysFavTracks',
		weight => 25,
	} );
	
	# this demonstrates how to make use of libraries without switching 
	# the full browsing experience to one particular library
	# create some custom menu items based on one library
	foreach (@menus) {
		Slim::Menu::BrowseLibrary->registerNode({
			type         => 'link',
			name         => $_->{name},
			# params       => { library_id => Slim::Music::VirtualLibraries->getRealId('DebsFavTracks') },
			params       => { library_id => Slim::Music::VirtualLibraries->getRealId($_->{virtualID}) },
			feed         => $_->{feed},
			icon         => $_->{icon},
			jiveIcon     => $_->{icon},
			homeMenuText => $_->{name},
			condition    => \&Slim::Menu::BrowseLibrary::isEnabledNode,
			id           => $_->{id},
			weight       => $_->{weight},
			cache        => 1,
		});
	}
	
	$class->SUPER::initPlugin(@_);
}

1;
