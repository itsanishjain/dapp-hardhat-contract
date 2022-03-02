// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";

import "./IFakeMarketplace.sol";
import "./IWeb3Rocks.sol";
import "hardhat/console.sol";

contract Web3RocksDAO is Ownable {
    struct Proposal {
        uint256 nftTokenId;
        uint256 deadline;
        uint256 yayVotes;
        uint256 nayVotes;
        bool executed;
        // key => NFT token ID
        mapping(uint256 => bool) voters;
    }

    // []
    mapping(uint256 => Proposal) public proposals;

    uint256 public numProposals;

    IFakeMarketplace nftMarketplace;
    IWeb3Rocks web3RocksNFT;

    constructor(address _nftMarketplaceAddress, address _web3RocksNFTAddress) {
        nftMarketplace = IFakeMarketplace(_nftMarketplaceAddress);
        web3RocksNFT = IWeb3Rocks(_web3RocksNFTAddress);
    }

    // Are u a NFT holder
    modifier nftHolderOnly() {
        require(web3RocksNFT.balanceOf(msg.sender) > 0, "NOT_A_DAO_MEMBER");
        _;
    }

    modifier activeProposalOnly(uint256 proposalIndex) {
        require(
            proposals[proposalIndex].deadline > block.timestamp,
            "DEADLINE_EXCEEDED"
        );
        _;
    }

    modifier inactiveProposalOnly(uint256 proposalIndex) {
        require(
            proposals[proposalIndex].deadline <= block.timestamp,
            "DEADLINE_NOT_EXCEEDED"
        );
        // false == false => true
        require(
            proposals[proposalIndex].executed == false,
            "PROPOSAL_ALREADY_EXECUTED"
        );
        _;
    }

    function createProposal(uint256 _nftTokenId, uint256 _deadline)
        external
        nftHolderOnly
        returns (uint256)
    {
        require(nftMarketplace.available(_nftTokenId), "NFT_NOT_FOR_SALE");

        // it is last one

        Proposal storage proposal = proposals[numProposals]; // type Proposal

        proposal.nftTokenId = _nftTokenId;
        proposal.deadline = block.timestamp + (_deadline * 1 minutes);

        numProposals++;

        return numProposals - 1;
    }

    enum Vote {
        YAY, // YAY= 0
        NAY //  NAY = 1
    }

    function voteOnProposal(uint256 proposalIndex, Vote vote)
        external
        nftHolderOnly
        activeProposalOnly(proposalIndex)
    {
        Proposal storage proposal = proposals[proposalIndex];

        uint256 voterNFTBalance = web3RocksNFT.balanceOf(msg.sender);

        uint256 numVotes = 0;

        for (uint256 i = 0; i < voterNFTBalance; i++) {
            uint256 tokenID = web3RocksNFT.tokenOfOwnerByIndex(msg.sender, i);

            if (proposal.voters[tokenID] == false) {
                numVotes++;
                proposal.voters[tokenID] = true;
            }
        }

        require(numVotes > 0, "TOKEN ID ALREADY VOTED");

        if (vote == Vote.YAY) {
            proposal.yayVotes += numVotes;
        } else {
            proposal.nayVotes += numVotes;
        }
    }

    function executeProposal(uint256 proposalIndex)
        external
        nftHolderOnly
        inactiveProposalOnly(proposalIndex)
    {
        Proposal storage proposal = proposals[proposalIndex];

        if (proposal.yayVotes > proposal.nayVotes) {
            uint256 nftPrice = nftMarketplace.getPrice();
            require(address(this).balance > nftPrice, "NOT_ENOUGH_FUNDS");
            nftMarketplace.purchase{value: nftPrice}(proposal.nftTokenId);
        }
        proposal.executed = true;
    }

    function withdrawEther() external onlyOwner {
        // owner() comes of ownable which is contract deplolyer
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}

    fallback() external payable {}
}

// question why to console.log not working with user defined datatype

// how to add custome/user defined time to block.timestamp => cleared
// eg: proposal.deadline = block.timestamp +  X minutes;

// power is base on token/NFT so how this fully
// decentralized

// If owner want to runaway with entire ETH is it possible to do same
