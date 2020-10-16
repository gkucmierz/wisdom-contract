
require('dotenv').config();

const Contract = require('web3-eth-contract');
const ethWallet = require('ethereumjs-wallet');

const {
  PRIVKEY,
  CONTRACT_ADDR,
  INFURA_APIKEY,
} = process.env;

const NETWORK_NAME = process.env.NETWORK_NAME || 'mainnet';
const BATCH_SIZE = +process.env.BATCH_SIZE;
const GAS_PRICE = +process.env.GAS_PRICE;
const GAS_LIMIT = +process.env.GAS_LIMIT;

const CONTRACT_ABI = require('../abi.json');
const TOKEN_HOLDERS_FILE = [__dirname, '../data/token-holders'].join('/');

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
  const OWNER_ADDR = privkeyToAddress(PRIVKEY);

  console.log(`Generating transactions with gas: ${GAS_PRICE}`);

  const Web3 = require('web3');
  const { Transaction } = require('ethereumjs-tx');
  const web3 = new Web3(INFURA_PROVIDER);

  const nonce = await web3.eth.getTransactionCount(OWNER_ADDR);
  const contract = new web3.eth.Contract(CONTRACT_ABI, CONTRACT_ADDR);

  const rawTxs = [];
  const tokenHolders = getTokenHolders();

  while (1) {
    const batch = tokenHolders.splice(0, BATCH_SIZE) || [];
    if (batch.length === 0) break;

    const issue = contract.methods.issue(
      batch.map(({ address }) => address),
      batch.map(({ balance }) => balance),
    );

    const txData = {
      nonce: Web3.utils.toHex(nonce),
      to: CONTRACT_ADDR,
      data: issue.encodeABI(),
      value: Web3.utils.toHex(0),
      gas: GAS_LIMIT,
      gasPrice: GAS_PRICE,
    };

    const tx = new Transaction(txData, { chain: NETWORK_NAME });
    tx.sign(Buffer.from(PRIVKEY, 'hex'));
    rawTxs.push('0x' + tx.serialize().toString('hex'));
  }

  return rawTxs;
};

const init = async () => {
  // console.log(await getTokenName());

  // console.log(getTokenHolders());
  // console.log(BATCH_SIZE);
  console.log(await generateTxs());
};

init();
