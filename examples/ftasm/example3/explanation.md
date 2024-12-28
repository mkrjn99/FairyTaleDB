First the following command was run:

cp input.txt temp.txt

Then the following command was run 32 times:

sha512sum temp.txt | cut -d' ' -f1 | tail -c 3 >> temp.txt

Finally this command was run:

sha512sum temp.txt | cut -d' ' -f1 >> output.txt
