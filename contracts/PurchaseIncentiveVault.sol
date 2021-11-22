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

    uint256 public currentRound;

    uint256 public currentDistributionIndex;

    uint256 public degisPerRound;
    uint256 public distributionInterval; // in blocks
    uint256 public lastDistribution;

    event OwnershipTransferred(address _oldOwner, address _newOwner);
    event ChangeDegisPerRound(uint256 _oldPerRound, uint256 _newPerRound);
    event ChangeDistributionInterval(
        uint256 _oldInterval,
        uint256 _newInterval
    );

    constructor(address _buyerToken, address _degisToken) {
        owner = msg.sender;
        buyerToken = IBuyerToken(_buyerToken);
        degis = IDegisToken(_degisToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier canStake() {
        require(
            block.number - lastDistribution <= distributionInterval,
            "Can not stake buyer token now, waiting for distribution"
        );
        _;
    }

    modifier canDistribute() {
        require(
            block.number - lastDistribution > distributionInterval,
            "Two distributions need to have an interval "
        );
        _;
    }

    /**
     * @notice Check if users can stake buyer tokens now
     * @dev Used for frontend
     * @return ifCanStake Whether users can stake now
     */
    function checkIfCanStake() external view returns (bool) {
        if (block.number - lastDistribution <= distributionInterval)
            return true;
        else return false;
    }

    function transferOwnerShip(address _newOwner) external onlyOwner {
        address oldOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(oldOwner, _newOwner);
    }

    /**
     * @notice Set degis distribution per round
     * @param _degisPerRound Degis distribution per round to be set
     */
    function setDegisPerRound(uint256 _degisPerRound) external onlyOwner {
        uint256 oldPerRound = degisPerRound;
        degisPerRound = _degisPerRound;
        emit ChangeDegisPerRound(oldPerRound, _degisPerRound);
    }

    /**
     * @notice Set a new distribution interval
     * @param _newInterval The new interval
     */
    function setDistributionInterval(uint256 _newInterval) external onlyOwner {
        uint256 oldInterval = distributionInterval;
        distributionInterval = _newInterval;
        emit ChangeDistributionInterval(oldInterval, _newInterval);
    }

    /**
     * @notice Stake buyer token into this contract
     * @param _amount Amount of buyer tokens to stake
     */
    function stakeBuyerToken(uint256 _amount) public canStake {
        require(
            buyerToken.balanceOf(msg.sender) > 0,
            "You do not have any buyer token to deposit"
        );

        buyerToken.burn(msg.sender, _amount);

        if (userSharesInRound[msg.sender][currentRound] == 0) {
            usersInRound[currentRound].push(msg.sender);
        }

        userSharesInRound[msg.sender][currentRound] += _amount;
        sharesInRound[currentRound] += _amount;
    }

    /**
     * @notice Distribute the reward in this round, the total number depends on the blocks during this period
     * @param _startIndex Distribution start index
     * @param _stopIndex Distribution stop index
     */
    function distributeReward(uint256 _startIndex, uint256 _stopIndex)
        public
        onlyOwner
        canDistribute
    {
        require(
            degisPerRound > 0,
            "Currently no Degis reward, please set degisPerRound first"
        );
        require(
            hasDistributed[currentRound] == false,
            "Current round has been distributed"
        );

        uint256 totalShares = sharesInRound[currentRound];
        uint256 degisPerShare = (degisPerRound / totalShares) * 1e18;

        // Distribute all at once (maybe not enough gas in one tx)
        if (_startIndex == 0 && _stopIndex == 0) {
            uint256 length = usersInRound[currentRound].length;
            _distributeReward(currentRound, 0, length, degisPerShare);
            currentDistributionIndex = length;
        }
        // Distribute in a certain range (need several times distribution)
        else {
            require(
                currentDistributionIndex == _startIndex,
                "You need to start from the last distribution point"
            );
            _distributeReward(
                currentRound,
                _startIndex,
                _stopIndex,
                degisPerShare
            );
            currentDistributionIndex = _stopIndex;
        }

        if (currentDistributionIndex == usersInRound[currentRound].length) {
            _finishDistribution();
        }
    }

    /**
     * @notice Finish the distribution process
     * @param _round Distribution round
     * @param _startIndex Start index
     * @param _stopIndex Stop index
     * @param _degisPerShare Amount of degis per share
     */
    function _distributeReward(
        uint256 _round,
        uint256 _startIndex,
        uint256 _stopIndex,
        uint256 _degisPerShare
    ) internal {
        for (uint256 i = _startIndex; i < _stopIndex; i++) {
            address userAddress = usersInRound[_round][i];
            uint256 userShares = userSharesInRound[userAddress][_round];

            if (userShares != 0) {
                degis.mint(userAddress, userShares * _degisPerShare);
                delete userSharesInRound[userAddress][_round];
            } else continue;
        }
    }

    /**
     * @notice You can claim your own reward if you want
     * @dev Can claim reward of the previous rounds
     * @param _round Which round to claim
     */
    function claimReward(uint256 _round) external {
        uint256 userShares = userSharesInRound[msg.sender][_round];

        require(userShares > 0, "You do not have enough degis in this round");

        uint256 totalShares = sharesInRound[_round];
        uint256 degisPerShare = (degisPerRound / totalShares) * 1e18;

        degis.mint(msg.sender, userShares * degisPerShare);

        delete userSharesInRound[msg.sender][_round];
    }

    /**
     * @notice Finish the distribution process and move to next round
     */
    function _finishDistribution() internal {
        currentDistributionIndex = 0;
        hasDistributed[currentRound] = true;
        currentRound += 1;
        lastDistribution = block.number;
    }
}
