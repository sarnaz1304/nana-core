import { expect } from 'chai';
import { ethers } from 'hardhat';
import { deployMockContract } from '@ethereum-waffle/mock-contract';
import { makeSplits, packFundingCycleMetadata, setBalance } from '../helpers/utils.js';

import errors from '../helpers/errors.json';

import jbDirectory from '../../artifacts/contracts/JBDirectory.sol/JBDirectory.json';
import JBEthPaymentTerminal from '../../artifacts/contracts/JBETHPaymentTerminal3_1_2.sol/JBETHPaymentTerminal3_1_2.json';
import jbPaymentTerminalStore from '../../artifacts/contracts/JBSingleTokenPaymentTerminalStore3_1_1.sol/JBSingleTokenPaymentTerminalStore3_1_1.json';
import jbOperatoreStore from '../../artifacts/contracts/JBOperatorStore.sol/JBOperatorStore.json';
import jbProjects from '../../artifacts/contracts/JBProjects.sol/JBProjects.json';
import jbSplitsStore from '../../artifacts/contracts/JBSplitsStore.sol/JBSplitsStore.json';
import jbToken from '../../artifacts/contracts/JBToken.sol/JBToken.json';
import jbPrices from '../../artifacts/contracts/JBPrices.sol/JBPrices.json';

describe('JBPayoutRedemptionPaymentTerminal3_1_2::getters', function () {
  const ETH_ADDRESS = '0x000000000000000000000000000000000000EEEe';
  let CURRENCY_ETH;

  before(async function () {
    const jbCurrenciesFactory = await ethers.getContractFactory('JBCurrencies');
    const jbCurrencies = await jbCurrenciesFactory.deploy();
    CURRENCY_ETH = await jbCurrencies.ETH();
  });

  async function setup() {
    let [deployer, terminalOwner, ...addrs] = await ethers.getSigners();

    const SPLITS_GROUP = 1;

    let [
      mockJbDirectory,
      mockJbEthPaymentTerminal,
      mockJBPaymentTerminalStore,
      mockJbOperatorStore,
      mockJbProjects,
      mockJbSplitsStore,
      mockJbPrices,
      mockJbToken,
    ] = await Promise.all([
      deployMockContract(deployer, jbDirectory.abi),
      deployMockContract(deployer, JBEthPaymentTerminal.abi),
      deployMockContract(deployer, jbPaymentTerminalStore.abi),
      deployMockContract(deployer, jbOperatoreStore.abi),
      deployMockContract(deployer, jbProjects.abi),
      deployMockContract(deployer, jbSplitsStore.abi),
      deployMockContract(deployer, jbPrices.abi),
      deployMockContract(deployer, jbToken.abi),
    ]);

    let jbTerminalFactory = await ethers.getContractFactory(
      'contracts/JBETHPaymentTerminal3_1_2.sol:JBETHPaymentTerminal3_1_2',
      deployer,
    );
    let jbErc20TerminalFactory = await ethers.getContractFactory(
      'contracts/JBERC20PaymentTerminal3_1_2.sol:JBERC20PaymentTerminal3_1_2',
      deployer,
    );
    const NON_ETH_TOKEN = mockJbToken.address;

    let jbEthPaymentTerminal = await jbTerminalFactory
      .connect(deployer)
      .deploy(
        mockJbOperatorStore.address,
        mockJbProjects.address,
        mockJbDirectory.address,
        mockJbSplitsStore.address,
        mockJbPrices.address,
        mockJBPaymentTerminalStore.address,
        terminalOwner.address,
      );

    const DECIMALS = 1;

    await mockJbToken.mock.decimals.returns(DECIMALS);

    let JBERC20PaymentTerminal = await jbErc20TerminalFactory
      .connect(deployer)
      .deploy(
        NON_ETH_TOKEN,
        SPLITS_GROUP,
        mockJbOperatorStore.address,
        mockJbProjects.address,
        mockJbDirectory.address,
        mockJbSplitsStore.address,
        mockJbPrices.address,
        mockJBPaymentTerminalStore.address,
        terminalOwner.address,
        addrs[5].address //random
      );

    return {
      jbEthPaymentTerminal,
      JBERC20PaymentTerminal,
      NON_ETH_TOKEN,
      DECIMALS,
    };
  }

  it('Should return true if the terminal accepts a token', async function () {
    const { JBERC20PaymentTerminal, jbEthPaymentTerminal, NON_ETH_TOKEN } = await setup();
    expect(await JBERC20PaymentTerminal.acceptsToken(NON_ETH_TOKEN, /*projectId*/ 0)).to.be.true;

    expect(await JBERC20PaymentTerminal.acceptsToken(ETH_ADDRESS, /*projectId*/ 0)).to.be.false;

    expect(await jbEthPaymentTerminal.acceptsToken(ETH_ADDRESS, /*projectId*/ 0)).to.be.true;

    expect(await jbEthPaymentTerminal.acceptsToken(NON_ETH_TOKEN, /*projectId*/ 0)).to.be.false;
  });

  it('Should return the decimals for the token', async function () {
    const { JBERC20PaymentTerminal, jbEthPaymentTerminal, NON_ETH_TOKEN, DECIMALS } = await setup();
    expect(await JBERC20PaymentTerminal.decimalsForToken(NON_ETH_TOKEN)).to.equal(DECIMALS);

    expect(await jbEthPaymentTerminal.decimalsForToken(ETH_ADDRESS)).to.equal(18);
  });

  it('Should return the currency for the token', async function () {
    const { JBERC20PaymentTerminal, jbEthPaymentTerminal, NON_ETH_TOKEN } = await setup();

    // slice from 36 to 42 to get the last 6 nibbles/3 bytes of the token address
    expect(await JBERC20PaymentTerminal.currencyForToken(NON_ETH_TOKEN)).to.equal(
      ethers.BigNumber.from('0x' + NON_ETH_TOKEN.slice(36, 42)).toNumber(),
    );

    expect(await jbEthPaymentTerminal.currencyForToken(ETH_ADDRESS)).to.equal(CURRENCY_ETH);
  });
});
