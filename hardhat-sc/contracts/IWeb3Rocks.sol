// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IWeb3Rocks {
    // this comes from IERC721Enum
    // 1 2 3 => [1,3,8] => 1=> 3
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);

    // this is coming from ERC721.sol
     // RETURNS THE TOTAL NFTS count

    function balanceOf(address owner) external view returns (uint256);
    


}


// We use to create this interface so we can our Web3Rocks function without interhit it.