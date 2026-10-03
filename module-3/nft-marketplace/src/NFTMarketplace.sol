// SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NFTMarketplace is ReentrancyGuard {

    struct Listing {
        address nftAddress;
        uint256 tokenId;
        address seller;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Listing)) public listing;

    event NFTListed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    event NFTCancelled(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);
    event NFTSold(address indexed buyer, address indexed seller, address indexed nftAddress, uint256 tokenId, uint256 price);

    constructor() {}

    // List NFTs
    function ListNFT(address nftAddress_, uint256 tokenId_, uint256 price_) external nonReentrant {
        require(price_ > 0, "Price cannot be 0.");
        address owner_ = IERC721(nftAddress_).ownerOf(tokenId_);
        require(owner_ == msg.sender, "You are not the owner of the NFT.");
        
        Listing memory listing_ = Listing({
            nftAddress: nftAddress_,
            tokenId: tokenId_,
            seller: msg.sender,
            price: price_
        });

        listing[nftAddress_][tokenId_] = listing_;

        emit NFTListed(msg.sender, nftAddress_, tokenId_, price_);
    }

    // Buy NFTs
    function buyNFT(address nftAddress_, uint256 tokenId_) external payable nonReentrant {
        Listing memory listing_ = listing[nftAddress_][tokenId_];

        // this is linked with require of line 26 => no need to check the addresses
        require(listing_.price > 0, "Listing not exists.");
        require(msg.value == listing_.price, "Incorrect price.");
        
        delete listing[nftAddress_][tokenId_];

        // transfer NFT from seller to buyer without passing through the SC, it will save gas and security issues
        IERC721(nftAddress_).safeTransferFrom(listing_.seller, msg.sender, listing_.tokenId);

        (bool success, ) = listing_.seller.call{value: msg.value}("");
        require(success, "Payment failed.");

        emit NFTSold(msg.sender, listing_.seller, listing_.nftAddress, listing_.tokenId, listing_.price);
    }


    // Cancel List
    function cancelList(address nftAddress_, uint256 tokenId_) external nonReentrant {
        Listing memory listing_ = listing[nftAddress_][tokenId_];
        require(listing_.seller == msg.sender, "Not the listing's owner.");

        delete listing[nftAddress_][tokenId_];

        emit NFTCancelled(msg.sender, nftAddress_, tokenId_);
    }

}