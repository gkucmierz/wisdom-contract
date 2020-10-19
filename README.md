### wisdom-contract

### setup env

```bash
npm i
touch .env
```

Fill `.env` file

```
PRIVKEY = …
CONTRACT_ADDR = …

INFURA_APIKEY = …

NETWORK_NAME = kovan

BATCH_SIZE = 200
GAS_PRICE = 1e9
GAS_LIMIT = 1e7

STARTING_NONCE =
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
