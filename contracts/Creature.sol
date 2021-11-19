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
        uint256 indexed index,
        uint256 indexed rgbValue
    );

    event EmojiSet(
        uint256 indexed tokenId,
        uint256 indexed index,
        uint256 indexed unicodeValue
    );

    constructor(address _proxyRegistryAddress)
        ERC721Tradable("Creature", "OSC", _proxyRegistryAddress)
    {}

    function baseTokenURI() override public pure returns (string memory) {
        return "http://34.150.230.209/api/tiles/get/";
    }

    function contractURI() public pure returns (string memory) {
        return "http://34.150.230.209/api/contract/get";
    }

    function setColor() public onlyOwner {
        uint256 tokenId = 1;
        uint256 index = 2;
        uint256 rgbValue = 3;
        emit ColorSet(tokenId, index, rgbValue);
    }

    function setEmoji() public onlyOwner {
        uint256 tokenId = 1;
        uint256 index = 2;
        uint256 rgbValue = 3;
        emit EmojiSet(tokenId, index, unicodeValue);
    }

}
