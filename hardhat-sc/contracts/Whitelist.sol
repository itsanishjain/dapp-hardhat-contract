//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Whitelist {
    uint8 public maxWhiteListedAddress;

    mapping(address => bool) public whiteListedAddresses;


    uint8 public numAddressesWhitelisted;
    

    // deploy
    constructor(uint8 _maxWhiteListedAddress) {
        maxWhiteListedAddress = _maxWhiteListedAddress;
    }

    function addAddressesToWhitelist() public {
               
        require(
            !whiteListedAddresses[msg.sender],
            "You are already whitelisted"
        );

        require(
            numAddressesWhitelisted < maxWhiteListedAddress,
            "Max whitelisted addresses reached"
        );


        whiteListedAddresses[msg.sender] = true;
        numAddressesWhitelisted++;
    }

}
