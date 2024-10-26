There are 4 kinds of actions we want to support:

1. Proof of authority
2. Proof of storage
3. Proof of serial computation
4. Proof of parallel computation

Authority is the most important. If an agent does not have the authority to act on behalf of another agent, that action should never be allowed.

The other 3 are purely mathematical:
If a chunk of a certain size is being asked to store, the node has to bid for it.
If a computation type is being requested, the node has to estimate whether it will be able to finish it in due time or not, otherwise it loses the staked coins.

One's bet can often define one's confidence, but there can be mal-actors who want to disrupt the system, so we might wanna have reputation scores for nodes as well.

The strategy for each node can depend on the status of the node, and we leave that to the node completely what they want to over-index on, at any point, given their bandwidth in that area.
