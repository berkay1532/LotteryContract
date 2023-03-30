// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract Lottery {

    address public owner;
    address payable[] public players;
    uint public lotteryId;
    mapping(uint => address payable ) public lotteryHistory;

    constructor() {
        owner = msg.sender;
        lotteryId = 1;
    }


    event Enter(
        address playerAddress,
        uint lotteryId
    );
    
    event PickWinner(
        address payable[] players,
        uint lotteryId,
        address winner,
        uint balance
    );



    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }


    // address that belongs sender entering lottery with this function 
    function enter() public payable {
        require(msg.value > .01 ether,"You dont have enough ether to enter lottery");//checking the value of msg.sender have enough ether to enter the lottery
        players.push(payable(msg.sender));
        emit Enter(msg.sender,lotteryId);
    }

    //This function concatenate the owner and the block.timestamp, hash them with keecak256, change it type to uint and returns it as random number
    function getRandomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

    function pickWinner() public onlyOwner {
        require(players.length > 1,"Number of players is smaller than '1'");
        uint amount = address(this).balance;
        uint index = getRandomNumber() % players.length;//This provides us to get random number beetwen 0 to # of players
        players[index].transfer(address(this).balance);
        
        lotteryHistory[lotteryId] = players[index];
        lotteryId++;
        
        emit PickWinner(
        players,
        lotteryId,
        players[index],
        amount
        );

        // reseting the players array (winner is picked there is no players anymore)
        players = new address payable[](0);
    }


    modifier onlyOwner() {
        require(msg.sender == owner,"You are not the owner of the contract");
        _;
    }

}
