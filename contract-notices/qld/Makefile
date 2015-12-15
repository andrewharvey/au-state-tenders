get:
	wget -O allItems.html http://qcd.hpw.qld.gov.au/Awarded%20Contracts/Forms/AllItems.aspx
	grep -o 'href="/Awarded Contracts/[^"]*"' allItems.html | sed 's/^href="/http:\/\/qcd.hpw.qld.gov.au/' | sed 's/"$//' | wget --directory-prefix="AwardedContracts" --input-file=- --no-clobber

toCSV:
	./toCSV.sh
