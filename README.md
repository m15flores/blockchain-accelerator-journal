# Blockchain Accelerator — Journal

Exercises and projects from the Blockchain Accelerator program, organized by module.

## About
Backend Software Engineer (Java/Spring Boot) building a bridge profile between backend engineering and blockchain, aimed at backend blockchain dev roles in on-chain payments / stablecoins / digital assets infrastructure.

This repo is the full learning journal. Projects that grew into standalone portfolio pieces (with their own backend, infra, or extended security work) live in separate repos, linked below.

## Structure
```
module-N-short-name/
  exercise-kebab-case/
    contracts/
    test/
    README.md
```

## Extended projects

- **Cryptobank → ERC-20 migration**: [cryptobank-erc20](https://github.com/m15flores/cryptobank-erc20). Original exercise migrated from native ETH to a custom ERC-20 token, with `Ownable`, `SafeERC20`, and a full Foundry test suite.
- **Staking App → Proportional rewards**: [proportional-staking](https://github.com/m15flores/proportional-staking). MasterChef-style accumulator pattern, multi-user staking with continuous proportional reward accrual in a separate reward token, `SafeERC20`, full Foundry test suite.

- **NFT Collection → City Journey NFT**: [city-journey-nft](https://github.com/m15flores/city-journey-nft). A personal, soulbound NFT collection with on-chain city data, deployed live on Arbitrum One. Includes a Go minting script using go-ethereum.
