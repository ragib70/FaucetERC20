// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract faucet is Ownable{
    uint256 public tokenAmount = 1000000000000000000000;
    uint256 public waitTime = 30 minutes;

    ERC20 public tokenInstance;
    
    mapping(address => uint256) lastAccessTime;

    constructor() {
    }

    function updateTokenAmount(uint256 _tokenAmount) public onlyOwner {
        require(tokenAmount != _tokenAmount);
        tokenAmount = _tokenAmount;
    }

    function updateWaitTime(uint256 _waitTime) public onlyOwner {
        require(waitTime != _waitTime);
        waitTime = _waitTime;
    }

    function requestTokens(address _tokenInstance) public {
        require(allowedToWithdraw(msg.sender));
        address _owner = owner();
        tokenInstance = ERC20(_tokenInstance);
        tokenInstance.transferFrom(_owner, msg.sender, tokenAmount);
        lastAccessTime[msg.sender] = block.timestamp + waitTime;
    }

    function allowedToWithdraw(address _address) public view returns (bool) {
        if(lastAccessTime[_address] == 0) {
            return true;
        } else if(block.timestamp >= lastAccessTime[_address]) {
            return true;
        }
        return false;
    }
}
