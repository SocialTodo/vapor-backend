#!/bin/bash

crypto_file="{\"hash\": {\"method\": \"sha256\",\"encoding\": \"hex\",\"key\": \""
crypto_file+=${HASH_KEY?"HASH_KEY needs to be set!"}
crypto_file+="\"},\"cipher\": {\"method\": \"aes256\",\"encoding\": \"base64\",\"key\": \""
crypto_file+=${CIPHER_KEY?"CIPHER_KEY needs to be set!"}
crypto_file+="\"}}"

echo $crypto_file > ./Config/crypto.json