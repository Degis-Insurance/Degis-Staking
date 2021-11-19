// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IDegisToken.sol";

contract DegisStaking is ERC20("DegisStaking", "xDegis") {
    address public owner;
    IDegisToken degis;

    uint256 public degisPerBlock;

    uint256 public totalScores;

    constructor(address _degis) {
        degis = IDegisToken(_degis);
    }

    function stake() external {}

    function flexibleStake() internal {}

    function stableStake() internal {}

    function unstake() external {}

    function settle() external {}
}
