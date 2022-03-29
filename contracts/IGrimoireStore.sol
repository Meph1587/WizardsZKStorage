//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;
pragma experimental ABIEncoderV2;

interface IGrimoireStore {
    function hasTraitsStored(uint256) external view returns (bool);

    function getWizardToName(uint256) external view returns (string memory);

    function getTraitsToAffinities(uint16)
        external
        view
        returns (uint16[] memory);

    function getTraitsToIdentity(uint16)
        external
        view
        returns (uint16[] memory);

    function getTraitsToPositive(uint16)
        external
        view
        returns (uint16[] memory);

    function getWizardTraitsEncoded(uint256 id)
        external
        view
        returns (bytes memory);
}
