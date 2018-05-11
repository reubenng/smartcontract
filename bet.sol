pragma solidity ^0.4.0;

// Design adapted from: https://medium.com/@merunasgrincalaitis/the-ultimate-end-to-end-tutorial-to-create-and-deploy-a-fully-descentralized-dapp-in-ethereum-18f0cf6d7e0e
// Every solidity contract must start with the compiler version
// The one above is the default on the example script in Remix Ethereum

contract JanKenPonBet {
	address public owner;
	uint256 public minimumBetValue;
	uint256 public totalBetValue;
	uint256 public numberOfBets;
	uint256 public maxAmountOfBets = 100;
	address[] public betters; // Array to store the betters' addresses

	// A struct will be made for each person betting on the match
	struct Better {
		uint256 betAmount;
		uint256 playerBettedOn; // There are only two players
	}

	// Needed so we can use a better's address to figure out his bet and how much he betted
	mapping(address => Better) public betterInfo;

	// An anonymous callback function that gets executed when ether is sent without executing any function
	// This saves it and makes sure it isn't lost otherwise the transfer would be rejected
	function() public payable {}

	// The constructor
	constructor(uint256 _minimumBetValue) public {
		// msg.sender is a value defined by the user when contract is executed, in this case the address
		owner = msg.sender;

		// Define the minimum bet for the game
		if (_minimumBetValue != 0 ) minimumBetValue = _minimumBetValue;
	}

	// The kill function - don't use this unless the contract is compromised in some way!
	function kill() public {
		if (msg.sender == owner) selfdestruct(owner);
	}

	// We need to check that the user hasn't placed a bet yet. This checks if they have
	function checkBetterBetted(address better) public constant returns(bool) {
		for (uint256 i = 0; i < betters.length; i++) {
			if (betters[i] == better) return true;
		}
		return false;
	}

	// This allows for a bet of either 1 or 2 (i.e. representing the players)
	// The "payable" modifier means this function can receive ether when executed
	function bet(uint256 playerBettedOn) public payable {
		// "require" is basically an if statement that must return true. If false ether paid is reverted to the sender
		require(!checkBetterBetted(msg.sender));
		require(playerBettedOn == 1 || playerBettedOn == 2);
		require(msg.value >= minimumBetValue); // msg.value is the user's ether amount

		betterInfo[msg.sender].betAmount = msg.value;
		betterInfo[msg.sender].playerBettedOn = playerBettedOn;
		numberOfBets++;
		betters.push(msg.sender);
		totalBetValue += msg.value;
	}

	// Takes the winner and changes it to a number (either 1 or 2) and distributes the prize to correct bets
	function generateWinner() public {
		// TODO: write a function that deals with returning the player number from the other contract
		// 		 that conducts the JanKenPon match
		distributePrizes(winningPlayer);
	}

	// This function distributes prizes to winning bets
	function distributePrizes(uint256 winningPlayerNum) public {
		// We have to create a temporary in memory array with fixed size (all betters could win)
		// This gets deleted after the function executes effectively and must be fixed size
		address[maxAmountOfBets] memory winners;
		uint256 numberOfWinners = 0;

		for (uint256 i = 0; i < betters.length; i++) {
			address betterAddress = betters[i];

			if (betterInfo[betterAddress].playerBettedOn == winningPlayerNum) {
				winners[numberOfWinners] = betterAddress;
				numberOfWinners++;
			}

			// Clear all the betters' bets and bet amounts
			delete betterInfo[betterAddress];
		}

		// Clear all the betters' addresses - the game is done for now
		betters.length = 0;

		// Divide up the winnings
		uint256 winnerEtherAmount = totalBetValue / winners.length;

		for (uint256 j = 0; j < numberOfWinners; j++) {
			// Check that there is in fact a winner for this round then send out the winnings
			if (winners[j] != address(0)) winners[j].transfer(winnerEtherAmount);
		}
	}
}
