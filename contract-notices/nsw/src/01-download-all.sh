#!/bin/sh

# This script is licensed CC0 by Andrew Harvey <andrew.harvey4@gmail.com>
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

mkdir -p exports

for year in `seq 2004 2015`; do
    for month in Jan Feb Mar May Jun Jul Aug Sep Oct Nov Dec; do
        echo $year $month
        if [ -n $prev_year ] ; then
            url="https://tenders.nsw.gov.au/?event=public.reports.CN.Published.download&VALUESTART=&report=CNPublishedReport&DATETYPE=Publish%20Date&downloadEvent=public.reports.CN.Published.download&DATEEND=01-$month-$year&CONTRACTVALUETYPE=1EA4EBED-ABB2-4A7F-0AC90B0DC4410801,1EA78EEB-C399-6C48-336FCFD2C8F78F0E,1EA7E836-A9AC-6168-FDC87AD93B787125,1EB37386-AA04-9E57-1406EBBF6402C760,BE1DB05B-F6FB-2B6B-6A30378CDFE7ADD6,BE1DCFCA-0279-F233-0233E671A271F3EA,BE1DE48A-CFBF-4CC6-ED19C5B044E65531&VALUEEND=&NOCONTRACTVALUETYPE=true&AGENCYSTATUS=-1&AGENCYTYPE=&RFTID=&decorator=XLS&DOWNLOAD=Download%20Spreadsheet&DATESTART=01-$prev_month-$prev_year&CATEGORYSEARCHCODE="
            wget -O "exports/$year-$month.html" "$url"
        fi
        prev_year=$year
        prev_month=$month
    done
done
