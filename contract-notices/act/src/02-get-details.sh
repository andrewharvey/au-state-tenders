#!/bin/sh

mkdir -p export/individual
cat export/listings/*.html | grep -o '\.\.\/contracts\/contracts[^"]*' | sed 's/^/http:\/\/www.procurement.act.gov.au\/contracts\/contracts_register\/contracts_register_functionality\//' | wget --directory-prefix export/individual -i -
