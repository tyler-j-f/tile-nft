/* Useful aliases */

// No, we don't have easy access to web3 here.
// And bn.js new BN() weirdly doesn't work with truffle-assertions
const toBN = a => a;
const toBNHex = a => a;


// Configfuration for our tokens

const MINT_INITIAL_SUPPLY = 1000;
const INITIAL_SUPPLY = toBNHex('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');

const CLASS_COMMON = 0;
const CLASS_RARE = 1;
const CLASS_EPIC = 2;
const CLASS_LEGENDARY = 3;
const CLASS_DIVINE = 4;
const CLASS_HIDDEN = 5;
const NUM_CLASSES = 6;

module.exports = {
  MINT_INITIAL_SUPPLY,
  INITIAL_SUPPLY,
  CLASS_COMMON,
  CLASS_RARE,
  CLASS_EPIC,
  CLASS_LEGENDARY,
  CLASS_DIVINE,
  CLASS_HIDDEN,
  NUM_CLASSES
};
