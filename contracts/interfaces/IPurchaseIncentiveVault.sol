// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IPurchaseIncentiveVault {
    // ---------------------------------------------------------------------------------------- //
    // ************************************* Events ******************************************* //
    // ---------------------------------------------------------------------------------------- //
    event OwnerChanged(address _oldOwner, address _newOwner);
    event DegisPerRoundChanged(uint256 _oldPerRound, uint256 _newPerRound);
    event DistributionIntervalChanged(
        uint256 _oldInterval,
        uint256 _newInterval
    );
    event RewardClaimed(address _userAddress, uint256 _userReward);

    // ---------------------------------------------------------------------------------------- //
    // ************************************** Functions *************************************** //
    // ---------------------------------------------------------------------------------------- //
    function owner() external view returns (address);

    function currentRound() external view returns (uint256);

    function currentDistributionIndex() external view returns (uint256);

    function degisPerRound() external view returns (uint256);

    function distributionInterval() external view returns (uint256);

    function lastDistribution() external view returns (uint256);

    function pendingReward(address _userAddress)
        external
        view
        returns (uint256);

    function getTotalUsersInRound(uint256 _round)
        external
        view
        returns (uint256);

    function getUserShares(address _userAddress)
        external
        view
        returns (uint256);

    /**
     * @notice Transfer the ownership
     * @param _newOwner Address of the new owner
     */
    function passOwnership(address _newOwner) external;

    /**
     * @notice Set degis distribution per round
     * @param _degisPerRound Degis distribution per round to be set
     */
    function setDegisPerRound(uint256 _degisPerRound) external;

    /**
     * @notice Set a new distribution interval
     * @param _newInterval The new interval
     */
    function setDistributionInterval(uint256 _newInterval) external;

    /**
     * @notice Stake buyer tokens into this contract
     * @param _amount Amount of buyer tokens to stake
     */
    function stake(uint256 _amount) external;

    /**
     * @notice Redeem buyer token from the vault
     * @param _amount Amount to redeem
     */
    function redeem(uint256 _amount) external;

    /**
     * @notice Distribute the reward in this round, the total number depends on the blocks during this period
     * @param _startIndex Distribution start index
     * @param _stopIndex Distribution stop index
     */
    function distributeReward(uint256 _startIndex, uint256 _stopIndex) external;
}
