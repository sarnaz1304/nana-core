// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "forge-std/Test.sol";

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC165, IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import {JBController3_1} from "@juicebox/JBController3_1.sol";
import {JBDirectory} from "@juicebox/JBDirectory.sol";
import {JBERC20PaymentTerminal3_1_2} from "@juicebox/JBERC20PaymentTerminal3_1_2.sol";
import {JBSingleTokenPaymentTerminalStore3_1_1} from
    "@juicebox/JBSingleTokenPaymentTerminalStore3_1_1.sol";
import {JBFundAccessConstraintsStore} from "@juicebox/JBFundAccessConstraintsStore.sol";
import {JBFundingCycleStore} from "@juicebox/JBFundingCycleStore.sol";
import {JBOperatorStore} from "@juicebox/JBOperatorStore.sol";
import {JBPrices} from "@juicebox/JBPrices.sol";
import {JBProjects} from "@juicebox/JBProjects.sol";
import {JBSplitsStore} from "@juicebox/JBSplitsStore.sol";
import {JBToken} from "@juicebox/JBToken.sol";
import {JBTokenStore} from "@juicebox/JBTokenStore.sol";
import {JBReconfigurationBufferBallot} from "@juicebox/JBReconfigurationBufferBallot.sol";
import {JBETHERC20SplitsPayerDeployer} from "@juicebox/JBETHERC20SplitsPayerDeployer.sol";
import {JBETHERC20SplitsPayer} from "@juicebox/JBETHERC20SplitsPayer.sol";
import {JBETHPaymentTerminal3_1_2} from "@juicebox/JBETHPaymentTerminal3_1_2.sol";

import {JBPayoutRedemptionPaymentTerminal3_1_2} from
    "@juicebox/abstract/JBPayoutRedemptionPaymentTerminal3_1_2.sol";
import {JBSingleTokenPaymentTerminal} from "@juicebox/abstract/JBSingleTokenPaymentTerminal.sol";

import {JBDidPayData3_1_1} from "@juicebox/structs/JBDidPayData3_1_1.sol";
import {JBDidRedeemData3_1_1} from "@juicebox/structs/JBDidRedeemData3_1_1.sol";
import {JBFee} from "@juicebox/structs/JBFee.sol";
import {JBFees} from "@juicebox/libraries/JBFees.sol";
import {JBFundAccessConstraints} from "@juicebox/structs/JBFundAccessConstraints.sol";
import {JBFundingCycle} from "@juicebox/structs/JBFundingCycle.sol";
import {JBFundingCycleData} from "@juicebox/structs/JBFundingCycleData.sol";
import {JBFundingCycleMetadata} from "@juicebox/structs/JBFundingCycleMetadata.sol";
import {JBFundingCycleConfiguration} from "@juicebox/structs/JBFundingCycleConfiguration.sol";
import {JBGroupedSplits} from "@juicebox/structs/JBGroupedSplits.sol";
import {JBOperatorData} from "@juicebox/structs/JBOperatorData.sol";
import {JBPayParamsData} from "@juicebox/structs/JBPayParamsData.sol";
import {JBProjectMetadata} from "@juicebox/structs/JBProjectMetadata.sol";
import {JBRedeemParamsData} from "@juicebox/structs/JBRedeemParamsData.sol";
import {JBSplit} from "@juicebox/structs/JBSplit.sol";
import {JBProjectMetadata} from "@juicebox/structs/JBProjectMetadata.sol";
import {JBGlobalFundingCycleMetadata} from "@juicebox/structs/JBGlobalFundingCycleMetadata.sol";
import {JBPayDelegateAllocation3_1_1} from "@juicebox/structs/JBPayDelegateAllocation3_1_1.sol";
import {JBTokenAmount} from "@juicebox/structs/JBTokenAmount.sol";
import {JBSplitAllocationData} from "@juicebox/structs/JBSplitAllocationData.sol";
import {IJBPaymentTerminal} from "@juicebox/interfaces/IJBPaymentTerminal.sol";
import {IJBToken} from "@juicebox/interfaces/IJBToken.sol";

import {IJBController3_1} from "@juicebox/interfaces/IJBController3_1.sol";
import {IJBMigratable} from "@juicebox/interfaces/IJBMigratable.sol";
import {IJBOperatorStore} from "@juicebox/interfaces/IJBOperatorStore.sol";
import {IJBSingleTokenPaymentTerminalStore3_1_1} from
    "@juicebox/interfaces/IJBSingleTokenPaymentTerminalStore3_1_1.sol";
import {IJBProjects} from "@juicebox/interfaces/IJBProjects.sol";
import {IJBFundingCycleBallot} from "@juicebox/interfaces/IJBFundingCycleBallot.sol";
import {IJBPayoutRedemptionPaymentTerminal3_1} from
    "@juicebox/interfaces/IJBPayoutRedemptionPaymentTerminal3_1.sol";
import {IJBDirectory} from "@juicebox/interfaces/IJBDirectory.sol";
import {IJBFundingCycleStore} from "@juicebox/interfaces/IJBFundingCycleStore.sol";
import {IJBSplitsStore} from "@juicebox/interfaces/IJBSplitsStore.sol";
import {IJBTokenStore} from "@juicebox/interfaces/IJBTokenStore.sol";
import {IJBSplitAllocator} from "@juicebox/interfaces/IJBSplitAllocator.sol";
import {IJBPayDelegate3_1_1} from "@juicebox/interfaces/IJBPayDelegate3_1_1.sol";
import {IJBFundingCycleDataSource3_1_1} from
    "@juicebox/interfaces/IJBFundingCycleDataSource3_1_1.sol";
import {IJBFeeGauge3_1} from "@juicebox/interfaces/IJBFeeGauge3_1.sol";
import {IJBPayoutRedemptionPaymentTerminal3_1} from
    "@juicebox/interfaces/IJBPayoutRedemptionPaymentTerminal3_1.sol";
import {IJBFeeHoldingTerminal} from "@juicebox/interfaces/IJBFeeHoldingTerminal.sol";
import {IJBProjectPayer} from "@juicebox/interfaces/IJBProjectPayer.sol";
import {IJBOperatable} from "@juicebox/interfaces/IJBOperatable.sol";
import {IJBAllowanceTerminal3_1} from "@juicebox/interfaces/IJBAllowanceTerminal3_1.sol";
import {IJBPayoutTerminal3_1} from "@juicebox/interfaces/IJBPayoutTerminal3_1.sol";
import {IJBRedemptionTerminal} from "@juicebox/interfaces/IJBRedemptionTerminal.sol";
import {IJBSingleTokenPaymentTerminal} from "@juicebox/interfaces/IJBSingleTokenPaymentTerminal.sol";
import {IJBFundingCycleBallot} from "@juicebox/interfaces/IJBFundingCycleBallot.sol";
import {IJBPrices} from "@juicebox/interfaces/IJBPrices.sol";
import {IJBPriceFeed} from "@juicebox/interfaces/IJBPriceFeed.sol";
import {IJBSplitsPayer} from "@juicebox/interfaces/IJBSplitsPayer.sol";

import {JBTokens} from "@juicebox/libraries/JBTokens.sol";
import {JBFundingCycleMetadataResolver} from
    "@juicebox/libraries/JBFundingCycleMetadataResolver.sol";
import {JBConstants} from "@juicebox/libraries/JBConstants.sol";
import {JBSplitsGroups} from "@juicebox/libraries/JBSplitsGroups.sol";
import {JBOperations} from "@juicebox/libraries/JBOperations.sol";

import "./AccessJBLib.sol";

import "@paulrberg/contracts/math/PRBMath.sol";
import "@paulrberg/contracts/math/PRBMathUD60x18.sol";

// Base contract for Juicebox system tests.
//
// Provides common functionality, such as deploying contracts on test setup.
contract TestBaseWorkflow is Test {
    //*********************************************************************//
    // --------------------- internal stored properties ------------------- //
    //*********************************************************************//

    // Multisig address used for testing.
    address internal _multisig = address(123);

    address internal _beneficiary = address(69_420);

    // JBOperatorStore
    JBOperatorStore internal _jbOperatorStore;
    // JBProjects
    JBProjects internal _jbProjects;
    // JBPrices
    JBPrices internal _jbPrices;
    // JBDirectory
    JBDirectory internal _jbDirectory;
    // JBFundingCycleStore
    JBFundingCycleStore internal _jbFundingCycleStore;
    // JBToken
    JBToken internal _jbToken;
    // JBTokenStore
    JBTokenStore internal _jbTokenStore;
    // JBSplitsStore
    JBSplitsStore internal _jbSplitsStore;

    // JBController3_1(s)
    JBController3_1 internal _jbController;

    JBFundAccessConstraintsStore internal _jbFundAccessConstraintsStore;

    // JBETHPaymentTerminalStore
    JBSingleTokenPaymentTerminalStore3_1_1 internal _jbPaymentTerminalStore3_1_1;

    // JBETHPaymentTerminal3_1_2
    JBETHPaymentTerminal3_1_2 internal _jbETHPaymentTerminal3_1_2;

    // JBERC20PaymentTerminal3_1_2
    JBERC20PaymentTerminal3_1_2 internal _jbERC20PaymentTerminal3_1_2;

    // AccessJBLib
    AccessJBLib internal _accessJBLib;

    //*********************************************************************//
    // ------------------------- internal views -------------------------- //
    //*********************************************************************//

    function multisig() internal view returns (address) {
        return _multisig;
    }

    function jbOperatorStore() internal view returns (JBOperatorStore) {
        return _jbOperatorStore;
    }

    function jbProjects() internal view returns (JBProjects) {
        return _jbProjects;
    }

    function jbPrices() internal view returns (JBPrices) {
        return _jbPrices;
    }

    function jbDirectory() internal view returns (JBDirectory) {
        return _jbDirectory;
    }

    function jbFundingCycleStore() internal view returns (JBFundingCycleStore) {
        return _jbFundingCycleStore;
    }

    function jbTokenStore() internal view returns (JBTokenStore) {
        return _jbTokenStore;
    }

    function jbSplitsStore() internal view returns (JBSplitsStore) {
        return _jbSplitsStore;
    }

    function jbController() internal view returns (JBController3_1) {
        return _jbController;
    }

    function jbAccessConstraintStore() internal view returns (JBFundAccessConstraintsStore) {
        return _jbFundAccessConstraintsStore;
    }

    function jbPaymentTerminalStore()
        internal
        view
        returns (JBSingleTokenPaymentTerminalStore3_1_1)
    {
        return _jbPaymentTerminalStore3_1_1;
    }

    function jbETHPaymentTerminal() internal view returns (JBETHPaymentTerminal3_1_2) {
        return _jbETHPaymentTerminal3_1_2;
    }

    function jbERC20PaymentTerminal() internal view returns (JBERC20PaymentTerminal3_1_2) {
        return _jbERC20PaymentTerminal3_1_2;
    }

    function jbToken() internal view returns (JBToken) {
        return _jbToken;
    }

    function jbLibraries() internal view returns (AccessJBLib) {
        return _accessJBLib;
    }

    //*********************************************************************//
    // --------------------------- test setup ---------------------------- //
    //*********************************************************************//

    // Deploys and initializes contracts for testing.
    function setUp() public virtual {
        // Labels
        vm.label(_multisig, "projectOwner");
        vm.label(_beneficiary, "beneficiary");

        // JBOperatorStore
        _jbOperatorStore = new JBOperatorStore();
        vm.label(address(_jbOperatorStore), "JBOperatorStore");

        // JBProjects
        _jbProjects = new JBProjects(_jbOperatorStore);
        vm.label(address(_jbProjects), "JBProjects");

        // JBPrices
        _jbPrices = new JBPrices(_multisig);
        vm.label(address(_jbPrices), "JBPrices");

        address contractAtNoncePlusOne = addressFrom(address(this), 5);

        // JBFundingCycleStore
        _jbFundingCycleStore = new JBFundingCycleStore(IJBDirectory(contractAtNoncePlusOne));
        vm.label(address(_jbFundingCycleStore), "JBFundingCycleStore");

        // JBDirectory
        _jbDirectory =
            new JBDirectory(_jbOperatorStore, _jbProjects, _jbFundingCycleStore, _multisig);
        vm.label(address(_jbDirectory), "JBDirectory");

        // JBTokenStore
        _jbTokenStore = new JBTokenStore(
      _jbOperatorStore,
      _jbProjects,
      _jbDirectory,
      _jbFundingCycleStore
    );
        vm.label(address(_jbTokenStore), "JBTokenStore");

        // JBSplitsStore
        _jbSplitsStore = new JBSplitsStore(_jbOperatorStore, _jbProjects, _jbDirectory);
        vm.label(address(_jbSplitsStore), "JBSplitsStore");

        _jbFundAccessConstraintsStore = new JBFundAccessConstraintsStore(_jbDirectory);
        vm.label(address(_jbFundAccessConstraintsStore), "JBFundAccessConstraintsStore");

        // JBController3_1
        _jbController = new JBController3_1(
      _jbOperatorStore,
      _jbProjects,
      _jbDirectory,
      _jbFundingCycleStore,
      _jbTokenStore,
      _jbSplitsStore,
      _jbFundAccessConstraintsStore
    );
        vm.label(address(_jbController), "JBController3_1");

        vm.prank(_multisig);
        _jbDirectory.setIsAllowedToSetFirstController(address(_jbController), true);

        // JBETHPaymentTerminalStore
        _jbPaymentTerminalStore3_1_1 = new JBSingleTokenPaymentTerminalStore3_1_1(
      _jbDirectory,
      _jbFundingCycleStore,
      _jbPrices
    );
        vm.label(address(_jbPaymentTerminalStore3_1_1), "JBSingleTokenPaymentTerminalStore3_1_1");

        // AccessJBLib
        _accessJBLib = new AccessJBLib();

        // JBETHPaymentTerminal3_1_2
        _jbETHPaymentTerminal3_1_2 = new JBETHPaymentTerminal3_1_2(
      _jbOperatorStore,
      _jbProjects,
      _jbDirectory,
      _jbSplitsStore,
      _jbPrices,
      address(_jbPaymentTerminalStore3_1_1),
      _multisig
    );
        vm.label(address(_jbETHPaymentTerminal3_1_2), "JBETHPaymentTerminal3_1_2");

        vm.prank(_multisig);
        _jbToken = new JBToken('MyToken', 'MT', 1);

        vm.prank(_multisig);
        _jbToken.mint(1, _multisig, 100 * 10 ** 18);

        // JBERC20PaymentTerminal3_1_2
        _jbERC20PaymentTerminal3_1_2 = new JBERC20PaymentTerminal3_1_2(
      _jbToken,
      1, // JBSplitsGroupe
      _jbOperatorStore,
      _jbProjects,
      _jbDirectory,
      _jbSplitsStore,
      _jbPrices,
      address(_jbPaymentTerminalStore3_1_1),
      _multisig
    );

        vm.label(address(_jbERC20PaymentTerminal3_1_2), "JBERC20PaymentTerminal3_1_2");
    }

    //https://ethereum.stackexchange.com/questions/24248/how-to-calculate-an-ethereum-contracts-address-during-its-creation-using-the-so
    function addressFrom(address _origin, uint256 _nonce)
        internal
        pure
        returns (address _address)
    {
        bytes memory data;
        if (_nonce == 0x00) {
            data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, bytes1(0x80));
        } else if (_nonce <= 0x7f) {
            data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, uint8(_nonce));
        } else if (_nonce <= 0xff) {
            data =
                abi.encodePacked(bytes1(0xd7), bytes1(0x94), _origin, bytes1(0x81), uint8(_nonce));
        } else if (_nonce <= 0xffff) {
            data =
                abi.encodePacked(bytes1(0xd8), bytes1(0x94), _origin, bytes1(0x82), uint16(_nonce));
        } else if (_nonce <= 0xffffff) {
            data =
                abi.encodePacked(bytes1(0xd9), bytes1(0x94), _origin, bytes1(0x83), uint24(_nonce));
        } else {
            data =
                abi.encodePacked(bytes1(0xda), bytes1(0x94), _origin, bytes1(0x84), uint32(_nonce));
        }
        bytes32 hash = keccak256(data);
        assembly {
            mstore(0, hash)
            _address := mload(0)
        }
    }

    function strEqual(string memory a, string memory b) internal returns (bool) {
        return keccak256(abi.encode(a)) == keccak256(abi.encode(b));
    }
}
