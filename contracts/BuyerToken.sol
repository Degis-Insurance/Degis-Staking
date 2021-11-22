// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IBuyerToken.sol";

/**
 * @title  Buyer Token
 * @notice Buyer tokens are distributed to buyers corresponding to the usd value they spend
 */

contract BuyerToken is ERC20("DegisBuyerToken", "DBT"), IBuyerToken {
    address public owner;

    address[] public minterList;
    mapping(address => bool) isMinter;

    address[] public burnerList;
    mapping(address => bool) isBurner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Check if the msg.sender is in the minter list
    modifier inMinterList(address _sender) {
        require(
            isMinter[_sender] == true,
            "Only the address in the minter list can call this function"
        );
        _;
    }

    // Check if the msg.sender is in the burner list
    modifier inBurnerList(address _sender) {
        require(
            isBurner[_sender] == true,
            "Only the address in the minter list can call this function"
        );
        _;
    }

    /**
     * @notice Add a new minter into the list
     * @param _newMinter Address of the new minter
     */
    function addMinter(address _newMinter) public onlyOwner {
        require(
            isMinter[_newMinter] == false,
            "This address is already a minter"
        );
        minterList.push(_newMinter);

        emit MinterAdded(_newMinter);
    }

    /**
     * @notice Remove a minter from the list
     * @param _oldMinter Address of the minter to be removed
     */
    function removeMinter(address _oldMinter) public onlyOwner {
        require(isMinter[_oldMinter] == true, "This address is not a minter");

        uint256 length = minterList.length;
        for (uint256 i = 0; i < length; i++) {
            if (minterList[i] == _oldMinter) {
                for (uint256 j = i; j < length - 1; j++) {
                    minterList[j] = minterList[j + 1];
                }
                minterList.pop();
            } else continue;
        }

        emit MinterRemoved(_oldMinter);
    }

    /**
     * @notice Add a new burner into the list
     * @param _newBurner Address of the new burner
     */
    function addBurner(address _newBurner) public onlyOwner {
        require(
            isBurner[_newBurner] == false,
            "This address is already a burner"
        );
        burnerList.push(_newBurner);

        emit BurnerAdded(_newBurner);
    }

    /**
     * @notice Remove a minter from the list
     * @param _oldBurner Address of the minter to be removed
     */
    function removeBurner(address _oldBurner) public onlyOwner {
        require(isMinter[_oldBurner] == true, "This address is not a burner");

        uint256 length = burnerList.length;
        for (uint256 i = 0; i < length; i++) {
            if (burnerList[i] == _oldBurner) {
                for (uint256 j = i; j < length - 1; j++) {
                    burnerList[j] = burnerList[j + 1];
                }
                burnerList.pop();
            } else continue;
        }

        emit BurnerRemoved(_oldBurner);
    }

    /**
     * @notice Pass the owner role to a new address, only the owner can change the owner
     * @param _newOwner New owner's address
     */
    function passOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnerChanged(msg.sender, _newOwner);
    }

    /**
     * @notice Release the ownership to zero address, can never get back !
     */
    function releaseOwnership() public onlyOwner {
        owner = address(0);
        emit ReleaseOwnership(msg.sender);
    }

    function mint(address _account, uint256 _amount)
        public
        inMinterList(msg.sender)
    {
        _mint(_account, _amount);
    }

    function burn(address _account, uint256 _amount)
        public
        inBurnerList(msg.sender)
    {
        _burn(_account, _amount);
    }
}
