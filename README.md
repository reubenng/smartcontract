# The Rock-Paper-Scissors Betting Smart Contract

## Basic Idea

All implementation can be done on [Remix browser IDE](https://remix.ethereum.org).
There is no need to actually deploy the contract and build frontend app (for now).

#### Game Part (COMPLETED)
- All address (players) starts with 1 action or ‘played’ bool false
- Have 3 actions to select (0: rock, 1: paper, 2: scissors)
- Only player with action count can select action
- Decrement the player’s action count to 0 or ‘played’ bool true after he selected an option (0/1/2)
- Store all players’ actions as private
- After 1st player played, wait for a 2nd player
- After 2nd player played, output result
- After output result, restore player action count to 1

#### Betting Part (COMPLETED)
- All address starts with 3 tokens
- Have 3 options to bet (1: player 1, 2: player 2, 3: draw)
- Only better with tokens can bet
- Decrement better’s token count by 1 after selecting a bet
- Payout when game result is revealed
- If draw, increment better’s token count by 1, if win increment by 2

#### Final Integration (IN PROGRESS)
