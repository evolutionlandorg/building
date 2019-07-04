pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol";
import "@evolutionland/common/contracts/interfaces/IObjectOwnership.sol";
import "@evolutionland/common/contracts/PausableDSAuth.sol";
import "openzeppelin-solidity/contracts/introspection/SupportsInterfaceWithLookup.sol";

contract BuildingBase is PausableDSAuth, BuildingSettingIds {

    event Created(
        address indexed owner, uint256 buildingMapTokenId, uint256 _gold, uint256 _wood, uint256 _water, uint256 _fire, uint256 _sioo, uint256 createTime
    );

    struct Building {
        uint256 buildingMapId;
        uint256 streetBlockId;

        uint256 gold;
        uint256 wood;
        uint256 water;
        uint256 fire;
        uint256 sioo;
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

    function createBuilding(
        uint256 _buildingMapId, uint256 _streetBlockId, uint256 _gold, uint256 _wood, uint256 _water, uint256 _fire, uint256 _sioo) public auth returns (uint256) {

        // TODO: validate msg.sender
        // TODO: Charge resources.

        Building memory building = Building({
            buildingMapId : _buildingMapId,
            streetBlockId : _streetBlockId,
            gold : _gold,
            wood : _wood,
            water : _water,
            fire : _fire,
            sioo : _sioo
        });

        lastBuildingObjectId += 1;
        require(lastBuildingMapObjectId <= 340282366920938463463374607431768211455, "Can not be stored with 128 bits.");
        uint256 tokenId = IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).mintObject(_owner, uint128(lastBuildingObjectId));

        tokenId2Building[tokenId] = building;

        emit Created(_owner, tokenId, _buildingMapId, _streetBlockId, _gold, _wood, _water, _fire, _sioo, now);

        return tokenId;
    }

}

