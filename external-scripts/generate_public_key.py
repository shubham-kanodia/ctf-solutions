from eth_keys import keys
from eth_utils import decode_hex

priv_key_bytes = decode_hex('YOUR_PRIVATE_KEY_HERE')
priv_key = keys.PrivateKey(priv_key_bytes)
pub_key = priv_key.public_key

print(pub_key.to_hex())