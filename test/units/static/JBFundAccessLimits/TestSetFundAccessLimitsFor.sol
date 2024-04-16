// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import /* {*} from */ "../../../helpers/TestBaseWorkflow.sol";
import {JBFundAccessSetup} from "./JBFundAccessSetup.sol";

contract TestSetFundAccessLimitsFor_Local is JBFundAccessSetup {
    uint256 _projectId = 1;
    uint256 _ruleset = block.timestamp;
    uint256 _validCurrency = uint32(uint160(JBConstants.NATIVE_TOKEN));
    uint256 _invalidCurrency = uint256(type(uint32).max) + 1;
    address _terminal = address(1);
    address _terminal2 = address(2);
    address _someToken = makeAddr("sometoken");
    uint256 _validLimit = 1e18;
    uint256 _invalidLimit = uint256(type(uint224).max) + 1;

    function setUp() public {
        super.fundAccessSetup();
    }

    function test_WhenCallerIsNotController() external {
        // it will revert

        bytes memory _controllerCall = abi.encodeCall(IJBDirectory.controllerOf, (1));
        bytes memory _return = abi.encode(address(makeAddr("notThisContract")));

        mockExpect(address(directory), _controllerCall, _return);

        // Fund Access config
        JBFundAccessLimitGroup[] memory _fundAccessLimitGroup = new JBFundAccessLimitGroup[](2);

        vm.expectRevert(abi.encodeWithSignature("CONTROLLER_UNAUTHORIZED()"));
        _fundAccess.setFundAccessLimitsFor(_projectId, _ruleset, _fundAccessLimitGroup);
    }

    modifier whenCallerIsControllerOfProject() {
        bytes memory _controllerCall = abi.encodeCall(IJBDirectory.controllerOf, (1));
        bytes memory _return = abi.encode(address(this));

        mockExpect(address(directory), _controllerCall, _return);
        _;
    }

    function test_GivenPayoutLimitAmountIsGtUint224() external whenCallerIsControllerOfProject {
        // it will revert INVALID_PAYOUT_LIMIT

        // Fund Access config
        JBFundAccessLimitGroup[] memory _fundAccessLimitGroup = new JBFundAccessLimitGroup[](2);
        {
            // Specify a payout limit.
            JBCurrencyAmount[] memory _payoutLimits = new JBCurrencyAmount[](2);
            _payoutLimits[0] =
                JBCurrencyAmount({amount: _validLimit, currency: uint32(uint160(JBConstants.NATIVE_TOKEN))});

            // Specify a second payout limit.
            _payoutLimits[1] = JBCurrencyAmount({amount: _invalidLimit, currency: uint32(uint160(_someToken))});

            // Specify a surplus allowance.
            JBCurrencyAmount[] memory _surplusAllowances = new JBCurrencyAmount[](0);

            _fundAccessLimitGroup[0] = JBFundAccessLimitGroup({
                terminal: address(_terminal),
                token: JBConstants.NATIVE_TOKEN,
                payoutLimits: _payoutLimits,
                surplusAllowances: _surplusAllowances
            });
        }

        vm.expectRevert(abi.encodeWithSignature("INVALID_PAYOUT_LIMIT()"));
        _fundAccess.setFundAccessLimitsFor(_projectId, _ruleset, _fundAccessLimitGroup);
    }

    function test_GivenPayoutLimitCurrencyIsGtUint32() external whenCallerIsControllerOfProject {
        // it will revert INVALID_PAYOUT_LIMIT_CURRENCY

        // Fund Access config
        JBFundAccessLimitGroup[] memory _fundAccessLimitGroup = new JBFundAccessLimitGroup[](2);
        {
            // Specify a payout limit.
            JBCurrencyAmount[] memory _payoutLimits = new JBCurrencyAmount[](2);
            _payoutLimits[0] =
                JBCurrencyAmount({amount: _validLimit, currency: uint32(uint160(JBConstants.NATIVE_TOKEN))});

            // Specify a second payout limit.
            _payoutLimits[1] = JBCurrencyAmount({amount: _validLimit, currency: _invalidCurrency});

            // Specify a surplus allowance.
            JBCurrencyAmount[] memory _surplusAllowances = new JBCurrencyAmount[](0);

            _fundAccessLimitGroup[0] = JBFundAccessLimitGroup({
                terminal: address(_terminal),
                token: JBConstants.NATIVE_TOKEN,
                payoutLimits: _payoutLimits,
                surplusAllowances: _surplusAllowances
            });
        }

        vm.expectRevert(abi.encodeWithSignature("INVALID_PAYOUT_LIMIT_CURRENCY()"));
        _fundAccess.setFundAccessLimitsFor(_projectId, _ruleset, _fundAccessLimitGroup);
    }

    function test_GivenPayoutLimitCurrencyIsNotGivenInAscendingOrder() external whenCallerIsControllerOfProject {
        // it will revert INVALID_PAYOUT_LIMIT_CURRENCY_ORDERING

        // Fund Access config
        JBFundAccessLimitGroup[] memory _fundAccessLimitGroup = new JBFundAccessLimitGroup[](2);
        {
            // Specify a payout limit.
            JBCurrencyAmount[] memory _payoutLimits = new JBCurrencyAmount[](2);
            _payoutLimits[0] = JBCurrencyAmount({amount: _validLimit, currency: type(uint32).max});

            // Specify a second payout limit.
            _payoutLimits[1] =
                JBCurrencyAmount({amount: _validLimit, currency: uint32(uint160(JBConstants.NATIVE_TOKEN))});

            // Specify a surplus allowance.
            JBCurrencyAmount[] memory _surplusAllowances = new JBCurrencyAmount[](0);

            _fundAccessLimitGroup[0] = JBFundAccessLimitGroup({
                terminal: address(_terminal),
                token: JBConstants.NATIVE_TOKEN,
                payoutLimits: _payoutLimits,
                surplusAllowances: _surplusAllowances
            });
        }

        vm.expectRevert(abi.encodeWithSignature("INVALID_PAYOUT_LIMIT_CURRENCY_ORDERING()"));
        _fundAccess.setFundAccessLimitsFor(_projectId, _ruleset, _fundAccessLimitGroup);
    }

    function test_GivenSurplusAllowanceAmountGtUint224() external whenCallerIsControllerOfProject {
        // it will revert INVALID_SURPLUS_ALLOWANCE

        // Fund Access config
        JBFundAccessLimitGroup[] memory _fundAccessLimitGroup = new JBFundAccessLimitGroup[](2);
        {
            // Specify a payout limit.
            JBCurrencyAmount[] memory _payoutLimits = new JBCurrencyAmount[](1);
            _payoutLimits[0] = JBCurrencyAmount({amount: _validLimit, currency: type(uint32).max});

            // Specify a surplus allowance.
            JBCurrencyAmount[] memory _surplusAllowances = new JBCurrencyAmount[](1);
            _surplusAllowances[0] =
                JBCurrencyAmount({amount: _invalidLimit, currency: uint32(uint160(JBConstants.NATIVE_TOKEN))});

            _fundAccessLimitGroup[0] = JBFundAccessLimitGroup({
                terminal: address(_terminal),
                token: JBConstants.NATIVE_TOKEN,
                payoutLimits: _payoutLimits,
                surplusAllowances: _surplusAllowances
            });
        }

        vm.expectRevert(abi.encodeWithSignature("INVALID_SURPLUS_ALLOWANCE()"));
        _fundAccess.setFundAccessLimitsFor(_projectId, _ruleset, _fundAccessLimitGroup);
    }

    function test_GivenSurplusAllowanceCurrencyGtUint32() external whenCallerIsControllerOfProject {
        // it will revert INVALID_PAYOUT_LIMIT_CURRENCY

        // Fund Access config
        JBFundAccessLimitGroup[] memory _fundAccessLimitGroup = new JBFundAccessLimitGroup[](2);
        {
            // Specify a payout limit.
            JBCurrencyAmount[] memory _payoutLimits = new JBCurrencyAmount[](1);
            _payoutLimits[0] = JBCurrencyAmount({amount: _validLimit, currency: _invalidCurrency});

            // Specify a surplus allowance.
            JBCurrencyAmount[] memory _surplusAllowances = new JBCurrencyAmount[](1);
            _surplusAllowances[0] = JBCurrencyAmount({amount: _validLimit, currency: _validCurrency});

            _fundAccessLimitGroup[0] = JBFundAccessLimitGroup({
                terminal: address(_terminal),
                token: JBConstants.NATIVE_TOKEN,
                payoutLimits: _payoutLimits,
                surplusAllowances: _surplusAllowances
            });
        }

        vm.expectRevert(abi.encodeWithSignature("INVALID_PAYOUT_LIMIT_CURRENCY()"));
        _fundAccess.setFundAccessLimitsFor(_projectId, _ruleset, _fundAccessLimitGroup);
    }

    function test_GivenSurplusAllowanceCurrenciesAreNotAscendingOrder() external whenCallerIsControllerOfProject {
        // it will revert INVALID_SURPLUS_ALLOWANCE_CURRENCY_ORDERING

        // Fund Access config
        JBFundAccessLimitGroup[] memory _fundAccessLimitGroup = new JBFundAccessLimitGroup[](2);
        {
            // Specify a payout limit.
            JBCurrencyAmount[] memory _payoutLimits = new JBCurrencyAmount[](1);
            _payoutLimits[0] = JBCurrencyAmount({amount: _validLimit, currency: _validCurrency});

            // Specify a surplus allowance.
            JBCurrencyAmount[] memory _surplusAllowances = new JBCurrencyAmount[](2);
            _surplusAllowances[0] = JBCurrencyAmount({amount: _validLimit, currency: type(uint32).max});

            _surplusAllowances[1] = JBCurrencyAmount({amount: _validLimit, currency: _validCurrency});

            _fundAccessLimitGroup[0] = JBFundAccessLimitGroup({
                terminal: address(_terminal),
                token: JBConstants.NATIVE_TOKEN,
                payoutLimits: _payoutLimits,
                surplusAllowances: _surplusAllowances
            });
        }

        vm.expectRevert(abi.encodeWithSignature("INVALID_SURPLUS_ALLOWANCE_CURRENCY_ORDERING()"));
        _fundAccess.setFundAccessLimitsFor(_projectId, _ruleset, _fundAccessLimitGroup);
    }

    function test_GivenSurplusAllowanceCurrencyGTUint32Max() external whenCallerIsControllerOfProject {
        // it will revert INVALID_SURPLUS_ALLOWANCE_CURRENCY

        // Fund Access config
        JBFundAccessLimitGroup[] memory _fundAccessLimitGroup = new JBFundAccessLimitGroup[](2);
        {
            // Specify a payout limit.
            JBCurrencyAmount[] memory _payoutLimits = new JBCurrencyAmount[](1);
            _payoutLimits[0] = JBCurrencyAmount({amount: _validLimit, currency: _validCurrency});

            // Specify a surplus allowance.
            JBCurrencyAmount[] memory _surplusAllowances = new JBCurrencyAmount[](2);
            _surplusAllowances[0] = JBCurrencyAmount({amount: _validLimit, currency: type(uint32).max});

            _surplusAllowances[1] = JBCurrencyAmount({amount: _validLimit, currency: _invalidCurrency});

            _fundAccessLimitGroup[0] = JBFundAccessLimitGroup({
                terminal: address(_terminal),
                token: JBConstants.NATIVE_TOKEN,
                payoutLimits: _payoutLimits,
                surplusAllowances: _surplusAllowances
            });
        }

        vm.expectRevert(abi.encodeWithSignature("INVALID_SURPLUS_ALLOWANCE_CURRENCY()"));
        _fundAccess.setFundAccessLimitsFor(_projectId, _ruleset, _fundAccessLimitGroup);
    }

    function test_GivenValidConfig() external whenCallerIsControllerOfProject {
        // it will set packed properties and emit SetFundAccessLimits

        // Fund Access config
        JBFundAccessLimitGroup[] memory _fundAccessLimitGroup = new JBFundAccessLimitGroup[](2);
        {
            // Specify a payout limit.
            JBCurrencyAmount[] memory _payoutLimits = new JBCurrencyAmount[](2);
            _payoutLimits[0] =
                JBCurrencyAmount({amount: _validLimit, currency: uint32(uint160(JBConstants.NATIVE_TOKEN))});

            // Specify a second payout limit.
            _payoutLimits[1] = JBCurrencyAmount({amount: _validLimit, currency: uint32(uint160(_someToken))});

            // Specify a surplus allowance.
            JBCurrencyAmount[] memory _surplusAllowances = new JBCurrencyAmount[](0);

            _fundAccessLimitGroup[0] = JBFundAccessLimitGroup({
                terminal: address(_terminal),
                token: JBConstants.NATIVE_TOKEN,
                payoutLimits: _payoutLimits,
                surplusAllowances: _surplusAllowances
            });

            _fundAccessLimitGroup[1] = JBFundAccessLimitGroup({
                terminal: address(_terminal2),
                token: JBConstants.NATIVE_TOKEN,
                payoutLimits: _payoutLimits,
                surplusAllowances: _surplusAllowances
            });
        }

        vm.expectEmit();
        emit IJBFundAccessLimits.SetFundAccessLimits(_ruleset, _projectId, _fundAccessLimitGroup[0], address(this));

        vm.expectEmit();
        emit IJBFundAccessLimits.SetFundAccessLimits(_ruleset, _projectId, _fundAccessLimitGroup[1], address(this));

        _fundAccess.setFundAccessLimitsFor(_projectId, _ruleset, _fundAccessLimitGroup);
    }
}
