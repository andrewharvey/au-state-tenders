#!/usr/bin/perl -wT

use strict;
use LWP::Simple;        #to fetch the HTML page
use HTML::TreeBuilder;  #to parse the HTML page
use Date::Format;       #to format datetimes

sub trim {
    (my $s = $_[0]) =~ s/^\s+|\s+$//g;
    return $s;        
}
my $is_there_a_next_page = 'yes';


my $pageNum = 1;

my $header_first_seen = undef;

my $month = time2str("%m", time) - 1;
my $year = time2str("%Y", time);
if ($month == 0) {
    $month = 12;
    $year -= 1;
}
my $fromDate = "01/$month/$year";
my $toDate = time2str("%d/%m/%Y", time);

print STDERR "Getting contracts awarded from $fromDate to $toDate...\n";

my $file_name = $fromDate . "_" . $toDate . ".csv";
$file_name =~ s/\//-/g;
open(my $csv_fh, ">", "$file_name") or die "cannot open > $file_name: $!";

sub getDetailsForContract($) {
    my ($id) = @_;
    my $html = get('https://www.tenders.vic.gov.au/tenders/contract/view.do?id='.$id);

    if ($html eq '') {
        die "No response\n";
    }

    open(my $contract_notice, '>', "cn/$id.html");
    print $contract_notice $html;
    close $contract_notice;

}

while (defined $pageNum) {
    print STDERR "GET page $pageNum\n";
    my $html = get('https://www.tenders.vic.gov.au/tenders/contract/list.do?action=contract-search-submit&awardDateFromString=' . $fromDate . '&pageNum=' . $pageNum);

    if ($html eq '') {
        die "No response\n";
    }

    my $tree = HTML::TreeBuilder->new;
    $tree->parse($html); $tree->eof;
    $tree->elementify();

    my @tables = $tree->look_down('_tag', 'table',
                                 'summary', 'A list of contracts grouped by Agency and orderd by contract code');


    foreach my $table (@tables) {
        my @header = ('id');
        foreach my $thead ($table->look_down('_tag', 'thead')) {
            foreach my $tr ($thead->look_down('_tag', 'tr')) {
                foreach my $th ($tr->look_down('_tag', 'th')) {
                    push @header, trim($th->as_text());
                }
            }
        }
        if (!$header_first_seen) {
            # save the header so we can later check if we see a different one
            $header_first_seen = [ @header ]; # [] ensures we get a copy of the array not just a reference to @header

            # print the header
            print $csv_fh join("\t", @header)."\n";
        }else{
            # we've already seen a header before, check if this one different
            if (@header ~~ @$header_first_seen) {
                # headers are the same, all good
            }else{
                # this header is different, we can't merge the files
                print STDERR "First Seen Header:  " . join(',', @$header_first_seen) . "\n";
                print STDERR "Header encountered: " . join(',', @header) . "\n";
                die "Found a header which didn't match the first seen header\n";
            }
        }
                        
        # source doesn't have a tbody
        foreach my $tr ($table->look_down('_tag', 'tr')) {
            my @row = ();
            my $link_id = undef;
            foreach my $td ($tr->look_down('_tag', 'td')) {
                push @row, trim($td->as_text());

                # get the ID from the href
                foreach my $a ($td->look_down('_tag', 'a')) {
                    my $href = $a->attr('href');
                    if ($href =~ /id=([^&]*)&/) {
                        my $id = $1;
                        if (!defined $link_id) {
                            $link_id = $id;
                        }
                    }
                }
            }
            if (scalar @row > 0) {
                unshift @row, ($link_id);
                push @row, getDetailsForContract($link_id);
                print $csv_fh join("\t", @row)."\n";
            }
        }

    }

    my @paging = $tree->look_down('_tag', 'span',
                                  'class', 'paging');

    my $current_page_number = undef;
    my $is_there_a_next_page = undef;
    foreach my $page (@paging) {
        my @current_page = $page->look_down('_tag', 'strong');
        foreach my $cp (@current_page) {
            $current_page_number = $cp->as_text();
            $current_page_number =~ s/,$//;
        }

        # look for a Next to determine if there is another page
        if ($page->as_text() eq "Next") {
            $is_there_a_next_page = 'yes';
        }
    }
    if ($current_page_number != $pageNum) {
        die "Page number in query ($pageNum), doesn't match that reported my the page contents ($current_page_number)\n";
    }
    if (defined $is_there_a_next_page) {
        $pageNum += 1;
    }else{
        $pageNum = undef;
    }
}

close $csv_fh;
