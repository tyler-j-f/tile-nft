// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/Strings.sol";
import "./IFactoryERC721.sol";
import "./Creature.sol";

contract CreatureFactory is FactoryERC721, Ownable {
    using Strings for string;

    /*
    * EVENTS
    */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /*
    * TODO: Do we need both the tokenId and the toAddress?
    * Clients could likely just use the tokenId and query the NFTContractAddress for the toAddress
    */
    event Mint(
        uint256 indexed tokenId
    );

    /*
    * STORAGE
    */
    /*
    * Mapping from a sale _optionId to the total number of tokens minted by that sale option.
    * TODO: Based on the final number of sale options and max token supply, we can probably change the uint size.
    */
    mapping(uint256 => uint256) private _mintedTokens;
    address public proxyRegistryAddress;
    address public nftAddress;

    /*
    * CONSTANTS
    */
    string public BASE_URI = "http://34.150.230.209/api/sales/get/";
    uint256 NUM_SUBTILES = 4;
    uint256 NUM_SUBTILE_COLORS = 2;
    uint256 NUM_SUBTILE_SHAPES = 1;

    uint256 NUM_TILES_PER_SALE_OPTION = 5;

    constructor(address _proxyRegistryAddress, address _nftAddress) {
        proxyRegistryAddress = _proxyRegistryAddress;
        nftAddress = _nftAddress;
        fireTransferEvents(address(0), owner());
    }

    function name() override external pure returns (string memory) {
        return "OpenSeaCreature Item Sale";
    }

    function symbol() override external pure returns (string memory) {
        return "CPF";
    }

    function supportsFactoryInterface() override public pure returns (bool) {
        return true;
    }

    function numOptions() override public view returns (uint256) {
        return NUM_SUBTILES * NUM_SUBTILE_COLORS * NUM_SUBTILE_SHAPES;
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
        Creature openSeaCreature = Creature(nftAddress);
        openSeaCreature.mintTo(_toAddress);
        uint256 numMintedTokensPerSale = _mintedTokens[_optionId];
        numMintedTokensPerSale++;
        _mintedTokens[_optionId] = numMintedTokensPerSale;
        emit Mint(_mintedTokens[_optionId]);
    }

    function canMint(uint256 _optionId) override public view returns (bool) {
        if (_optionId >= numOptions()) {
            return false;
        }
        Creature openSeaCreature = Creature(nftAddress);
        uint256 currentCreatureSupply = openSeaCreature.totalSupply();
        return _mintedTokens[_optionId] < getSaleOptionMaxSupply();
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
    function getSaleOptionMaxSupply() private view returns (uint256) {
        return NUM_TILES_PER_SALE_OPTION;
    }

}
