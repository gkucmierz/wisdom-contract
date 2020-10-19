
require('dotenv').config();

const Contract = require('web3-eth-contract');
const ethWallet = require('ethereumjs-wallet');

const {
  PRIVKEY,
  CONTRACT_ADDR,
  INFURA_APIKEY,
  STARTING_NONCE,
} = process.env;

const NETWORK_NAME = process.env.NETWORK_NAME || 'mainnet';
const BATCH_SIZE = +process.env.BATCH_SIZE;
const GAS_PRICE = +process.env.GAS_PRICE;
const GAS_LIMIT = +process.env.GAS_LIMIT;

const CONTRACT_ABI = require('../abi.json');
const DATA_DIR = [__dirname, '..', 'data'].join('/');
const TOKEN_HOLDERS_FILE = [DATA_DIR, 'token-holders'].join('/');
const TRANSACTIONS_FILE = [DATA_DIR, 'transactions.json'].join('/');

const INFURA_PROVIDER = (NETWORK_NAME === 'kovan' ?
  `wss://kovan.infura.io/ws/v3/${INFURA_APIKEY}` :
  `wss://mainnet.infura.io/ws/v3/${INFURA_APIKEY}`
);

const hexToBuffer = hex => {
  const size = hex.length / 2;
  const res = new Uint8Array(size);
  PRIVKEY.match(/../g).map((s, i) => res[i] = parseInt(s, 16));
  return Buffer.from(res, 'utf8')
};

const privkeyToAddress = priv => {
  return ethWallet.default.fromPrivateKey(hexToBuffer(priv)).getAddressString() + '';
};

const OWNER_ADDR = privkeyToAddress(PRIVKEY);

const getTokenName = async () => {
  Contract.setProvider(INFURA_PROVIDER);
  const contract = new Contract(CONTRACT_ABI, CONTRACT_ADDR, {
    from: privkeyToAddress(PRIVKEY)
  });
  const name = await contract.methods.name().call();
  return name;
};

const getTokenHolders = () => {
  const fs = require('fs');
  return (fs.readFileSync(TOKEN_HOLDERS_FILE)+'')
    .split(/\n+/)
    .filter(line => line)
    .map(line => {
    const [address, balance] = line.split(/\s+/);
    return { address, balance };
  });
};

const generateTxs = async () => {
  console.log(`Generating transactions with gas: ${GAS_PRICE}`);

  const Web3 = require('web3');
  const { Transaction } = require('ethereumjs-tx');
  const web3 = new Web3(INFURA_PROVIDER);

  const nonce = (STARTING_NONCE ?
    +STARTING_NONCE :
    await web3.eth.getTransactionCount(OWNER_ADDR)
  );
  console.log(`Starting nonce: ${nonce}`);
  const contract = new web3.eth.Contract(CONTRACT_ABI, CONTRACT_ADDR);

  const transactions = [];
  const tokenHolders = getTokenHolders();

  let cnt = 0;
  while (1) {
    const batch = tokenHolders.splice(0, BATCH_SIZE) || [];
    if (batch.length === 0) break;

    const issue = contract.methods.issue(
      batch.map(({ address }) => address),
      batch.map(({ balance }) => balance),
    );

    const txData = {
      nonce: Web3.utils.toHex(nonce + cnt),
      to: CONTRACT_ADDR,
      data: issue.encodeABI(),
      value: Web3.utils.toHex(0),
      gas: GAS_LIMIT,
      gasPrice: GAS_PRICE,
    };

    const tx = new Transaction(txData, { chain: NETWORK_NAME });
    tx.sign(Buffer.from(PRIVKEY, 'hex'));
    transactions.push('0x' + tx.serialize().toString('hex'));
    ++cnt;
  }

  return { transactions, startingNonce: nonce };
};

const saveTransactions = transactions => {
  const fs = require('fs');
  if (fs.existsSync(TRANSACTIONS_FILE)) {
    console.error(`File ${TRANSACTIONS_FILE} already exists!`);
    return;
  }
  fs.writeFileSync(TRANSACTIONS_FILE, JSON.stringify(transactions, null, '  '));
};

const pushTransactions = async (finishCb) => {
  const Web3 = require('web3');
  const web3 = new Web3(INFURA_PROVIDER);
  const { transactions, startingNonce } = require(TRANSACTIONS_FILE);

  console.log(`Pushing ${transactions.length} transactions to network`);

  const addrNonce = await web3.eth.getTransactionCount(OWNER_ADDR);
  let pushed = false;
  for (let i = addrNonce - startingNonce; i < transactions.length; ++i) {
    const tx = transactions[i];
    web3.eth.sendSignedTransaction(tx).catch(error => {
      // console.error(error);
    });
    pushed = true;
  }

  console.log(`Pushed ${transactions.length} transactions to network!`);

  if (!pushed) {
    finishCb();
  }
};

const init = async () => {
  console.log(await getTokenName());

  const { transactions, startingNonce } = await generateTxs();
  saveTransactions({ transactions, startingNonce });

  pushTransactions(() => console.log('done'));
};

init();
