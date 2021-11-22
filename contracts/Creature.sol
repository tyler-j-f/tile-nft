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
        uint256 indexed rgbValue
    );

    event EmojiSet(
        uint256 indexed tokenId,
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

    function setColors(uint256 tokenId,  uint256 rgbValue) public {
        if (ERC721.ownerOf(tokenId) == _msgSender()) {
            emit ColorSet(tokenId, rgbValue);
        }
    }

    function setEmojis(uint256 tokenId,  uint256 unicodeValue) public {
        if (ERC721.ownerOf(tokenId) == _msgSender()) {
            emit EmojiSet(tokenId, unicodeValue);
        }
    }

    function merge(uint256 tokenId1,  uint256 tokenId2) public {
        address sender = _msgSender();
        require(ERC721.ownerOf(tokenId1) == sender && ERC721.ownerOf(tokenId2) == sender);
        emit Transfer(sender, address(0), tokenId1);
        emit Transfer(sender, address(0), tokenId2);
        mintTo(sender);
        uint256 newTokenId = ERC721Enumerable.totalSupply();
        emit Transfer(address(0), sender, newTokenId);
    }

}
