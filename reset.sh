# export RPC_URL=http://localhost:8545
export RPC_URL=https://eth-sepolia.g.alchemy.com/v2/xy-cMZFtG0UOM3MT314iu

# export DEPLOYER_PK=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# account 2
export DEPLOYER_PK=0xf8f6a1d4f13923606fa43e0c631747b0fde95576ad1c1f2397aab4b809cc4ede
# account 3
export VICTIM_ADDR=0x2B2C5A226CA30A72ec645817a656E7475b223417

export FREENFT_ADDR=0x19e86F201f2645aFBb6F7b8C0bA2162DbbcF3533
export USDT_ADDR=0x3fBfEfDd669F8a2066E85B03B3821700385D594d

forge script Reset --rpc-url $RPC_URL --private-key $DEPLOYER_PK --broadcast