// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Tradable.sol";

/**
 * @title TileNFT
 * TileNFT - a contract for my non-fungible tileNFTs.
 */
contract Tile is ERC721Tradable {

    event MergeMint(
        uint256 indexed burnedTokenId1,
        uint256 indexed burnedTokenId2,
        uint256 indexed newTokenId
    );

    event MetadataSet(
        uint256 indexed tokenId,
        uint8 indexed dataToSetIndex,
        bytes32 indexed dataToSet
    );

    constructor(address _proxyRegistryAddress)
        ERC721Tradable("Tile Nft", "TileNft", _proxyRegistryAddress)
    {}

    function baseTokenURI() override public pure returns (string memory) {
        return "http://34.86.114.102/view/?tokenId=";
    }

    function contractURI() public pure returns (string memory) {
        return "http://34.86.114.102/api/contract/get";
    }

    function metadataSet(uint256 tokenId, uint8 dataToSetIndex, bytes32 dataToSet) public {
        if (ERC721.ownerOf(tokenId) == _msgSender()) {
            emit MetadataSet(tokenId, dataToSetIndex, dataToSet);
        }
    }

    function merge(uint256 tokenId1,  uint256 tokenId2) public {
        address sender = _msgSender();
        require(tokenId1 != tokenId2 && ERC721.ownerOf(tokenId1) == sender && ERC721.ownerOf(tokenId2) == sender);
        uint256 newTokenId = _getNextTokenId();
        _incrementTokenIdForMerge(tokenId1, tokenId2);
        _burn(tokenId1);
        _burn(tokenId2);
        _mint(sender, newTokenId);
        emit MergeMint(tokenId1, tokenId2, newTokenId);
    }

}
