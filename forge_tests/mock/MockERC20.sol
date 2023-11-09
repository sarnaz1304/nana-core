// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import /* {*} from */ "../helpers/TestBaseWorkflow.sol";

import {ERC20, IERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract MockERC20 is ERC20 {

constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

  function mint(address _to, uint256 _amount) external {
    _mint(_to, _amount);
  }
}