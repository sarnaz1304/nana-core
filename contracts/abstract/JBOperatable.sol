// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";

import {IJBOperatable} from "./../interfaces/IJBOperatable.sol";
import {IJBOperatorStore} from "./../interfaces/IJBOperatorStore.sol";

/// @notice Modifiers to allow access to functions based on the message sender's operator status.
abstract contract JBOperatable is Context, IJBOperatable {
    //*********************************************************************//
    // --------------------------- custom errors -------------------------- //
    //*********************************************************************//
    error UNAUTHORIZED();

    //*********************************************************************//
    // ---------------------------- modifiers ---------------------------- //
    //*********************************************************************//

    /// @notice Only allows the speficied account or an operator of the account to proceed.
    /// @param _account The account to check for.
    /// @param _domain The domain namespace to look for an operator within.
    /// @param _permissionIndex The index of the permission to check for.
    modifier requirePermission(address _account, uint256 _domain, uint256 _permissionIndex) {
        _requirePermission(_account, _domain, _permissionIndex);
        _;
    }

    /// @notice Only allows the speficied account, an operator of the account to proceed, or a truthy override flag.
    /// @param _account The account to check for.
    /// @param _domain The domain namespace to look for an operator within.
    /// @param _permissionIndex The index of the permission to check for.
    /// @param _override A condition to force allowance for.
    modifier requirePermissionAllowingOverride(
        address _account,
        uint256 _domain,
        uint256 _permissionIndex,
        bool _override
    ) {
        _requirePermissionAllowingOverride(_account, _domain, _permissionIndex, _override);
        _;
    }

    //*********************************************************************//
    // ---------------- public immutable stored properties --------------- //
    //*********************************************************************//

    /// @notice A contract storing operator assignments.
    IJBOperatorStore public immutable override operatorStore;

    //*********************************************************************//
    // -------------------------- constructor ---------------------------- //
    //*********************************************************************//

    /// @param _operatorStore A contract storing operator assignments.
    constructor(IJBOperatorStore _operatorStore) {
        operatorStore = _operatorStore;
    }

    //*********************************************************************//
    // -------------------------- internal views ------------------------- //
    //*********************************************************************//

    /// @notice Require the message sender is either the account or has the specified permission.
    /// @param _account The account to allow.
    /// @param _domain The domain namespace within which the permission index will be checked.
    /// @param _permissionIndex The permission index that an operator must have within the specified domain to be allowed.
    function _requirePermission(address _account, uint256 _domain, uint256 _permissionIndex)
        internal
        view
    {
        address _sender = _msgSender();
        if (
            _sender != _account
                && !operatorStore.hasPermission(_sender, _account, _domain, _permissionIndex)
                && !operatorStore.hasPermission(_sender, _account, 0, _permissionIndex)
        ) revert UNAUTHORIZED();
    }

    /// @notice Require the message sender is either the account, has the specified permission, or the override condition is true.
    /// @param _account The account to allow.
    /// @param _domain The domain namespace within which the permission index will be checked.
    /// @param _domain The permission index that an operator must have within the specified domain to be allowed.
    /// @param _override The override condition to allow.
    function _requirePermissionAllowingOverride(
        address _account,
        uint256 _domain,
        uint256 _permissionIndex,
        bool _override
    ) internal view {
        if(_override) return;
        _requirePermission(_account, _domain, _permissionIndex);
    }
}
