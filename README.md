# The Rock-Paper-Scissors Betting Smart Contract

## Basic Idea

All implementation can be done on [Remix browser IDE](https://remix.ethereum.org).
There is no need to actually deploy the contract and build frontend app (for now).

#### Game Part
- All address (players) starts with 1 action or ‘played’ bool false
- Have 3 actions to select (0: rock, 1: paper, 2: scissors)
- Only player with action count can select action
- Decrement the player’s action count to 0 or ‘played’ bool true after he selected an option (0/1/2)
- Store all players’ actions as private
- After 1st player played, wait for a 2nd player
- After 2nd player played, output result
- After output result, restore player action count to 1

#### Betting Part
- All address starts with 3 tokens
- Have 3 options to bet (0: player 1, 1: player 2)
- Only player with tokens can bet
- Decrement player’s token count by 1 after selecting a bet
- Payout when game result is revealed
- If draw, increment better’s token count by 1, if win increment by 2


## Some Function Suggestions

#### Game part

```javascript
// for storing player info
struct Player {
	bool played;	// already played an action or not
	uint action;	// action selected
}

// action function
function play {
	require(played); // check player has not played before
	action = 0; // selected action
	played = true; // set to true when player has played
}

// reveal result
function result() {
	require(game_end); // game_end needs to be true to display result
	// display game result
}
```

#### Betting part

```javascript
// for storing bettor info
struct Bettor {
	uint token;	// number of token
	uint bet;	// bet selected
}

// bet function
function bet {
	Bet = 0; // selected bet
	token =- 1; // decrement token count
}

// payout
function payout() {
	require(game_end); // game_end needs to be true to display result
	// payout
}
```
