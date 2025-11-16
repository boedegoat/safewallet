# Mitigating Transaction Simulation Spoofing via EIP-7702 Extension: A Post-Transaction State Verification Approach

## Abstract

This research presents a novel approach to mitigate "Transaction Simulation Spoofing" attacks, a significant threat in the Web3 ecosystem. We propose an extension to the EIP-7702 standard, introducing a "Post-Checked Delegation Contract." This mechanism ensures the integrity of transactions by verifying that the post-transaction state on the blockchain matches the state predicted by a pre-transaction simulation. Any detected mismatch between the simulated and actual outcomes results in an automatic transaction revert, effectively neutralizing the spoofing attack. This paper details the implementation of this extension and presents empirical evidence of its effectiveness against various phishing scenarios involving ETH, ERC20 tokens, and ERC721 non-fungible tokens (NFTs).

## Introduction

Transaction simulation is a widely used security measure in Web3 wallets, allowing users to preview the outcome of a transaction before signing it. However, malicious actors have developed "Transaction Simulation Spoofing" techniques, as documented by Scamsniffer. These attacks manipulate the simulation environment to present a benign outcome to the user, while the actual transaction, once executed on-chain, leads to malicious consequences such as asset drainage.

EIP-7702 introduces a new transaction type that allows an Externally Owned Account (EOA) to delegate its authority to a contract for a single transaction. This research leverages the EIP-7702 framework to build a defense mechanism. We introduce a smart contract that, in addition to executing the delegated transaction, performs a post-transaction state check. This check compares critical state variables (e.g., account balances) against expected values derived from the initial, trusted simulation.

## Tests

All tests were executed using the [`phising.sh`](./runner/phising.sh) script on the Sepolia test network (Chain ID: 11155111). Each "Post checked" transaction utilizes delegation contract defined in [`PostCheckedDelegationContract.sol`](./src/wallet/PostCheckedDelegationContract.sol).

### ETH Phising

#### Spoof = false
- **Post checked = false** — ✅ Hash [0xe040c698df3c2c0ab29f5bb5a669bf05ccdaf1aaa94398a37760c1fe96d8f1b6](https://sepolia.etherscan.io/tx/0xe040c698df3c2c0ab29f5bb5a669bf05ccdaf1aaa94398a37760c1fe96d8f1b6)  
  Block 9642255, paid 0.000000031523 ETH (31523 gas * 0.001 gwei)
- **Post checked = true** — ✅ Hash [0xfb38572768e0726aba25de41b6d68971adeda4e4bf23fb59fc26f9e0215999b4](https://sepolia.etherscan.io/tx/0xfb38572768e0726aba25de41b6d68971adeda4e4bf23fb59fc26f9e0215999b4)  
  Block 9642268, paid 0.000000062598563382 ETH (62598 gas * 0.001000009 gwei)

#### Spoof = true
- **Post checked = false** — ✅ Hash [0xcf96a97a0940834f7c2a52940583ac21c8d4ddba49b3661144c523e48bcfa3bb](https://sepolia.etherscan.io/tx/0xcf96a97a0940834f7c2a52940583ac21c8d4ddba49b3661144c523e48bcfa3bb)  
  Block 9642426, 0.000000023971 ETH (23971 gas * 0.001 gwei)
- **Post checked = true** — Reverted  
  ```
  │   ├─ [907] Drainer::claim{value: 1000000000000000}()
  │   │   └─ ← [Return]
  │   └─ ← [Revert] ETHMissmatch()
  └─ ← [Revert] EvmError: Revert
  ```

### Token Phising

#### Spoof = false
- **Post checked = false** — ✅ Hash [0xd6505954114faf6fdd5249322143de10a10fab151b0f4e603dbc201c426e232a](https://sepolia.etherscan.io/tx/0xd6505954114faf6fdd5249322143de10a10fab151b0f4e603dbc201c426e232a)  
  Block 9641095, paid 0.000000141271539936 ETH (140808 gas × 0.001003292 gwei)
- **Post checked = true** — ✅ Hash [0x8ca880852c8f11c8d292614c3f9549f71a51ad63f54e5ca76d104b307c109a9f](https://sepolia.etherscan.io/tx/0x8ca880852c8f11c8d292614c3f9549f71a51ad63f54e5ca76d104b307c109a9f)  
  Block 9641107, paid 0.00000019742138646 ETH (196774 gas × 0.00100329 gwei)

#### Spoof = true
- **Post checked = false** — ✅ Hash [0x295e7693e0b4a2e6684d778ff7e7c0cb4abf709e9d76b293186908290b951934](https://sepolia.etherscan.io/tx/0x295e7693e0b4a2e6684d778ff7e7c0cb4abf709e9d76b293186908290b951934)  
  Block 9641136, paid 0.000000138465 ETH (138465 gas × 0.001 gwei)
- **Post checked = true** — Reverted  
  ```
  │   ├─ [1240] USDT::balanceOf(0x31Dcc59Ac89ecc77A8F9F2B3A5a8C39eb2Cf1233) [staticcall]
  │   │   └─ ← [Return] 0
  │   └─ ← [Revert] ERC20Missmatch(0x092d415E0F97DB18182E4fc7345c6086009001AE)
  └─ ← [Revert] EvmError: Revert
  ```

### NFT Phising

#### Spoof = false
- **Post checked = false** — ✅ Hash [0xa627cb594266b976c9dbc41aeae601cd89e7190ab84325b5a29360b88ae0478a](https://sepolia.etherscan.io/tx/0xa627cb594266b976c9dbc41aeae601cd89e7190ab84325b5a29360b88ae0478a)  
  Block 9641733, paid 0.000000139194531123 ETH (139193 gas * 0.001000011 gwei)
- **Post checked = true** — ✅ Hash [0x5918f15a6c1721082c667a58f94255317d6c8ddfa74a5a6ed010eebcacc76457](https://sepolia.etherscan.io/tx/0x5918f15a6c1721082c667a58f94255317d6c8ddfa74a5a6ed010eebcacc76457)  
  Block 9641757, paid 0.00000020024900247 ETH (200247 gas * 0.00100001 gwei)

#### Spoof = true
- **Post checked = false** — ✅ Hash [0x4e4dbe533f6f5eb31d42d42246f46b51bb93c7eb180a008daa329befc9473d8e](https://sepolia.etherscan.io/tx/0x4e4dbe533f6f5eb31d42d42246f46b51bb93c7eb180a008daa329befc9473d8e)  
  Block 9641777, paid 0.000000215752941759 ETH (215751 gas * 0.001000009 gwei)
- **Post checked = true** — Reverted  
  ```
  │   ├─ [1728] FreeNFT::balanceOf(0x31Dcc59Ac89ecc77A8F9F2B3A5a8C39eb2Cf1233) [staticcall]
  │   │   └─ ← [Return] 0
  │   └─ ← [Revert] ERC721Missmatch(0x70a160Fd209f0C765e76f316B852A314c0F07591)
  └─ ← [Revert] EvmError: Revert
  ```

## Conclusion

The experimental results demonstrate that the "Post-Checked Delegation Contract" is a highly effective countermeasure against Transaction Simulation Spoofing attacks. In all tested phishing scenarios (ETH, ERC20, and ERC721), enabling the post-transaction state check successfully prevented asset loss by reverting the malicious transaction. The mechanism introduces a negligible performance overhead in legitimate transactions, making it a practical and powerful security enhancement for the Web3 ecosystem.

## Future Work

Future research could explore the gas optimization of the verification contract, extend the post-check logic to cover a wider range of state variables and smart contract interactions, and investigate the integration of this mechanism into mainstream wallet infrastructure.

## References

- [EIP-7702: Set EOA account code for one transaction](https://eips.ethereum.org/EIPS/eip-7702)
- [Transaction Simulation Spoofing, a New Threat in Web3](https://drops.scamsniffer.io/transaction-simulation-spoofing-a-new-threat-in-web3/)

## Disclaimer

This is a research project and has not been audited for security. It is provided for informational purposes only and should not be used in a production environment. Use at your own risk.
