// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IJBDirectory} from "./IJBDirectory.sol";
import {IJBFeeTerminal} from "./IJBFeeTerminal.sol";
import {IJBPayoutTerminal} from "./IJBPayoutTerminal.sol";
import {IJBPermitTerminal} from "./IJBPermitTerminal.sol";
import {IJBProjects} from "./IJBProjects.sol";
import {IJBRedeemTerminal} from "./IJBRedeemTerminal.sol";
import {IJBSplits} from "./IJBSplits.sol";
import {IJBTerminal} from "./IJBTerminal.sol";
import {IJBTerminalStore} from "./IJBTerminalStore.sol";

interface IJBMultiTerminal is IJBTerminal, IJBFeeTerminal, IJBRedeemTerminal, IJBPayoutTerminal, IJBPermitTerminal {
    function STORE() external view returns (IJBTerminalStore);

    function PROJECTS() external view returns (IJBProjects);

    function DIRECTORY() external view returns (IJBDirectory);

    function SPLITS() external view returns (IJBSplits);
}
