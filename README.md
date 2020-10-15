### wisdom-contract

### setup env

```bash
npm i
touch .env
```

`.env` file

```
PRIVKEY=7d6d…
CONTRACT_ADDR=0xa3efba0cf94eb8998c23d37547d6e5b5062508e1

INFURA_PROVIDER=wss://mainnet.infura.io/v3/a9…
INFURA_KOVAN_PROVIDER=wss://kovan.infura.io/ws/v3/a9…
```

### cost comparision

##### with `calldata`

| function type | cost type        | gas   |
| :-----------: | :--------------: | ----: |
| external      | transaction cost | 43452 |
| external      |   execution cost | 21476 |
| public        | transaction cost | 29279 |
| public        |   execution cost | 7303  |

##### with `memory`

| function type | cost type        | gas   |
| :-----------: | :--------------: | ----: |
| external      | transaction cost | 29451 |
| external      |   execution cost | 7475  |
| public        | transaction cost | 29473 |
| public        |   execution cost | 7497  |
