A node should support the following APIs:

1. Connect with a requester ID and proof-of-identity
2. Connect with a requester ID and proof-of-authorisation by a previously known node
3. Reserve a keyspace for data from the requester in future
4. Query API to check the available keyspace this node reserve for the requester
5. Async store key-value pair, overwrite if present
6. Async store key-value pair, preserve original if present
7. Read latest value for a key
8. Read possibly stale value for a key
9. Archive data by the requester
10. Query what is the requester's confidence score in the current node
