# The Rock-Paper-Scissors Betting Smart Contract

## Usage

Use npm to run the front-end:

```bash
npm start
```

## Basic Idea

All implementation can be done on [Remix browser IDE](https://remix.ethereum.org).
There is no need to actually deploy the contract and build frontend app (for now). (Lol, too late).

#### Game Part (COMPLETED)
- All address (players) starts with ‘played’ bool false
- Have 3 actions to select (0: rock, 1: paper, 2: scissors)
- Only player with ‘played’ bool false can play action without giving error
- Set ‘played’ bool true after he selected an option (0/1/2)
- Store all players’ actions as private
- After 1st player played, wait for a 2nd player
- After 2nd player played, output result, 1: player1 wins, 2: player2 wins, 3: no winner
- After output result, restore ‘played’ bool to false

#### Betting Part (COMPLETED)
- All address starts with 3 tokens
- Have 3 options to bet (1: player 1, 2: player 2, 3: draw)
- Only better with tokens can bet
- Decrement better’s token count by 1 after selecting a bet
- Payout when game result is revealed
- If draw, increment better’s token count by 1, if win increment by 2

#### Final Integration (IN PROGRESS)
