#!/bin/sh

mkdir -p export
curl --output "export/#1.html" 'http://www.procurement.act.gov.au/contracts/contracts_register/contracts_register_functionality/contracts_search?mode=results&current_result_page=[1-313]&results_per_page=20'
