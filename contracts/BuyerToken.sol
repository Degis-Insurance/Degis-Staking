// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IBuyerToken.sol";

contract BuyerToken is ERC20("DegisBuyerToken", "DBT"), IBuyerToken {
    address public owner;
    address public minter;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyOwnerMinter() {
        require(
            msg.sender == owner || msg.sender == minter,
            "Only the owner or minter can call this function"
        );
        _;
    }

    function mint(address _account, uint256 _amount) public onlyOwnerMinter {
        _mint(_account, _amount);
    }

    function passMinterRole(address _newMinter) public onlyOwner {
        address _oldMinter = minter;
        minter = _newMinter;
        emit MinterRoleChanged(_oldMinter, _newMinter);
    }

    function burn(address _account, uint256 _amount) public onlyOwnerMinter {
        _burn(_account, _amount);
    }
}
