# HarvestVault Protocol 🌾

An advanced yield farming and staking protocol built on Stacks blockchain using Clarity, featuring time-weighted rewards, multi-pool staking, and compound interest mechanisms.

## Overview

HarvestVault Protocol is a sophisticated DeFi yield farming platform that enables users to stake tokens and earn rewards through multiple farming pools. The protocol features advanced time-weighted bonus systems, compound staking capabilities, and comprehensive pool management - making it ideal for liquidity mining, governance token distribution, and long-term incentive programs.

## Features

### 🚜 **Multi-Pool Yield Farming**
- **Dynamic Pool Creation**: Admins can create unlimited staking pools
- **Flexible Token Support**: Each pool can accept different stake tokens
- **Configurable Parameters**: Custom reward rates and minimum stake periods
- **Pool Management**: Individual pool activation/deactivation controls

### ⏰ **Time-Weighted Reward System**
- **Progressive Bonuses**: Longer staking periods earn higher multipliers
  - **Week 1**: 1x baseline rewards
  - **Month 1**: 1.5x reward multiplier
  - **Quarter 1**: 2x reward multiplier
  - **90+ Days**: 3x maximum multiplier
- **Block-Based Accrual**: Continuous reward accumulation
- **Real-Time Calculations**: Dynamic pending reward tracking

### 💰 **Advanced Reward Mechanics**
- **Native HARVEST Token**: Custom reward token with controlled minting
- **Compound Staking**: Auto-reinvest rewards for exponential growth
- **Flexible Claiming**: Users can claim rewards anytime
- **Complete History**: Total reward tracking per user and pool

### 🛡️ **Security & Governance**
- **Emergency Controls**: Protocol-wide pause and emergency withdrawals
- **Access Management**: Owner-only administrative functions
- **Input Validation**: Comprehensive parameter checking and error handling
- **Minimum Stakes**: Configurable minimum stake amounts for spam prevention

### 📊 **Analytics & Tracking**
- **Pool Statistics**: Total participants, rewards distributed, APY tracking
- **User Analytics**: Complete staking history and reward records
- **Real-Time Data**: Live pending reward calculations
- **Performance Metrics**: Pool performance and participation analytics

## Project Structure

```
stacks-harvest-vault/
├── contracts/
│   └── harvest-vault.clar         # Main yield farming smart contract
├── tests/
│   ├── harvest-vault_test.ts      # Core functionality tests
│   ├── pool-management_test.ts    # Pool creation and management tests
│   ├── staking_test.ts            # Staking and unstaking tests
│   ├── rewards_test.ts            # Reward calculation and distribution tests
│   └── security_test.ts           # Emergency controls and security tests
├── scripts/
│   ├── deploy.ts                  # Contract deployment scripts
│   ├── create-pools.ts            # Initial pool setup scripts
│   └── admin-tools.ts             # Administrative utilities
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   │   ├── PoolList.tsx       # Available farming pools
│   │   │   ├── StakingForm.tsx    # Stake/unstake interface
│   │   │   ├── RewardsPanel.tsx   # Rewards tracking and claiming
│   │   │   └── PoolStats.tsx      # Pool analytics dashboard
│   │   ├── hooks/
│   │   │   ├── useStaking.ts      # Staking operations hook
│   │   │   └── useRewards.ts      # Rewards calculation hook
│   │   └── utils/
│   │       └── calculations.ts    # Time bonus calculations
│   └── package.json
├── docs/
│   ├── API.md                     # Function documentation
│   ├── TOKENOMICS.md              # Reward mechanism details
│   ├── GOVERNANCE.md              # Protocol governance guide
│   └── SECURITY.md                # Security considerations
├── settings/
│   ├── Devnet.toml               # Development network config
│   ├── Testnet.toml              # Testnet configuration
│   └── Mainnet.toml              # Mainnet configuration
├── Clarinet.toml                 # Project configuration
├── README.md                     # This file
└── .gitignore                    # Git ignore patterns
```

## Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- [Node.js](https://nodejs.org/) v16+ (for frontend and testing)
- [TypeScript](https://www.typescriptlang.org/) (for tests and scripts)
- [React](https://reactjs.org/) (for frontend interface)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/stacks-harvest-vault.git
   cd stacks-harvest-vault
   ```

2. **Install dependencies**
   ```bash
   # Install Clarinet dependencies
   npm install

   # Install frontend dependencies
   cd frontend && npm install && cd ..
   ```

3. **Check contract syntax**
   ```bash
   clarinet check
   ```

4. **Run test suite**
   ```bash
   clarinet test
   ```

5. **Start frontend development server**
   ```bash
   cd frontend && npm start
   ```

## Smart Contract Functions

### Pool Management

#### Public Functions
- `create-pool(name, stake-token, reward-per-block, min-stake-period)` - Create new farming pool (Owner only)
- `toggle-pool(pool-id)` - Activate/deactivate pool (Owner only)

### Staking Operations

#### Public Functions
- `stake-tokens(pool-id, amount)` - Stake tokens in farming pool
- `unstake-tokens(pool-id)` - Withdraw staked tokens and claim rewards
- `claim-rewards(pool-id)` - Claim accumulated rewards without unstaking
- `compound-rewards(pool-id)` - Auto-reinvest rewards to increase stake

### Read-Only Functions
- `get-pool-info(pool-id)` - Get complete pool information
- `get-user-stake(pool-id, user)` - Get user's stake details
- `calculate-pending-rewards(pool-id, user)` - Calculate unclaimed rewards
- `get-pool-stats(pool-id)` - Get pool statistics and metrics

### Administrative Functions
- `emergency-pause()` - Emergency protocol shutdown (Owner only)

## Usage Examples

### Deploy Contract
```bash
clarinet deploy --devnet
```

### Create a Farming Pool
```clarity
;; Create STX staking pool with 1% daily rewards, 7-day minimum
(contract-call? .harvest-vault create-pool 
    "STX Farming Pool" 
    'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.stx-token
    u100 
    u1008) ;; 7 days in blocks
```

### Stake Tokens
```clarity
;; First: Transfer tokens to contract
;; Then: Record stake in pool #1
(contract-call? .harvest-vault stake-tokens u1 u1000000) ;; Stake 1 token
```

### Claim Rewards
```clarity
;; Claim accumulated rewards from pool #1
(contract-call? .harvest-vault claim-rewards u1)
```

### Compound Rewards
```clarity
;; Auto-reinvest rewards to increase stake
(contract-call? .harvest-vault compound-rewards u1)
```

## Token Economics

### HARVEST Token Specifications
| Property | Value |
|----------|-------|
| **Name** | HarvestToken |
| **Symbol** | HARVEST |
| **Type** | Fungible Token (Native) |
| **Supply** | Unlimited (Controlled Minting) |
| **Distribution** | Yield Farming Rewards Only |

### Reward Calculation Formula
```
Base Reward = (Staked Amount × Pool Reward Rate × Blocks Staked) ÷ 10,000
Time Bonus = Progressive multiplier based on stake duration
Final Reward = Base Reward × Time Bonus ÷ 100
```

### Time Bonus Schedule
| Staking Duration | Multiplier | Bonus |
|------------------|------------|-------|
| 0-7 days | 1.0x | Baseline |
| 8-30 days | 1.5x | +50% |
| 31-90 days | 2.0x | +100% |
| 90+ days | 3.0x | +200% |

## Pool Configuration

### Default Settings
- **Base Reward Rate**: 100 (1% per 144 blocks ≈ 1 day)
- **Minimum Stake**: 1,000,000 (1 token with 6 decimals)
- **Blocks Per Day**: 144 (Stacks average)
- **Maximum Multiplier**: 3.0x

### Pool Parameters
Each pool can be configured with:
- **Custom reward rates** per block
- **Minimum staking periods** for lock-up requirements
- **Different stake tokens** for diversified farming
- **Individual activation** status

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 100 | `err-owner-only` | Function restricted to contract owner |
| 101 | `err-insufficient-balance` | Not enough tokens for operation |
| 102 | `err-pool-not-found` | Pool ID doesn't exist |
| 103 | `err-already-staked` | User already has active stake in pool |
| 104 | `err-not-staked` | User has no stake in specified pool |
| 105 | `err-insufficient-stake` | Stake amount below minimum or lock period not met |
| 106 | `err-pool-paused` | Pool or protocol is currently paused |
| 107 | `err-invalid-amount` | Amount must be greater than zero |

## Security Features

### Multi-Layer Protection
- **Access Control**: Owner-only administrative functions
- **Input Validation**: Comprehensive parameter checking
- **Emergency Pause**: Protocol-wide shutdown capability
- **Emergency Withdrawal**: Bypass lock periods in emergencies

### Economic Security
- **Minimum Stakes**: Prevent spam and gaming attacks
- **Time Locks**: Discourage short-term manipulation
- **Supply Control**: Controlled HARVEST token minting
- **Rate Limiting**: Configurable reward rates prevent inflation

## Testing Strategy

### Test Coverage Areas
- ✅ **Pool Management**: Creation, activation, configuration
- ✅ **Staking Operations**: Stake, unstake, validation
- ✅ **Reward Mechanics**: Calculation, distribution, time bonuses
- ✅ **Security Controls**: Emergency functions, access control
- ✅ **Edge Cases**: Boundary conditions, error scenarios
- ✅ **Integration**: End-to-end user workflows

### Test Execution
```bash
# Run all tests
clarinet test

# Run specific test file
clarinet test --filter staking_test

# Test with coverage
clarinet test --coverage
```

## Frontend Interface

### Key Components
- **Pool Dashboard**: Overview of all available farming pools
- **Staking Interface**: Intuitive stake/unstake forms
- **Rewards Tracker**: Real-time pending rewards display
- **Analytics Panel**: Personal and pool performance metrics
- **Admin Console**: Pool management for contract owners

### Technology Stack
- **React 18**: Modern UI framework
- **TypeScript**: Type-safe development
- **Stacks.js**: Blockchain interaction library
- **Chart.js**: Data visualization
- **Tailwind CSS**: Responsive styling

## Deployment Guide

### Development Network
```bash
clarinet deploy --devnet
```

### Testnet Deployment
```bash
clarinet deploy --testnet
```

### Mainnet Deployment
```bash
clarinet deploy --mainnet
```

### Post-Deployment Setup
1. Create initial farming pools
2. Configure reward rates and parameters
3. Set up frontend configuration
4. Initialize monitoring and analytics

## Use Cases

### DeFi Protocols
- **Liquidity Mining**: Incentivize liquidity provision
- **Governance Distribution**: Reward active community participation
- **Protocol Bootstrapping**: Attract early adopters with high yields

### Token Projects
- **Holder Incentives**: Reward long-term token holding
- **Community Building**: Engage users through farming activities
- **Ecosystem Growth**: Distribute governance tokens fairly

### Enterprise Applications
- **Employee Incentives**: Token-based reward programs
- **Partner Rewards**: Incentivize business partnerships
- **Customer Loyalty**: Reward platform usage and engagement

## Roadmap

### Phase 1: Core Protocol ✅
- [x] Multi-pool staking system
- [x] Time-weighted rewards
- [x] Emergency controls
- [x] Basic frontend interface

### Phase 2: Advanced Features 🚧
- [ ] Liquidity pool integration
- [ ] Cross-chain farming support
- [ ] Advanced analytics dashboard
- [ ] Mobile application

### Phase 3: Ecosystem Expansion 📋
- [ ] Governance token integration
- [ ] DAO treasury management
- [ ] Third-party integrations
- [ ] Institutional features

### Phase 4: Enterprise Grade 📋
- [ ] Audit completion
- [ ] Insurance integration
- [ ] Compliance features
- [ ] Multi-sig support

## Contributing

We welcome contributions from the community! Here's how to get involved:

### Development Process
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/yield-optimization`)
3. Make your changes with tests
4. Commit changes (`git commit -m 'Add yield optimization'`)
5. Push to branch (`git push origin feature/yield-optimization`)
6. Open a Pull Request

### Contribution Guidelines
- All new features must include comprehensive tests
- Security-related changes require thorough review
- Documentation must be updated for API changes
- Follow Clarity and TypeScript best practices

### Areas for Contribution
- **Smart Contract Optimization**: Gas efficiency improvements
- **Frontend Development**: UI/UX enhancements
- **Testing**: Additional test cases and scenarios
- **Documentation**: Guides, tutorials, and examples
- **Security**: Audit findings and vulnerability fixes

## Security & Audits

### Security Considerations
- **Smart Contract Security**: Input validation, access control, emergency stops
- **Economic Security**: Inflation control, reward distribution, tokenomics
- **Operational Security**: Admin key management, upgrade procedures

### Audit Status
- **Internal Review**: ✅ Completed
- **Community Review**: 🚧 In Progress
- **Professional Audit**: 📋 Planned
- **Bug Bounty**: 📋 Planned

### Reporting Issues
- **Security Issues**: Email security@harvestvault.protocol
- **Bug Reports**: Open GitHub issue with detailed reproduction steps
- **Feature Requests**: Use GitHub discussions for community input

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support & Community

### Getting Help
- **Documentation**: Check our comprehensive docs in `/docs`
- **GitHub Issues**: Report bugs and request features
- **Discord**: Join our community for real-time support
- **Twitter**: Follow [@HarvestVault](https://twitter.com/HarvestVault) for updates

### Community Resources
- **Developer Guide**: Complete development setup and contribution guide
- **User Manual**: Step-by-step user interface guide
- **API Reference**: Detailed smart contract function documentation
- **Tutorials**: Video guides and written tutorials

## Acknowledgments

- **Stacks Foundation**: For the Clarity language and blockchain infrastructure
- **DeFi Community**: For inspiration from protocols like Compound, Yearn, and SushiSwap
- **Security Researchers**: For ongoing security review and feedback
- **Open Source Contributors**: For code contributions and community support

---

**Grow your wealth with HarvestVault - Where DeFi meets sustainable yields 🌾💰**