// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
// pragma experimental ABIEncoderV2; // After solidity 0.8.0, ABIEncoderV2 is enabled by default

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSD is ERC20 {
    uint256 public constant MOCK_SUPPLY = 10000e18;

    uint256 public MAX_CAP = 50000e18;

    mapping(address => uint256) userHaveMinted;
    address[] allUsers;

    constructor() ERC20("MOCKUSD", "USDC") {
        // When first deployed, give the owner some coins
        _mint(msg.sender, MOCK_SUPPLY);
    }

    function getAllUsers() external view returns (address[] memory) {
        return allUsers;
    }

    // Everyone can mint, have fun for test
    function mint(address account, uint256 value) public {
        require(value <= 10000e18, "Please mint less than 10k every time");
        require(
            userHaveMinted[account] + value <= MAX_CAP,
            "You have minted too many usd"
        );

        if (userHaveMinted[account] == 0) allUsers.push(account);

        _mint(account, value);
        userHaveMinted[account] += value;
    }
}
