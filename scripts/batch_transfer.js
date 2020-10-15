
require('dotenv').config();
const Contract = require('web3-eth-contract');
const ethWallet = require('ethereumjs-wallet');

const {
  PRIVKEY,
  CONTRACT_ADDR,
  INFURA_KOVAN_PROVIDER,
} = process.env;
const CONTRACT_ABI = require('../abi.json');

const hexToBuffer = hex => {
  const size = hex.length / 2;
  const res = new Uint8Array(size);
  PRIVKEY.match(/../g).map((s, i) => res[i] = parseInt(s, 16));
  return Buffer.from(res, 'utf8')
};

const privkeyToAddress = priv => {
  return ethWallet.default.fromPrivateKey(hexToBuffer(priv)).getAddressString() + '';
};

Contract.setProvider(INFURA_KOVAN_PROVIDER);
const contract = new Contract(CONTRACT_ABI, CONTRACT_ADDR, {
  from: privkeyToAddress(PRIVKEY)
});

const init = async () => {
  const name = await contract.methods.name().call();
  console.log(name);
};

init();
