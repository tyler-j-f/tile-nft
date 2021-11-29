// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Tradable.sol";

/**
 * @title Creature
 * Creature - a contract for my non-fungible creatures.
 */
contract Creature is ERC721Tradable {

    event MergeMint(
        uint256 indexed burnedTokenId1,
        uint256 indexed burnedTokenId2,
        uint256 indexed newTokenId
    );

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
        if (ERC721.ownerOf(tokenId) == _msgSender()) {
            emit ColorSet(tokenId, rgbValue);
        }
    }

    function setEmojis(uint256 tokenId,  bytes32 unicodeValue) public {
        if (ERC721.ownerOf(tokenId) == _msgSender()) {
            emit EmojiSet(tokenId, unicodeValue);
        }
    }

    function merge(uint256 tokenId1,  uint256 tokenId2) public {
        address sender = _msgSender();
        require(ERC721.ownerOf(tokenId1) == sender && ERC721.ownerOf(tokenId2) == sender);
        uint256 newTokenId = _getNextTokenId();
        _incrementTokenIdForMerge(tokenId1, tokenId2);
        _burn(tokenId1);
        _burn(tokenId2);
        _mint(sender, newTokenId);
        emit MergeMint(tokenId1, tokenId2, newTokenId);
    }

}
