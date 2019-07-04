pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol";
import "@evolutionland/common/contracts/interfaces/IObjectOwnership.sol";
import "@evolutionland/common/contracts/PausableDSAuth.sol";
import "openzeppelin-solidity/contracts/introspection/SupportsInterfaceWithLookup.sol";

contract BuildingBase is PausableDSAuth, BuildingSettingIds {

    event Created(
        address indexed owner, uint256 buildingMapTokenId, uint256 createTime
    );

    struct Building {
        uint256 buildingMapId;
        uint256 streetBlockId;
    }

    /*
     *  Modifiers
     */
    modifier singletonLockCall() {
        require(!singletonLock, "Only can call once");
        _;

        singletonLock = true;
    }


    /*** STORAGE ***/
    bool private singletonLock = false;

    uint128 public lastBuildingObjectId;

    ISettingsRegistry public registry;

    mapping(uint256 => Building) public tokenId2Building;

    function initializeContract(address _registry) public singletonLockCall {
        // Ownable constructor
        owner = msg.sender;
        emit LogSetOwner(msg.sender);

        registry = ISettingsRegistry(_registry);
    }

    function createBuildingFromLand(uint256 _buildingMapId, uint256 _landTokenId)  public auth returns (uint256) {
        uint256 streetBlockId = createBuildingBlock(_landTokenId);

        uint256 tokenId = createBuilding(_buildingMapId, streetBlockId);
        return tokenId;
    }

    function createBuilding(
        uint256 _buildingMapId, uint256 _streetBlockId) public auth returns (uint256) {

        // TODO: validate msg.sender
        // TODO: Charge resources.

        Building memory building = Building({
            buildingMapId : _buildingMapId,
            streetBlockId : _streetBlockId
        });

        lastBuildingObjectId += 1;
        require(lastBuildingMapObjectId <= 340282366920938463463374607431768211455, "Can not be stored with 128 bits.");
        uint256 tokenId = IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).mintObject(_owner, uint128(lastBuildingObjectId));

        tokenId2Building[tokenId] = building;

        emit Created(_owner, tokenId, _buildingMapId, _streetBlockId, now);

        return tokenId;
    }

    // TODO upgradebuilding

}

