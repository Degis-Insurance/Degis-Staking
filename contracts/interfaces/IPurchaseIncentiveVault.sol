// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IPurchaseIncentiveVault {
    // ---------------------------------------------------------------------------------------- //
    // ************************************* Events ******************************************* //
    // ---------------------------------------------------------------------------------------- //
    event OwnershipTransferred(address _oldOwner, address _newOwner);
    event ChangeDegisPerRound(uint256 _oldPerRound, uint256 _newPerRound);
    event ChangeDistributionInterval(
        uint256 _oldInterval,
        uint256 _newInterval
    );

    // ---------------------------------------------------------------------------------------- //
    // ************************************** Functions *************************************** //
    // ---------------------------------------------------------------------------------------- //
    function owner() external view returns (address);

    function currentRound() external view returns (uint256);

    function currentDistributionIndex() external view returns (uint256);

    function degisPerRound() external view returns (uint256);

    function distributionInterval() external view returns (uint256);

    function lastDistribution() external view returns (uint256);

    function stakeBuyerToken(uint256 _amount) external;

    function distributeReward(uint256 _startIndex, uint256 _stopIndex) external;
}
