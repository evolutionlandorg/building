pragma solidity ^0.4.24;

contract ITokenLocation {
    function getTokenIdByLocation(int _x, int _y) public view returns (uint256);
}
