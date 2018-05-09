pragma solidity ^0.4.0;

// How to use game part
// 1. deploy
// 2. select any address, 

contract JanKenPonBet {
	address public owner; // owner of contract, can use to implement special rights

    bool firstPlayer; // has a player played, if no store next action as actionOne, else store as actionTwo
    uint actionOne; // store player 1 action
    uint actionTwo; // store player 2 action
    uint winner; // 0 for no winner, 1 for player 1 wins, 2 for player 2 wins
    mapping(address => Player) public playerInfo; // mapping to store player info
    Action[] public actions; // dynamically sized array for available actions, will be initialised on construction
    bool public gameEnd; // keep track if game ended
    
    event revealActions(string name, string action); // review player action
    
    struct Action { // struct for available action to play, rock/paper/scissors
        string name;
    }
    
    // struct for each player, to store player info
    struct Player {
        bool played; // already played an action or not
    }

	// The constructor
	function JanKenPonBet() public {
		// msg.sender is a value defined by the user when contract is executed, in this case the address
		owner = msg.sender;

        // pass actions' names, can be used to add more actions
        actions.push(Action("rock"));
        actions.push(Action("paper"));
        actions.push(Action("scissors"));
	}

    // for selecting actions
    function play(uint actionIndex) {
        require(!playerInfo[msg.sender].played); // check player has not played before
        if (!firstPlayer) { // if no first player
            actionOne = actionIndex; // store as player1's action
            firstPlayer = true; // first player has played
        } else { // first player already played
            actionTwo = actionIndex; // store as player2's action
            gameEnd = true; // 2 players have played, game ends
            // select winner
            if () {
                
            }
        }
        
        playerInfo[msg.sender].played = true; // set to true when player has selected action
    }
    
    // for revealing game result
    function Result() {
        require(gameEnd); // gameEnd needs to be true to display result
        revealActions("player1", actions[actionOne].name); // display player 1 action
        revealActions("player2", actions[actionTwo].name); // display player 2 action
    }
}