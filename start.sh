export RPC_URL=http://localhost:8545

export DEPLOYER_PK=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export VICTIM_PK=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d

if [[ $# -lt 2 || "$1" != "--spoof" ]]; then
  echo "Usage: $0 --spoof <true|false>"
  exit 1
fi

SPOOF="$2"
if [[ "$SPOOF" != "true" && "$SPOOF" != "false" ]]; then
  echo "Error: --spoof must be 'true' or 'false'"
  exit 1
fi

if [ "$SPOOF" = "true" ]; then
  export SPOOF=true
else
  export SPOOF=false
fi

forge script SafeTransaction --rpc-url $RPC_URL --broadcast