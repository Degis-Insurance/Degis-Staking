// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
import "./interfaces/IBuyerToken.sol";
import "./interfaces/IDegisToken.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract PurchaseIncentiveVault {
    using SafeERC20 for IBuyerToken;

    address public owner;

    IBuyerToken buyerToken;
    IDegisToken degis;

    mapping(uint256 => uint256) sharesInRound;

    mapping(uint256 => address[]) usersInRound;

    mapping(uint256 => bool) hasDistributed;

    mapping(address => mapping(uint256 => uint256)) userSharesInRound;
    mapping(address => uint256) userRewards;

    uint256 public round;

    uint256 public degisPerRound;
    uint256 public distributeInterval; // in blocks
    uint256 public lastDistribution;

    event ChangeDegisPerRound(uint256 _oldPerRound, uint256 _newPerRound);
    event ChangeDistributeInterval(uint256 _oldInterval, uint256 _newInterval);

    constructor(address _buyerToken, address _degisToken) {
        owner = msg.sender;
        buyerToken = IBuyerToken(_buyerToken);
        degis = IDegisToken(_degisToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function setDegisPerRound(uint256 _degisPerRound) external onlyOwner {
        uint256 oldPerRound = degisPerRound;
        degisPerRound = _degisPerRound;
        emit ChangeDegisPerRound(oldPerRound, _degisPerRound);
    }

    function setDistributeInterval(uint256 _newInterval) external onlyOwner {
        uint256 oldInterval = distributeInterval;
        distributeInterval = _newInterval;
        emit ChangeDistributeInterval(oldInterval, _newInterval);
    }

    function stakeBuyerToken(uint256 _amount) public {
        require(
            buyerToken.balanceOf(msg.sender) > 0,
            "You do not have any buyer token to deposit"
        );

        // buyerToken.safeTransferFrom(msg.sender, address(this), _amount);
        buyerToken.burn(msg.sender, _amount);

        if (userSharesInRound[msg.sender][round] == 0) {
            usersInRound[round].push(msg.sender);
        }

        userSharesInRound[msg.sender][round] += _amount;
        sharesInRound[round] += _amount;
    }

    function distributeReward() public onlyOwner {
        require(
            hasDistributed[round] == false,
            "Current round has been distributed"
        );
        require(
            block.number - lastDistribution >= distributeInterval,
            "Two distribution need to have an interval "
        );

        uint256 totalShares = sharesInRound[round];

        for (uint256 i = 0; i < 20; i++) {
            address user = usersInRound[round][i];
            uint256 amount = userSharesInRound[round];

            degis.mint(user, amount);
        }

        lastDistribution = block.number;
        round += 1;
        hasDistributed[round] = true;
    }

    function claimReward(uint256 _amount) external {
        require(userShares);
    }
}
