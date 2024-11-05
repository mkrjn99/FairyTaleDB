Intent: we don't want blobs larger than 64KB to be stored in FairyTaleDB.

Algorithm to store a file in FairyTaleDB:

1. Let the original file be F.
2. Check if F is larger than 64KB, if not go to step 8.
3. Split the file into two parts: F1 & F2.
4. Recursively store F1 and F2 in FairyTaleDB.
5. Create a new text file which contains SHA-512 of F1 & F2, calling it F3.
6. Store F3 recursively in FairyTaleDB as well.
7. Write an agent to get the file F3 from the FairyTaleDB and get F from it.
8. Make the FairyTaleDB API call to store F.
