// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/Strings.sol";
import "./IFactoryERC721.sol";
import "./Creature.sol";

contract CreatureFactory is FactoryERC721, Ownable {
    using Strings for string;

    // 0x255000255000255000255000255
    // 0x255255255255255255255255255
    // 0xA110000A110000A110000A1100000001
    // 0xtile1  tile2  tile3  tile4  EmojiIndex (last 4 hex digits)
    // tile# => 7 hex digits

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
    string public BASE_URI = "http://34.150.230.209/api/sales/get/";
    uint256 MAX_TOKEN_SUPPLY = 5;
    uint256 NUM_SALE_OPTIONS = 1;

    constructor(address _proxyRegistryAddress, address _nftAddress) {
        proxyRegistryAddress = _proxyRegistryAddress;
        nftAddress = _nftAddress;
        fireTransferEvents(address(0), owner());
    }

    function name() override external pure returns (string memory) {
        return "TILE NFT Item Sale";
    }

    function symbol() override external pure returns (string memory) {
        return "SALE-TILE";
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
        Creature openSeaCreature = Creature(nftAddress);
        uint256 nextTokenId = openSeaCreature._getNextTokenId();
        require(canMint(_optionId));
        openSeaCreature.mintTo(_toAddress);
        emit Mint(nextTokenId);
    }

    function canMint(uint256 _optionId) override public view returns (bool) {
        if (_optionId >= getSaleOptionsTotal()) {
            return false;
        }
        Creature openSeaCreature = Creature(nftAddress);
        uint256 creatureSupply = openSeaCreature.totalSupply();
        return creatureSupply < (getTokenMaxSupply() - 1);
    }

    function tokenURI(uint256 _optionId) override external view returns (string memory) {
        return string(abi.encodePacked(BASE_URI, Strings.toString(_optionId)));
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
