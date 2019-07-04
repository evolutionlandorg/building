pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol";
import "@evolutionland/common/contracts/interfaces/IObjectOwnership.sol";
import "@evolutionland/common/contracts/PausableDSAuth.sol";
import "openzeppelin-solidity/contracts/introspection/SupportsInterfaceWithLookup.sol";
import "./BuildingSettingIds.sol";
import "./interfaces/ITokenLocation.sol";

contract StreetBlockBase is PausableDSAuth, BuildingSettingIds {

    event Created(
        address indexed owner, uint256 streetBlockTokenId, uint256 createTime
    );

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

    uint128 public lastStreetBlockObjectId;

    ISettingsRegistry public registry;

    mapping(uint256 => uint256[])   public landsInStreetBlock;

    mapping(uint256 => uint256)     public land2StreetBlock;

    function initializeContract(address _registry) public singletonLockCall {
        // Ownable constructor
        owner = msg.sender;
        emit LogSetOwner(msg.sender);

        registry = ISettingsRegistry(_registry);
    }

    function createStreetBlockFromLand(
        uint256 _landTokenId) public auth returns (uint256) {

        // TODO: Iterate the locations and insert to the new create BlockStreet.
        // TODO: Validate there is no conflict: each land can only appear in one Street Block.
        // TODO: Other rule checks: continuous coordinate etc.
        ERC721 ownership = ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP));

        address owner = ownership.ownerOf(_landTokenId);

        // TODO: require approve
        ownership.transferFrom(owner, address(this), _landTokenId);

        lastStreetBlockObjectId += 1;
        require(lastStreetBlockObjectId <= 340282366920938463463374607431768211455, "Can not be stored with 128 bits.");
        uint256 tokenId = IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).mintObject(owner, uint128(lastStreetBlockObjectId));

        landsInStreetBlock[tokenId].push(_landTokenId);

        emit Created(owner, tokenId, now);

        return tokenId;
    }

    function createStreetBlock(
        int256 _x1, int256 _y1, int256 _width) public auth returns (uint256) {

        require(_width > 0 && _width < 4, "Invalid street block _width!");

        ITokenLocation landBase = ITokenLocation(registry.addressOf(CONTRACT_LAND_BASE));

        ERC721 ownership = ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP));
        
        // uint[] memory landTokens = new uint[](_width * _width);

        address owner;
        for (int i = 0; i < _width; i++) {
            for (int j = 0; j < _width; j++) {
                uint landTokenId = landBase.getTokenIdByLocation(_x1 + i, _y1 + j);

                if (i == 0 && j == 0) {
                    owner = ownership.ownerOf(landTokenId);
                } else {
                    require(ownership.ownerOf(landTokenId) == owner, "Not the same owner");
                }

                // TODO: require approve
                ownership.transferFrom(owner, address(this), landTokenId);
                landsInStreetBlock[tokenId].push(landTokenId);
            }
        }

        // TODO: Iterate the locations and insert to the new create BlockStreet.
        // TODO: Validate there is no conflict: each land can only appear in one Street Block.
        // TODO: Other rule checks: continuous coordinate etc.

        lastStreetBlockObjectId += 1;
        require(lastStreetBlockObjectId <= 340282366920938463463374607431768211455, "Can not be stored with 128 bits.");

        uint256 tokenId = IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).mintObject(owner, uint128(lastStreetBlockObjectId));

        emit Created(owner, tokenId, now);

        return tokenId;
    }

}

