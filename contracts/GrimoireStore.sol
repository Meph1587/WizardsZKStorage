//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./IGrimoireStore.sol";

contract GrimoireStore is IGrimoireStore {
    mapping(uint256 => bool) public hasTraitsStored;

    address public storageMaster;
    bytes32 public merkleRootTraitsTree;
    bytes32 public merkleRootNamesTree;

    mapping(uint256 => bytes) private wizardToTraits;
    mapping(uint256 => string) private wizardToName;
    mapping(uint16 => uint16[]) private traitsToAffinities;
    mapping(uint16 => uint16[]) private traitsToIdentity;
    mapping(uint16 => uint16[]) private traitsToPositive;

    bool public canStoreAffinities = true;

    event StoredTrait(uint256 wizardId, string name, bytes encodedTraits);

    constructor(bytes32 _rootTraits, bytes32 _rootNames) {
        storageMaster = msg.sender;
        merkleRootTraitsTree = _rootTraits;
        merkleRootNamesTree = _rootNames;
    }

    // Store traits for a list of Wizards
    function storeWizardTraits(
        uint256 wizardId,
        string calldata name,
        uint16[] calldata traits,
        bytes32[] calldata proofsName,
        bytes32[] calldata proofsTraits
    ) public {
        require(traits.length == 7, "Invalid Length");
        require(traits[0] == wizardId, "WizardsId to Trait mismatch");
        require(!hasTraitsStored[wizardId], "Traits are already stored");

        require(
            _verifyName(proofsName, wizardId, name),
            "Merkle Proof for name is invalid!"
        );

        bytes memory encodedTraits = _encode(
            traits[0],
            traits[1],
            traits[2],
            traits[3],
            traits[4],
            traits[5],
            traits[6]
        );
        require(
            _verifyEncodedTraits(proofsTraits, encodedTraits),
            "Merkle Proof for traits is invalid!"
        );

        wizardToName[wizardId] = name;
        wizardToTraits[wizardId] = encodedTraits;
        hasTraitsStored[wizardId] = true;

        emit StoredTrait(wizardId, name, encodedTraits);
    }

    // Store related affinities for a list of traits
    function storeTraitAffinities(
        uint16[] calldata traits,
        uint16[][] calldata affinities,
        uint16[][] calldata identity,
        uint16[][] calldata positive
    ) public {
        require(canStoreAffinities, "Storing is over");
        require(msg.sender == storageMaster, "Not Storage Master");
        for (uint256 i = 0; i < traits.length; i++) {
            traitsToAffinities[traits[i]] = affinities[i];
            traitsToIdentity[traits[i]] = identity[i];
            traitsToPositive[traits[i]] = positive[i];
        }
    }

    function stopStoring() public {
        require(canStoreAffinities, "Store is already over");
        require(msg.sender == storageMaster, "Not Storage Master");
        canStoreAffinities = false;
    }

    /**
        VIEWS
     */

    function getWizardToName(uint256 id) external view returns (string memory) {
        return wizardToName[id];
    }

    function getTraitsToAffinities(uint16 id)
        external
        view
        returns (uint16[] memory)
    {
        return traitsToAffinities[id];
    }

    function getTraitsToIdentity(uint16 id)
        external
        view
        returns (uint16[] memory)
    {
        return traitsToIdentity[id];
    }

    function getTraitsToPositive(uint16 id)
        external
        view
        returns (uint16[] memory)
    {
        return traitsToPositive[id];
    }

    function getWizardTraitsEncoded(uint256 id)
        external
        view
        returns (bytes memory)
    {
        return wizardToTraits[id];
    }

    /**
        INTERNAL
     */

    function _verifyName(
        bytes32[] memory proof,
        uint256 wizardId,
        string memory name
    ) internal view returns (bool) {
        return
            MerkleProof.verify(
                proof,
                merkleRootNamesTree,
                keccak256(abi.encode(wizardId, name))
            );
    }

    function _verifyEncodedTraits(bytes32[] memory proof, bytes memory traits)
        internal
        view
        returns (bool)
    {
        bytes32 hashedTraits = keccak256(abi.encodePacked(traits));
        return MerkleProof.verify(proof, merkleRootTraitsTree, hashedTraits);
    }

    function _encode(
        uint16 id,
        uint16 t0,
        uint16 t1,
        uint16 t2,
        uint16 t3,
        uint16 t4,
        uint16 t5
    ) internal pure returns (bytes memory) {
        bytes memory data = new bytes(16);

        assembly {
            mstore(add(data, 32), 32)

            mstore(add(data, 34), shl(240, id))
            mstore(add(data, 36), shl(240, t0))
            mstore(add(data, 38), shl(240, t1))
            mstore(add(data, 40), shl(240, t2))
            mstore(add(data, 42), shl(240, t3))
            mstore(add(data, 44), shl(240, t4))
            mstore(add(data, 46), shl(240, t5))
        }

        return data;
    }
}
