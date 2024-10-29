The most granular level of data for which access policies can be defined is a block.

Currently, blocks are being appended linearly in a CSV file. To start with, we can define nobody to have delete/modify access to any file, which is in the true spirit of any blockchain.

All documents should have a signatories column. The init block signatory should be considered the owner of the entire document. The ownership of any block should be the union of the set of owner(s) of the document and the set of signatories of that block. If needed, there can be blocks in the document which add or remove an owner to a set of blocks or the entire document on the basis of a condition.
