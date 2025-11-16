#!/usr/bin/env bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
usage() {
  echo "Usage: $0 <token|nft|eth> --spoof <true|false> [--network <anvil|sepolia>] [--post-checked <true|false>]"
  exit 1
}

NETWORK="anvil"
SPOOF=""
POST_CHECKED=""
SCRIPT_KIND=""
SCRIPT_NAME=""

[[ $# -gt 0 ]] || usage
SCRIPT_KIND="$1"
shift

case "$SCRIPT_KIND" in
  token)
    SCRIPT_NAME="TokenPhising"
    ;;
  nft)
    SCRIPT_NAME="NFTPhising"
    ;;
  eth)
    SCRIPT_NAME="ETHPhising"
    ;;
  *)
    usage
    ;;
esac

while [[ $# -gt 0 ]]; do
  case "$1" in
    --spoof)
      shift
      [[ $# -gt 0 ]] || usage
      SPOOF="$1"
      ;;
    --network)
      shift
      [[ $# -gt 0 ]] || usage
      NETWORK="$1"
      ;;
    --post-checked)
      shift
      [[ $# -gt 0 ]] || usage
      POST_CHECKED="$1"
      ;;
    *)
      usage
      ;;
  esac
  shift
done

[[ -n "$SPOOF" ]] || usage

if [[ "$SPOOF" != "true" && "$SPOOF" != "false" ]]; then
  echo "Error: --spoof must be 'true' or 'false'"
  exit 1
fi

if [[ "$NETWORK" != "anvil" && "$NETWORK" != "sepolia" ]]; then
  echo "Error: --network must be 'anvil' or 'sepolia'"
  exit 1
fi

if [[ "$POST_CHECKED" != "true" && "$POST_CHECKED" != "false" ]]; then
  echo "Error: --post-checked must be 'true' or 'false'"
  exit 1
fi

NETWORK_ENV="$ROOT_DIR/.env.$NETWORK"
if [[ ! -f "$NETWORK_ENV" ]]; then
  echo "Error: Environment file '$NETWORK_ENV' not found"
  exit 1
fi

source "$NETWORK_ENV"

if [ "$SPOOF" = "true" ]; then
  export SPOOF=true
else
  export SPOOF=false
fi

if [ "$POST_CHECKED" = "true" ]; then
  export POST_CHECKED=true
else
  export POST_CHECKED=false
fi

forge script ResetDelegation --rpc-url "$RPC_URL" --broadcast --skip-simulation
forge script "$SCRIPT_NAME" --rpc-url "$RPC_URL" --broadcast --via-ir
