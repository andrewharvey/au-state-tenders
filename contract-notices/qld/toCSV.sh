#!/bin/bash

for f in AwardedContracts/*.xlsx; do
    b=`basename "$f"`;
    if [ ! -e "AwardedContractsCSV/${b%.xlsx}.csv" ] ; then
        xlsx2csv "$f" "AwardedContractsCSV/${b%.xlsx}.csv";
    fi
done

for f in AwardedContracts/*.xls; do
    if [ ! -e "AwardedContractsCSV/${b%.xls}.csv" ] ; then
        libreoffice --headless --convert-to csv "$f" --outdir "AwardedContractsCSV";
    fi
done


#ls -1 AwardedContracts/*.xls | parallel --no-notice libreoffice --headless --convert-to csv "{}" --outdir "AwardedContractsCSV"
