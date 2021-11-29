// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Tradable.sol";

/**
 * @title Creature
 * Creature - a contract for my non-fungible creatures.
 */
contract Creature is ERC721Tradable {

    event ColorSet(
        uint256 indexed tokenId,
        bytes32 indexed rgbValue
    );

    event EmojiSet(
        uint256 indexed tokenId,
        bytes32 indexed unicodeValue
    );

    constructor(address _proxyRegistryAddress)
        ERC721Tradable("Tile", "TILE", _proxyRegistryAddress)
    {}

    function baseTokenURI() override public pure returns (string memory) {
        return "http://34.150.230.209/api/tiles/get/";
    }

    function contractURI() public pure returns (string memory) {
        return "http://34.150.230.209/api/contract/get";
    }

    function setColors(uint256 tokenId,  bytes32 rgbValue) public {
        require(ERC721.ownerOf(tokenId) == _msgSender());
        emit ColorSet(tokenId, rgbValue);
    }

    function setEmojis(uint256 tokenId,  bytes32 unicodeValue) public {
        require(ERC721.ownerOf(tokenId) == _msgSender());
        emit EmojiSet(tokenId, unicodeValue);
    }


    function burn(uint256 tokenId) public {
        require(ERC721.ownerOf(tokenId) == _msgSender());
        _burn(tokenId);
    }

}
