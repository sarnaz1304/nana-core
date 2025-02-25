// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import /* {*} from */ "../../../helpers/TestBaseWorkflow.sol";
import {JBPermissionsSetup} from "./JBPermissionsSetup.sol";

contract TestHasPermissions_Local is JBPermissionsSetup {
    address _op = makeAddr("operator");
    address _account = makeAddr("account");
    uint256 _projectId = 1;
    uint256[] _permissionsArray = [256, 256];

    function setUp() public {
        super.permissionsSetup();
    }

    function test_WhenAnyPermissionIdGt255() external {
        // it will revert with PERMISSION_ID_OUT_OF_BOUNDS
        vm.expectRevert(abi.encodeWithSignature("PERMISSION_ID_OUT_OF_BOUNDS()"));
        _permissions.hasPermissions(_op, _account, _projectId, _permissionsArray);
    }

    modifier whenAllPermissionIdsLt255() {
        _permissionsArray = [1, 2, 3];
        _;
    }

    function test_GivenOperatorDoesNotHaveAllPermissionsSpecified() external whenAllPermissionIdsLt255 {
        // it will return false
        uint256 permissions = 1 << 1;

        // Find the storage slot
        bytes32 permissionsOfSlot = keccak256(abi.encode(_op, uint256(0)));
        bytes32 accountSlot = keccak256(abi.encode(_account, uint256(permissionsOfSlot)));
        bytes32 slot = keccak256(abi.encode(_projectId, accountSlot));

        // Set storage
        vm.store(address(_permissions), slot, bytes32(permissions));

        bool hasAll = _permissions.hasPermissions(_op, _account, _projectId, _permissionsArray);
        assertEq(hasAll, false);
    }

    function test_GivenOperatorHasAllPermissionsSpecified() external whenAllPermissionIdsLt255 {
        // it will return true
        uint256 permissions = 1 << 1;
        permissions |= 1 << 2;
        permissions |= 1 << 3;

        // Find the storage slot
        bytes32 permissionsOfSlot = keccak256(abi.encode(_op, uint256(0)));
        bytes32 accountSlot = keccak256(abi.encode(_account, uint256(permissionsOfSlot)));
        bytes32 slot = keccak256(abi.encode(_projectId, accountSlot));

        // Set storage
        vm.store(address(_permissions), slot, bytes32(permissions));

        bool hasAll = _permissions.hasPermissions(_op, _account, _projectId, _permissionsArray);
        assertEq(hasAll, true);
    }
}
