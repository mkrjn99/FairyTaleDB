The following command was run multiple times:

sha512sum input.txt | cut -d' ' -f1 | tail -c 3 >> input.txt
