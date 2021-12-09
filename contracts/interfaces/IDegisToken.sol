// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDegisToken is IERC20, IERC20Permit {
    // ---------------------------------------------------------------------------------------- //
    // *************************************** Functions ************************************** //
    // ---------------------------------------------------------------------------------------- //

    function CAP() external view returns (uint256);

    function addMinter(address) external;

    function removeMinter(address) external;

    function addBurner(address) external;

    function removeBurner(address) external;

    function passOwnership(address) external;

    function releaseOwnership() external;

    function mint(address, uint256) external;

    function burn(address, uint256) external;

    // ---------------------------------------------------------------------------------------- //
    // **************************************** Events **************************************** //
    // ---------------------------------------------------------------------------------------- //

    event MinterAdded(address _newMinter);
    event MinterRemoved(address _oldMinter);

    event BurnerAdded(address _newBurner);
    event BurnerRemoved(address _oldBurner);

    event OwnerChanged(address indexed _oldOwner, address indexed _newOwner);
    event OwnershipReleased(address indexed _oldOwner);

    event Mint(address _account, uint256 _amount);
}
