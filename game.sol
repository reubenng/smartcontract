pragma solidity ^0.4.0;

// How to use game part
// 1. Deploy and go to 'Run' tab on the right hand side.
// 2. To play as first player, select any account address.
// 3. Enter an action number into the 'play' field, 0 for rock, 1 for paper, 3 for scissors.
// 4. Now if you're still using the same account and click 'play' again you'll get an error 
//     because you've already played.  If you click on 'Result' you'll get error as well 
//     because only 1 player has played, need a second player to show result.
// 5. Now switch to another account as player 2.
// 6. To play as 2nd player, enter an action number into the 'play' field. Again if you 
//     press 'play' again you'll get error because you've already played.
// 7. After the 2nd player has played, you can now click 'Result'.
// 8. Click on the latest console message to show the log, you'll see both players' actions revealed.
// 9. At the bottom part for showing winner, "winner": 0 is no winner, 1 if player 1 wins, 2 if player 2 wins

contract JanKenPonBet {
	address public owner; // owner of contract, can use to implement special rights

    bool firstPlayer; // has a player played, if no store next action as actionOne, else store as actionTwo
    uint private actionOne; // store player 1 action
    uint private actionTwo; // store player 2 action
    uint winner; // 0 for no winner, 1 for player 1 wins, 2 for player 2 wins
    mapping(address => Player) public playerInfo; // mapping to store player info
    Action[] public actions; // dynamically sized array for available actions, will be initialised on construction
    bool public gameEnd; // keep track if game ended
    
    event revealActions(string name, string action); // reveal player action
    event revealWinner(string name, uint winner); // show winner
    
    struct Action { // struct for storing available action to play, rock/paper/scissors
        string name;
    }
    
    // struct for each player, to store player info
    struct Player {
        bool played; // already played an action or not
    }

	// The constructor
	constructor() public {
		// msg.sender is a value defined by the user when contract is executed, in this case the address
		owner = msg.sender;

        // pass actions' names, can be used to add more actions
        actions.push(Action("rock")); // 0
        actions.push(Action("paper")); // 1
        actions.push(Action("scissors")); // 2
	}

    // compare actions for deciding winner
    function game(uint one, uint two) internal returns(uint) { // pass in actions from both player
        if (one == two) { // tie
            return 0;
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
    }

    // for selecting actions
    function play(uint actionIndex) public {
        require(!playerInfo[msg.sender].played); // check player has not played before
        if (!firstPlayer) { // if no first player
            actionOne = actionIndex; // store as player1's action
            firstPlayer = true; // first player has played
        } else { // first player already played
            actionTwo = actionIndex; // store as player2's action
            gameEnd = true; // 2 players have played, game ends
            // select winner
            winner = game(actionOne, actionTwo);
        }
        playerInfo[msg.sender].played = true; // set to true when player has selected action
    }
    
    // for revealing game result
    function Result() public {
        require(gameEnd); // gameEnd needs to be true to display result
        revealActions("Player 1", actions[actionOne].name); // display player 1 action
        revealActions("Player 2", actions[actionTwo].name); // display player 2 action
        revealWinner("Winner", winner); // display winner
    }
}
