use strict;
use warnings;

use Test::More;
use lib qw(t/lib);
use DBICTest;

my $schema = DBICTest->init_schema();

plan tests => 5;

my $bookmark = $schema->resultset("Bookmark")->find(1);
my $link = $bookmark->link;

my $new_link = $schema->resultset("Link")->create({
    url     => "http://bugsarereal.com",
    title   => "bugsarereal.com"
});

$bookmark->set_column( 'link', $new_link->id );
is $bookmark->link->id, $new_link->id;

$bookmark->update;
is $bookmark->link->id, $new_link->id;
is $bookmark->link->id, $bookmark->get_from_storage->link->id;

{ # what happen on a column which name's diferent from the relation name?
    $schema->populate('Lyrics', [
        [ qw/lyric_id track_id/ ],
        [ 1, 4 ],
        [ 2, 5 ],
        [ 3, 6 ],
    ]);

    my $lyric = $schema->resultset("Lyrics")->find(1);
    my $track = $lyric->track;
    my $track_id = $track->trackid;

    $lyric->track_id(5);
    is $lyric->track->trackid, 5;

    $lyric->update;
    is $lyric->track->trackid, 5;
}

