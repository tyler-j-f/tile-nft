// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/Strings.sol";
import "./IFactoryERC721.sol";
import "./Tile.sol";

contract TileFactory is FactoryERC721, Ownable {
    using Strings for string;

    /*
    * EVENTS
    */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Mint(
        uint256 indexed tokenId
    );

    /*
    * STORAGE
    */
    address public proxyRegistryAddress;
    address public nftAddress;

    /*
    * CONSTANTS
    */
    uint256 MAX_TOKEN_SUPPLY = 10000;
    uint256 NUM_SALE_OPTIONS = 1;

    constructor(address _proxyRegistryAddress, address _nftAddress) {
        proxyRegistryAddress = _proxyRegistryAddress;
        nftAddress = _nftAddress;
        fireTransferEvents(address(0), owner());
    }

    function name() override external pure returns (string memory) {
        return "TileNFT Sale";
    }

    function symbol() override external pure returns (string memory) {
        return "TileNftSale";
    }

    function supportsFactoryInterface() override public pure returns (bool) {
        return true;
    }

    function numOptions() override public view returns (uint256) {
        return getSaleOptionsTotal();
    }

    function transferOwnership(address newOwner) override public onlyOwner {
        address _prevOwner = owner();
        super.transferOwnership(newOwner);
        fireTransferEvents(_prevOwner, newOwner);
    }

    function fireTransferEvents(address _from, address _to) private {
        for (uint256 i = 0; i < numOptions(); i++) {
            emit Transfer(_from, _to, i);
        }
    }

    function mint(uint256 _optionId, address _toAddress) override public {
        // Must be sent from the owner proxy or owner.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        assert(
            address(proxyRegistry.proxies(owner())) == _msgSender() ||
                owner() == _msgSender()
        );
        require(canMint(_optionId));
        Tile tileContract = Tile(nftAddress);
        uint256 nextTokenId = tileContract._getNextTokenId();
        tileContract.mintTo(_toAddress);
        emit Mint(nextTokenId);
    }

    function canMint(uint256 _optionId) override public view returns (bool) {
        if (_optionId >= getSaleOptionsTotal()) {
            return false;
        }
        Tile tileContract = Tile(nftAddress);
        return tileContract.totalSupply() <= (getTokenMaxSupply() - 1);
    }

    function tokenURI(uint256 _optionId) override external view returns (string memory) {
        Tile tileContract = Tile(nftAddress);
        return string(abi.encodePacked(tileContract.baseMetadataURI(), "/api/sales/get/", Strings.toString(_optionId)));
    }

    /**
     * Hack to get things to work automatically on OpenSea.
     * Use transferFrom so the frontend doesn't have to worry about different method names.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public {
        mint(_tokenId, _to);
    }

    /**
     * Hack to get things to work automatically on OpenSea.
     * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
     */
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        returns (bool)
    {
        if (owner() == _owner && _owner == _operator) {
            return true;
        }

        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (
            owner() == _owner &&
            address(proxyRegistry.proxies(_owner)) == _operator
        ) {
            return true;
        }

        return false;
    }

    /**
     * Hack to get things to work automatically on OpenSea.
     * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
     */
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return owner();
    }

    /**
    * Get the max supply of each individual sale option.
    */
    function getTokenMaxSupply() private view returns (uint256) {
        return MAX_TOKEN_SUPPLY;
    }

    /**
    * Get the max supply of each individual sale option.
    */
    function getSaleOptionsTotal() private view returns (uint256) {
        return NUM_SALE_OPTIONS;
    }

}
