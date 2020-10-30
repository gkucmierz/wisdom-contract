
const { generate } = require('soldoc');
const path = require('path');

const BASE = path.join([__dirname, '..'].join('/'));
const INPUT_FILE = [BASE, 'src', 'wisdom-token.sol'].join('/');
const OUTPUT_DIR = [BASE, 'docs'].join('/');

generate('html', [], 'docs/', INPUT_FILE, BASE, 'spec', BASE);
