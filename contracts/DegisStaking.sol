// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IDegisToken.sol";

contract DegisStaking is ERC20("DegisStaking", "xDegis") {
    using SafeERC20 for IDegisToken;

    address public owner;
    IDegisToken degis;

    uint256 public degisPerBlock;

    uint256 public totalScores;

    mapping(address => uint256) userScores;

    constructor(address _degis) {
        degis = IDegisToken(_degis);
    }

    function pendingReward(address _userAddress) external view {}

    function stake(
        uint256 _type,
        uint256 _amount,
        uint256 _length
    ) external {
        require(
            degis.balanceOf(msg.sender) >= _amount,
            "You do not have enough degis token"
        );

        degis.safeTransferFrom(msg.sender, address(this), _amount);

        if (_type == 0) {
            _flexibleStake(_amount);
        } else if (_type == 1) {
            _stableStake(_length, _amount);
        } else {}
    }

    function _flexibleStake(uint256 _amount) internal {}

    function _stableStake(uint256 _length, uint256 _amount) internal {}

    function unstake() external {}

    function settle() external {}
}
