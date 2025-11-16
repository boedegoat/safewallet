Network: Sepolia (chainid: 11155111)

## Token Phising

### Spoof = false
- **Post checked = false** — ✅ Hash [0xd6505954114faf6fdd5249322143de10a10fab151b0f4e603dbc201c426e232a](https://sepolia.etherscan.io/tx/0xd6505954114faf6fdd5249322143de10a10fab151b0f4e603dbc201c426e232a)  
  Block 9641095, paid 0.000000141271539936 ETH (140808 gas × 0.001003292 gwei)
- **Post checked = true** — ✅ Hash [0x8ca880852c8f11c8d292614c3f9549f71a51ad63f54e5ca76d104b307c109a9f](https://sepolia.etherscan.io/tx/0x8ca880852c8f11c8d292614c3f9549f71a51ad63f54e5ca76d104b307c109a9f)  
  Block 9641107, paid 0.00000019742138646 ETH (196774 gas × 0.00100329 gwei)

### Spoof = true
- **Post checked = false** — ✅ Hash [0x295e7693e0b4a2e6684d778ff7e7c0cb4abf709e9d76b293186908290b951934](https://sepolia.etherscan.io/tx/0x295e7693e0b4a2e6684d778ff7e7c0cb4abf709e9d76b293186908290b951934)  
  Block 9641136, paid 0.000000138465 ETH (138465 gas × 0.001 gwei)
- **Post checked = true** — Reverted  
  ```
  │   ├─ [1240] USDT::balanceOf(0x31Dcc59Ac89ecc77A8F9F2B3A5a8C39eb2Cf1233) [staticcall]
  │   │   └─ ← [Return] 0
  │   └─ ← [Revert] ERC20Missmatch(0x092d415E0F97DB18182E4fc7345c6086009001AE)
  └─ ← [Revert] EvmError: Revert
  ```

## NFT Phising

### Spoof = false
- **Post checked = false** — ✅ Hash [0xa627cb594266b976c9dbc41aeae601cd89e7190ab84325b5a29360b88ae0478a](https://sepolia.etherscan.io/tx/0xa627cb594266b976c9dbc41aeae601cd89e7190ab84325b5a29360b88ae0478a)  
  Block 9641733, paid 0.000000139194531123 ETH (139193 gas * 0.001000011 gwei)
- **Post checked = true** — ✅ Hash [0x5918f15a6c1721082c667a58f94255317d6c8ddfa74a5a6ed010eebcacc76457](https://sepolia.etherscan.io/tx/0x5918f15a6c1721082c667a58f94255317d6c8ddfa74a5a6ed010eebcacc76457)  
  Block 9641757, paid 0.00000020024900247 ETH (200247 gas * 0.00100001 gwei)

### Spoof = true
- **Post checked = false** — ✅ Hash [0x4e4dbe533f6f5eb31d42d42246f46b51bb93c7eb180a008daa329befc9473d8e](https://sepolia.etherscan.io/tx/0x4e4dbe533f6f5eb31d42d42246f46b51bb93c7eb180a008daa329befc9473d8e)  
  Block 9641777, paid 0.000000215752941759 ETH (215751 gas * 0.001000009 gwei)
- **Post checked = true** — Reverted  
  ```
  │   ├─ [1728] FreeNFT::balanceOf(0x31Dcc59Ac89ecc77A8F9F2B3A5a8C39eb2Cf1233) [staticcall]
  │   │   └─ ← [Return] 0
  │   └─ ← [Revert] ERC721Missmatch(0x70a160Fd209f0C765e76f316B852A314c0F07591)
  └─ ← [Revert] EvmError: Revert
  ```
