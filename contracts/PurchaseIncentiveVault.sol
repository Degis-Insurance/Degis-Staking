// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
import "./interfaces/IBuyerToken.sol";
import "./interfaces/IDegisToken.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IPurchaseIncentiveVault.sol";

contract PurchaseIncentiveVault is IPurchaseIncentiveVault {
    using SafeERC20 for IBuyerToken;

    address public owner;

    IBuyerToken buyerToken;
    IDegisToken degis;

    mapping(uint256 => uint256) public sharesInRound;

    mapping(uint256 => address[]) public usersInRound;

    mapping(uint256 => bool) public hasDistributed;

    mapping(address => mapping(uint256 => uint256)) public userSharesInRound;
    mapping(address => uint256) public userRewards;

    uint256 public currentRound;

    uint256 public currentDistributionIndex;

    uint256 public degisPerRound;
    uint256 public distributionInterval; // in block numbers
    uint256 public lastDistribution; // in block numbers

    constructor(address _buyerToken, address _degisToken) {
        owner = msg.sender;
        buyerToken = IBuyerToken(_buyerToken);
        degis = IDegisToken(_degisToken);

        lastDistribution = block.number;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    /**
     * @notice Check if admins can distribute at this time, oppsite to "canStake"
     */
    modifier canDistribute() {
        require(
            block.number - lastDistribution > distributionInterval,
            "Two distributions need to have an interval "
        );
        _;
    }

    // ---------------------------------------------------------------------------------------- //
    // ************************************ View Functions ************************************ //
    // ---------------------------------------------------------------------------------------- //

    /**
     * @notice Check a user's pending reward
     * @param _userAddress Address of the user
     * @return userRewards Pending degis amount of this user
     */
    function pendingReward(address _userAddress) public view returns (uint256) {
        return userRewards[_userAddress];
    }

    /**
     * @notice Check if users can stake buyer tokens now
     * @dev Used for frontend
     *      If exceed the interval, can not deposit and need to wait for distribution
     * @return ifCanStake Whether users can stake now
     */
    function checkIfCanStake() external view returns (bool) {
        if (block.number - lastDistribution <= distributionInterval)
            return true;
        else return false;
    }

    /**
     * @notice Get the amount of users in _round, used for distribution
     * @param _round Round number to check
     * @return totalUsers Total amount of users in _round
     */
    function getTotalUsersInRound(uint256 _round)
        public
        view
        returns (uint256)
    {
        return usersInRound[_round].length;
    }

    /**
     * @notice Get your shares in the current round
     * @param _userAddress Address of the user
     */
    function getUserShares(address _userAddress) public view returns (uint256) {
        return userSharesInRound[_userAddress][currentRound];
    }

    // ---------------------------------------------------------------------------------------- //
    // ************************************ Set Functions ************************************* //
    // ---------------------------------------------------------------------------------------- //

    /**
     * @notice Transfer the ownership
     * @param _newOwner Address of the new owner
     */
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

    // ---------------------------------------------------------------------------------------- //
    // ************************************ Main Functions ************************************ //
    // ---------------------------------------------------------------------------------------- //

    /**
     * @notice Stake buyer token into this contract
     * @param _amount Amount of buyer tokens to stake
     */
    function stakeBuyerToken(uint256 _amount) public {
        require(
            buyerToken.balanceOf(msg.sender) > 0,
            "You do not have any buyer token to deposit"
        );

        if (userSharesInRound[msg.sender][currentRound] == 0) {
            usersInRound[currentRound].push(msg.sender);
        }

        buyerToken.safeTransferFrom(msg.sender, address(this), _amount);

        userSharesInRound[msg.sender][currentRound] += _amount;
        sharesInRound[currentRound] += _amount;
    }

    /**
     * @notice Redeem buyer token from the vault
     * @param _amount Amount to redeem
     */
    function redeemBuyerToken(uint256 _amount) public {
        uint256 userBalance = userSharesInRound[msg.sender][currentRound];
        require(userBalance >= _amount, "Not enough buyer tokens to redeem");

        userSharesInRound[msg.sender][currentRound] -= _amount;
        sharesInRound[currentRound] -= _amount;

        buyerToken.safeTransfer(msg.sender, _amount);

        if (userSharesInRound[msg.sender][currentRound] == 0) {
            delete userSharesInRound[msg.sender][currentRound];
        }
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
        uint256 degisPerShare = (degisPerRound * 1e18) / totalShares;

        uint256 length = getTotalUsersInRound(currentRound);

        // Distribute all at once (maybe not enough gas in one tx)
        if (_startIndex == 0 && _stopIndex == 0) {
            _distributeReward(currentRound, 0, length, degisPerShare);
            currentDistributionIndex = length;
        }
        // Distribute in a certain range (need several times distribution)
        else {
            // Check if you start from the last check point
            require(
                currentDistributionIndex == _startIndex,
                "You need to start from the last distribution point"
            );
            // Check if the stopindex exceeds the length
            _stopIndex = _stopIndex > length ? length : _stopIndex;

            if (_stopIndex != 0) {
                _distributeReward(
                    currentRound,
                    _startIndex,
                    _stopIndex,
                    degisPerShare
                );
            }

            currentDistributionIndex = _stopIndex;
        }

        if (currentDistributionIndex == usersInRound[currentRound].length) {
            _finishDistribution();
        }
    }

    // ---------------------------------------------------------------------------------------- //
    // *********************************** Internal Functions ********************************* //
    // ---------------------------------------------------------------------------------------- //

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

            buyerToken.burn(address(this), userShares);

            if (userShares != 0) {
                // degis.mint(userAddress, userShares * _degisPerShare);
                // Update the pending reward of a user
                userRewards[userAddress] +=
                    (userShares * _degisPerShare) /
                    1e18;
                delete userSharesInRound[userAddress][_round];
            } else continue;
        }
    }

    /**
     * @notice You can claim your own reward if you want
     * @dev Can claim reward of the previous rounds
     */
    function claimReward() external {
        uint256 reward = userRewards[msg.sender];

        require(reward > 0, "You do not have any rewards to claim");

        degis.mint(msg.sender, reward);

        delete userRewards[msg.sender];

        emit RewardClaimed(msg.sender, reward);
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
