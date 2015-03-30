#!/usr/bin/perl -w

# This script is licensed CC0 by Andrew Harvey <andrew.harvey4@gmail.com>
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

use warnings;
use strict;

use HTML::TableExtract;

my $te = HTML::TableExtract->new( );

my $html = join("", <STDIN>);

$te->parse($html);

my $header_first_seen = undef;

# Examine all matching tables
foreach my $ts ($te->tables) {
    #print "Table (", join(',', $ts->coords), "):\n";
    
    my @rows = @{$ts->rows};
    my $header = shift @rows;

    if (@$header[0] eq "Agency") {
        # table with CN list as opposed to some other table within the HTML
        if (!defined $header_first_seen) {
            # save the header so we can later check if we see a different one
            $header_first_seen = $header;

            # push header back on so it is printed in the output
            unshift @rows, $header;
        }else{
            # we've already seen a header before, check if this one different
            if (@$header ~~ @$header_first_seen) {
                # headers are the same, all good
            }else{
                # this header is different, we can't merge the files
                print STDERR "First Seen Header:  " . join(',', @$header_first_seen) . "\n";
                print STDERR "Header encountered: " . join(',', @$header) . "\n";
                die "Found a header which didn't match the first seen header\n";
            }
        }

        foreach my $row (@rows) {
            if (@$row[0] ne "There are no results that match your selection.") {
                print join(',', map { s/\xA0/ /gr } map { s/^="/"/gr } map { (defined $_) ? $_ : "" } @$row), "\n";
            }
        }
    }
}
