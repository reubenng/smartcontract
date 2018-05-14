pragma solidity ^0.4.22;

// How to use game part
// 1. Deploy and go to 'Run' tab on the right hand side.
// 2. To play as first player, select any account address.
// 3. Enter an action number into the 'play' field, 0 for rock, 1 for paper, 3 for scissors.
//     - Optional: Bet on yourself winning by adding value to the play function (must be over 100 microgwei)
// 4. Now if you're still using the same account and click 'play' again you'll get an error 
//     because you've already played.
// 5. Now switch to another account as player 2.
// 6. To play as 2nd player, enter an action number into the 'play' field.
//     - Optional: Bet on yourself winning by adding value to the play function (must be over 100 microgwei)
// 7. To bet, use the bet() function, give a value of 100microgwei as the bet, and enter:
//       1 = Player1 win, 2 = Player2 win, 3 = draw
// 8. Click on the latest console message to show the log, you'll see both players' actions revealed.
// 9. At the bottom part for showing winner, "winner": 1 if player 1 wins, 2 if player 2 wins, 3 is no winner
//10. All bets are split up proportional to all the winning bets, with a cut being taken by the contract.
//11. If there are no winners, all bets are refunded (minus a fee).
//12. Use withdraw() as the owner to take your winnings.

contract JanKenPonBet {
	address public owner; // owner of contract, can use to implement special rights

    uint private player1move;
    
    address public player1Add;
    string[] public actions = ["Rock", "Paper", "Scissors"];
    string[] public winner_string = ["Null", "Player1", "Player2", "Draw"];
    
    uint constant feePercentage = 98; // 98%, so 2% betting fee
    
    // reveal game results
    event revealActions(string player1action, string player2action, string winner);
    
    // reveal bet winners
    event revealBetWinners(address better, uint256 betAmount, uint256 wonAmount);
    
    event log_num_winners(uint number_of_winners);
    
    struct Action { // struct for storing available action to play, rock/paper/scissors
        string name;
    }

	// The constructor
	constructor() public {
		// msg.sender is a value defined by the user when contract is executed, in this case the address
		owner = msg.sender;
		
		// invalid move to show that we are waiting for player 1
		player1move = 255;

        betters.length = 0;
	}

    // compare actions for deciding winner
    function game(uint one, uint two) pure internal returns(uint) { // pass in actions from both player
        if (one == two) { // tie
            return 3;
        } 
        if (one == 0) { // rock
            if (two == 2) { // scissors
                return 1; // rock wins
            } else {
                return 2; // paper wins
            }
        } 
        if (one == 1) { // paper
            if (two == 0) { // rock
                return 1; // paper wins
            } else {
                return 2; // scissors win
            }
        }
        if (one == 2) { // scissors
            if (two == 1) { // paper
                return 1; // scissors win
            } else {
                return 2; // rock win
            }
        }
        return 3;
    }

    // for selecting actions
    function play(uint actionIndex) public payable {
        require(actionIndex < actions.length, "actionIndex must be 0, 1, or 2"); // check if move is valid
        if (player1move == 255) { // if no first player
            player1move = actionIndex; // store as player1's action
            player1Add = msg.sender;  // stores Player1 Address
            if (msg.value != 0) {
                bet(1);
            }
        } else { // first player already played
            // check if player1 != player2
            require(msg.sender != player1Add, "You cannot be both Player1 and Player2."); // could remove to save gas
            
            if (msg.value != 0) {
                bet(2);
            }
            
            uint winner = game(player1move, actionIndex); // find winner
            distributePrizes(winner);
            Result(winner, actionIndex);
            
            player1move = 255;
        } 
    }
    
    // for revealing game result
    function Result(uint winner, uint player2move) internal {
        emit revealActions(actions[player1move],
            actions[player2move],
            winner_string[winner]); // display game actions
        return;
    }
    
    // ----------------------------------- BEGIN BETTING -----------------------
// Design adapted from: https://medium.com/@merunasgrincalaitis/the-ultimate-end-to-end-tutorial-to-create-and-deploy-a-fully-descentralized-dapp-in-ethereum-18f0cf6d7e0e
// Every solidity contract must start with the compiler version
// The one above is the default on the example script in Remix Ethereum

    // 100 microether/szabo is currently like 7 cents
	uint256 public constant minimumBetValue = 100 szabo;
	uint256 public totalBetValue;
	uint256 public constant maxAmountOfBets = 100;
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
	
	modifier onlyOwner() {
        require (msg.sender == owner, "You are not the owner.");
        _;
    }

	// The kill function - don't use this unless the contract is compromised in some way!
	function kill() public onlyOwner {
		selfdestruct(owner);
	}
	
	function withdraw() public onlyOwner {
		owner.transfer(address(this).balance);
	}

	// We need to check that the user hasn't placed a bet yet. This checks if they have
	function checkBetterBetted(address better) public constant returns(bool) {
		for (uint256 i = 0; i < betters.length; i++) {
			if (betters[i] == better) return true;
		}
		return false;
	}

	// This allows for a bet of either 1, 2 (i.e. representing the players) or 3 (i.e. a draw)
	// The "payable" modifier means this function can receive ether when executed
	function bet(uint256 playerBettedOn) public payable {
		// "require" is basically an if statement that must return true. If false ether paid is reverted to the sender
		require(!checkBetterBetted(msg.sender), "You have already betted in this game.");
		require(playerBettedOn >= 1 && playerBettedOn <= 3, "playerBettedOn must be 1, 2, or 3.");
		require(msg.value >= minimumBetValue, "You must bet more than minimumBetValue."); // msg.value is the user's ether amount

		betterInfo[msg.sender].betAmount = msg.value;
		betterInfo[msg.sender].playerBettedOn = playerBettedOn;
		betters.push(msg.sender);
		totalBetValue += msg.value;
	}

	// This function distributes prizes to winning bets
	function distributePrizes(uint256 winningPlayerNum) internal {
		// We have to create a temporary in memory array with fixed size (all betters could win)
		// This gets deleted after the function executes effectively and must be fixed size
		if(totalBetValue == 0 || betters.length == 0) {
		    return;
		}
		address[] memory winners = new address[](betters.length);
		uint256 numberOfWinningShares = 0;
		uint numberOfWinners = 0; 

		for (uint256 i = 0; i < betters.length; i++) {
			address betterAddress = betters[i];

			if (betterInfo[betterAddress].playerBettedOn == winningPlayerNum) {
				winners[numberOfWinners] = betterAddress;
				numberOfWinningShares += betterInfo[betterAddress].betAmount;
				numberOfWinners++;
			}
		}
		
		emit log_num_winners(numberOfWinners);

        if(numberOfWinners == 0) {
            // no one wins, return all the money (minus a fee of course)
            for (i = 0; i < betters.length; i++) {
			    betterAddress = betters[i];
			    betterAddress.transfer(betterInfo[betterAddress].betAmount
			        * feePercentage / 100) ;
            }
            totalBetValue = 0;
            return;
        }
        
        // Clear all the betters' addresses - the game is done for now
		betters.length = 0;

        // initalize outside the loop to save gas
        address winner;
        uint256 betval;
        uint256 winamount;
        
		for (uint256 j = 0; j < numberOfWinners; j++) {
			// Check that there is in fact a winner for this round then send out the winnings
			winner = winners[j];
			betval = betterInfo[winner].betAmount;
			if (winner != address(0)) {
			    winamount = totalBetValue
			        * betval / numberOfWinningShares
			        * feePercentage / 100;
			    winner.transfer(winamount);
			    emit revealBetWinners(winner, betval, winamount);
			}
			// no actual need to delete these, but we get a gas refund!
			delete betterInfo[winner]; 
		}
		totalBetValue = 0;
	}
}
