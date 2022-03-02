// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWeb3Rocks.sol";
import "hardhat/console.sol";

contract Web3RocksToken is Ownable, ERC20 {
    uint256 public constant tokenPrice = 0.001 ether;

    IWeb3Rocks IWeb3RocksNFT;

    uint256 public constant maxTotalSupply = 10000 * 10**18;

    uint256 public constant tokensPerNFT = 10 * 10**18;

    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _web3RocksContract) ERC20("Web3Rocks Token", "W3R") {
        IWeb3RocksNFT = IWeb3Rocks(_web3RocksContract);

        // here code len is 0 why its a cons bro
        console.log(address(this).code.length);
    }

    function Hi() public view  {
        console.log(address(this).code.length);
    }

    function mint(uint256 amount) public payable {
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Ether sent is incorrect");
        uint256 amountWithDecimales = amount * 10**18;

        console.log("Total Supply in circulation", totalSupply());

        require(
            (totalSupply() + amountWithDecimales) <= maxTotalSupply,
            "Exceeds the max total supply available"
        );
        _mint(msg.sender, amountWithDecimales);
    }

    function claim() public {
        address sender = msg.sender;
        uint256 balance = IWeb3RocksNFT.balanceOf(sender); // RETURNS THE TOTAL NFTS count

        require(balance > 0, "You dont own any Web3 Rocks NFT's");

        uint256 amount = 0;
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = IWeb3RocksNFT.tokenOfOwnerByIndex(sender, i);

            if (!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }

        require(amount > 0, "You have already claimed all the tokens");
        _mint(msg.sender, amount * tokensPerNFT);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty

    // If payable fails then this function fire

    fallback() external payable {}
}

// If any inherited contract has a constructor we need to define a construtor in OUR contract AS WELL
// OTHERWISE THIS GIVES

/* 
TypeError: Contract "Web3RocksToken" should be marked as abstract.
 --> contracts/Web3RocksToken.sol:9:1: 
 
*/

// _safemint / mint

/* 
if somebody sends NFT TO some SC and if SC don't have a anything with NFT then it lost forever

saveMINT checks that the co


contract address don't have private key
but normal addess had prviate key

*/
