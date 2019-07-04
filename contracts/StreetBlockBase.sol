pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol";
import "@evolutionland/common/contracts/interfaces/IObjectOwnership.sol";
import "@evolutionland/common/contracts/PausableDSAuth.sol";
import "openzeppelin-solidity/contracts/introspection/SupportsInterfaceWithLookup.sol";

contract StreetBlockBase is PausableDSAuth, BuildingSettingIds {

    event Created(
        address indexed owner, uint256 streetBlockTokenId, uint256 _landTokenId, uint256 createTime
    );

    mapping(uint256 => uint256[])   public landsInStreetBlock;

    mapping(uint256 => uint256)     public land2StreetBlock;

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

    mapping(uint256 => StreetBlock) public tokenId2StreetBlock;

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

            lastStreetBlockObjectId += 1;
            require(lastStreetBlockObjectId <= 340282366920938463463374607431768211455, "Can not be stored with 128 bits.");
            uint256 tokenId = IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).mintObject(_owner, uint128(lastStreetBlockObjectId));

            landsInStreetBlock[tokenId].push(_landTokenId);

            emit Created(_owner, tokenId, _landTokenId, _width, now);

            return tokenId;
     }

    function createStreetBlock(
        uint256 _x1, uint256 _y1, uint256 _width) public auth returns (uint256) {

        // TODO: Iterate the locations and insert to the new create BlockStreet.
        // TODO: Validate there is no conflict: each land can only appear in one Street Block.
        // TODO: Other rule checks: continuous coordinate etc.

        lastStreetBlockObjectId += 1;
        require(lastStreetBlockObjectId <= 340282366920938463463374607431768211455, "Can not be stored with 128 bits.");
        uint256 tokenId = IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).mintObject(_owner, uint128(lastStreetBlockObjectId));

        // landsInStreetBlock[tokenId] = uint256[]();

        //emit Created(_owner, tokenId, _x1, _y1, _width, now);

        return tokenId;
    }

}

