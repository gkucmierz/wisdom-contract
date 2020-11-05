
const { execSync } = require('child_process');
const { generate } = require('soldoc');
const path = require('path');

const BASE = path.join([__dirname, '..'].join('/'));
const CONTRACTS_DIR = [BASE, 'src'].join('/');
const OUTPUT_DIR = [BASE, 'docs'].join('/');

execSync(`rm -rdf ${OUTPUT_DIR}`);
generate('html', [], 'docs/', CONTRACTS_DIR, BASE, 'spec', BASE);
