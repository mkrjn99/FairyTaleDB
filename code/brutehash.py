# Run python3 brute.py | tail -c 7
import hashlib

def find_nonce(S):
    nonce = 0
    target_prefix = "0" * 6
     
    while True:
        # Concatenate string S with the nonce (as a string)
        input_string = S + str(nonce)
        
        # Compute the SHA-512 hash
        hash_object = hashlib.sha512(input_string.encode())
        hash_hex = hash_object.hexdigest()
        
        # Check if the hash has 6 leading zeros
        if hash_hex.startswith(target_prefix):
            return nonce, hash_hex
        
        # Increment the nonce for the next iteration
        nonce += 1

superdmUsername = input()

S = superdmUsername + "@pdh"
nonce, hash_hex = find_nonce(S)
print(f"Found nonce: {nonce}")
print(f"SHA-512 hash: {hash_hex}")

