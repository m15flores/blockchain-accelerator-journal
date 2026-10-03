// SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "forge-std/Test.sol";
import "../src/NFTMarketplace.sol";

contract MockNFT is ERC721 {
    constructor() ERC721("MockNFT", "MNFT") {}

    function mint(address to_, uint256 tokenId_) external {
        _mint(to_, tokenId_);
    }
}

contract NFTMarketplaceTest is Test {

    NFTMarketplace marketplace;
    MockNFT nft;
    address deployer = vm.addr(1);
    address user = vm.addr(2);
    uint256 tokenId = 0;

    function setUp() public {
        vm.startPrank(deployer);
        marketplace = new NFTMarketplace();  
        nft = new MockNFT();
        vm.stopPrank();

        vm.startPrank(user);
        nft.mint(user, 0);
        vm.stopPrank();
    }

    function testMintNFT() public view {
        address ownerOf_ = nft.ownerOf(tokenId);
        assert(ownerOf_ == user);
    }

    function testListShouldRevertIfPriceIsZero() public {
        vm.startPrank(user);

        vm.expectRevert("Price cannot be 0.");
        marketplace.ListNFT(address(nft), tokenId, 0);

        vm.stopPrank();
    }

    function testListShouldRevertIfNotOwner() public {
        vm.startPrank(user);
        
        address user2_ = vm.addr(3);
        uint256 tokenId_ = 1;
        nft.mint(user2_, tokenId_);

        vm.expectRevert("You are not the owner of the NFT.");
        marketplace.ListNFT(address(nft), tokenId_, 1);

        vm.stopPrank();
    }

    function testListNFTCorrectly() public {
        vm.startPrank(user);

        (, , address sellerBefore_, ) = marketplace.listing(address(nft), tokenId);
        marketplace.ListNFT(address(nft), tokenId, 1e18);
        (, , address sellerAfter_, ) = marketplace.listing(address(nft), tokenId);

        assert(sellerBefore_ == address(0) && sellerAfter_ == user);

        vm.stopPrank();
    }

    function testCancelListShouldRevertIfNotOwner() public {
        vm.startPrank(user);

        (, , address sellerBefore_, ) = marketplace.listing(address(nft), tokenId);
        marketplace.ListNFT(address(nft), tokenId, 1e18);
        (, , address sellerAfter_, ) = marketplace.listing(address(nft), tokenId);

        assert(sellerBefore_ == address(0) && sellerAfter_ == user);

        vm.stopPrank();

        address user2_ = vm.addr(3);
        vm.startPrank(user2_);

        vm.expectRevert("Not the listing's owner.");
        marketplace.cancelList(address(nft), tokenId);

        vm.stopPrank();
    }

    function testCancelListShouldWorkCorrectly() public {
        vm.startPrank(user);

        (, , address sellerBefore_, ) = marketplace.listing(address(nft), tokenId);
        marketplace.ListNFT(address(nft), tokenId, 1e18);
        (, , address sellerAfter_, ) = marketplace.listing(address(nft), tokenId);

        assert(sellerBefore_ == address(0) && sellerAfter_ == user);

        marketplace.cancelList(address(nft), tokenId);
        (, , address sellerAfter2_, ) = marketplace.listing(address(nft), tokenId);

        assert(sellerAfter2_ == address(0));

        vm.stopPrank();
    }

    function testCannotBuyUnlistedNFT() public {
        address user2_ = vm.addr(3);

        vm.startPrank(user2_);

        vm.expectRevert("Listing not exists.");
        marketplace.buyNFT(address(nft), tokenId);

        vm.stopPrank();
    }

    function testCannotBuyWithIncorrectPay() public {
        vm.startPrank(user);

        (, , address sellerBefore_, ) = marketplace.listing(address(nft), tokenId);
        marketplace.ListNFT(address(nft), tokenId, 1e18);
        (, , address sellerAfter_, ) = marketplace.listing(address(nft), tokenId);

        assert(sellerBefore_ == address(0) && sellerAfter_ == user);

        vm.stopPrank();

        uint256 price_ = 1e18;
        address user2_ = vm.addr(3);
        vm.startPrank(user2_);

        vm.deal(user2_, price_);
        vm.expectRevert("Incorrect price.");
        marketplace.buyNFT{value: price_ - 1}(address(nft), tokenId);

        vm.stopPrank();
    }

    function testShouldBuyNFTCorrectly() public {
        vm.startPrank(user);

        (, , address sellerBefore_, ) = marketplace.listing(address(nft), tokenId);
        marketplace.ListNFT(address(nft), tokenId, 1e18);
        (, , address sellerAfter_, ) = marketplace.listing(address(nft), tokenId);

        assert(sellerBefore_ == address(0) && sellerAfter_ == user);

        nft.approve(address(marketplace), tokenId);
        vm.stopPrank();

        uint256 price_ = 1e18;
        address user2_ = vm.addr(3);
        vm.startPrank(user2_);
        vm.deal(user2_, price_);

        uint256 balanceBefore_ = address(user).balance;
        address ownerBefore_ = nft.ownerOf(tokenId);
        (, , address sellerBefore2_, ) = marketplace.listing(address(nft), tokenId);

        marketplace.buyNFT{value: price_}(address(nft), tokenId);
        (, , address sellerAfter2_, ) = marketplace.listing(address(nft), tokenId);
        address ownerAfter_ = nft.ownerOf(tokenId);
        uint256 balanceAfter_ = address(user).balance;

        assert(sellerBefore2_ == user && sellerAfter2_ == address(0));
        assert(ownerBefore_ == user && ownerAfter_ == user2_);
        assert(balanceAfter_ == balanceBefore_ + price_);

        vm.stopPrank();
    }
}