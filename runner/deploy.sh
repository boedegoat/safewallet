#!/usr/bin/env bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
usage() {
  echo "Usage: $0 [--network <anvil|sepolia>]"
  exit 1
}

NETWORK="anvil"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --network)
      shift
      [[ $# -gt 0 ]] || usage
      NETWORK="$1"
      ;;
    *)
      usage
      ;;
  esac
  shift
done

if [[ "$NETWORK" != "anvil" && "$NETWORK" != "sepolia" ]]; then
  echo "Error: --network must be 'anvil' or 'sepolia'"
  exit 1
fi

NETWORK_ENV="$ROOT_DIR/.env.$NETWORK"
if [[ ! -f "$NETWORK_ENV" ]]; then
  echo "Error: Environment file '$NETWORK_ENV' not found"
  exit 1
fi

source "$NETWORK_ENV"

forge script TokenDeploy --rpc-url $RPC_URL --private-key $DEPLOYER_PK --broadcast
