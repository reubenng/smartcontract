import React from 'react'
import ReactDOM from 'react-dom'
import Web3 from 'web3'
import './../css/index.css'
class App extends React.Component {
   constructor(props){
      super(props)
      this.state = {
         lastWinner: "None",
	 lastBetWinners: [],
         minimumBet: 0,
	 totalBet: 0,
	 maxAmountOfBets: 0
      }
      if(typeof web3 != 'undefined'){
        console.log("Using this.web3 detected from external source like Metamask")
        this.web3 = new Web3(web3.currentProvider)
      } else{
        this.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"))
      }
      const MyContract = this.web3.eth.contract(
[{"constant":false,"inputs":[],"name":"withdraw","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalBetValue","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"minimumBetValue","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"player1Add","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"actionIndex","type":"uint256"}],"name":"play","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[{"name":"playerBettedOn","type":"uint256"}],"name":"bet","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"actions","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"betterInfo","outputs":[{"name":"betAmount","type":"uint256"},{"name":"playerBettedOn","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"betters","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"better","type":"address"}],"name":"checkBetterBetted","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"winner_string","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"maxAmountOfBets","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"payable":true,"stateMutability":"payable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":false,"name":"player1action","type":"string"},{"indexed":false,"name":"player2action","type":"string"},{"indexed":false,"name":"winner","type":"string"}],"name":"revealActions","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"better","type":"address"},{"indexed":false,"name":"betAmount","type":"uint256"},{"indexed":false,"name":"wonAmount","type":"uint256"}],"name":"revealBetWinners","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"number_of_winners","type":"uint256"}],"name":"log_num_winners","type":"event"}])

	   
      this.state.ContractInstance = MyContract.at("0x5398f5caa4b8f9b123e45da11bf51d531ef478f5")
}

componentDidMount(){
      this.updateState()
setInterval(this.updateState.bind(this), 10e3)
   }

updateState(){
      this.state.ContractInstance.minimumBetValue((err, result) => {
         if(result != null){
            this.setState({
               minimumBet: parseFloat(this.web3.fromWei(result, 'ether'))
            })
         }
      })
      this.state.ContractInstance.totalBetValue((err, result) => {
         if(result != null){
            this.setState({
               totalBet: parseFloat(this.web3.fromWei(result, 'ether'))
            })
         }
      });
      this.state.ContractInstance.maxAmountOfBets((err, result) => {
         if(result != null){
            this.setState({
               maxAmountOfBets: parseInt(result)
            })
         }
      });
      this.state.ContractInstance.revealActions({}, { fromBlock: 3227131, toBlock: 'latest' }).get((error, eventResult) => {
        if (error)
          console.log('Error in revealActions event handler: ' + error);
        else {
          var lastWin = eventResult[eventResult.length - 1];
          var lastWinBlock = lastWin["blockNumber"];

          // search for the winners of the bet in that block
          this.state.ContractInstance.revealBetWinners({}, {
	    fromBlock: lastWinBlock, toBlock: lastWinBlock
	  }).get((error, eventResult) => {
            if (error)
              console.log('Error in revealBetWinners event handler: ' + error);
            else {
              //save all the winners of the last bet
	      var tmpLastBetWinners = [];
              if (eventResult.length == 0) {
                tmpLastBetWinners = "There were no winners in the last round."
                  + " All bets were refunded. ";
	      } else {
		var winner;
                for (winner of eventResult) {
	          tmpLastBetWinners.push(
                    <ul class="betwinners">
                      <li> <strong>Better</strong>:
                        {winner["args"]["better"]} <br/></li> 
                      <li> <strong>Betted</strong>:
                        {parseFloat(this.web3.fromWei(
                          winner["args"]["betAmount"], 'ether'))} ether <br/>
                      </li> 
                      <li> <strong>Won</strong>:
                        {parseFloat(this.web3.fromWei(
                          winner["args"]["wonAmount"], 'ether'))} ether<br/>
                      </li> 
                    </ul>
	          );
	        }
	      }
	      this.setState({
                // save lastBetWinners as a list of dictionaries
                lastBetWinners: tmpLastBetWinners
              });
            }
          });
          var lwarg = lastWin["args"];
	  var blockNumber = lastWin["blockNumber"];
	  this.web3.eth.getBlock(blockNumber, (error, block) => {
            if (error)
              console.log('Error in getBlock event handler: ' + error);
            else
              this.setState({
                lastWinner: <div>
                  Player 1 played: <strong>{lwarg["player1action"]} </strong>
                  and Player 2 played:
		  <strong>{lwarg["player2action"]} </strong>
                  so winner was: <strong>{lwarg["winner"]}</strong> on
                  block {blockNumber} at
		  time {new Date(block["timestamp"]*1000).toISOString()}.
                </div>
	      })
          });
        }
      });
}

action(number){
      let bet = this.refs['ether-bet-player'].value
if(!bet) bet = 0.0
if(parseFloat(bet) != 0.0 && parseFloat(bet) < this.state.minimumBet){
         alert('You must bet more than the minimum')
         cb()
      } else {
         this.state.ContractInstance.play(number, {
            gas: 300000,
            from: this.web3.eth.accounts[0],
            value: this.web3.toWei(bet, 'ether')
         }, (err, result) => {
            cb()
         })
      }
   }

bet(number){
      let bet = this.refs['ether-bet'].value
if(!bet) bet = this.state.minimumBet
if(parseFloat(bet) != 0.0 && parseFloat(bet) < this.state.minimumBet){
         alert('You must bet more than the minimum')
         cb()
      } else {
         this.state.ContractInstance.bet(number, {
            gas: 300000,
            from: this.web3.eth.accounts[0],
            value: this.web3.toWei(bet, 'ether')
         }, (err, result) => {
            cb()
         })
      }
   }


render(){
      var warning = "";
      if(typeof web3 == 'undefined'){
      warning = (<div>
        <h2> !!! Warning !!! </h2>
          <strong>MetaMask or another browser based ETH Wallet could not be found. We highly recommend you use one, otherwise this website may not work. Check the Help section for instructions.</strong>
        </div>);}

      return (
         <div className="main-container">
            <h1>JanKenPo Dapp</h1>

              {warning}

<div className="block">
               <b>Last game winners:</b> &nbsp;
               <span>{this.state.lastWinner}</span>
            </div>
<div className="block">
               <b>Total ether bet:</b> &nbsp;
               <span>{this.state.totalBet} ether</span>
            </div>
<div className="block">
               <b>Minimum bet:</b> &nbsp;
               <span>{this.state.minimumBet} ether</span>
            </div>
<div className="block">
               <b>Max amount of bets:</b> &nbsp;
               <span>{this.state.maxAmountOfBets} ether</span>
            </div>
<hr/>
<h2>Play JanKen</h2>
               <b>How much Ether do you want to bet? Enter 0 for no bet. <input className="bet-input" ref="ether-bet-player" type="number" placeholder="0.0"/></b> ether
   <ul ref="numbers">
               <li class="li_button" onClick={
                 () => {this.action(0)}}>Rock</li>
               <li class="li_button" onClick={
                 () => {this.action(1)}}>Paper</li>
               <li class="li_button" onClick={
                 () => {this.action(2)}}>Scissors</li>
   </ul>

<h2>Bet on JanKen</h2>
	<b>How much Ether do you want to bet? <input className="bet-input" ref="ether-bet" ref="ether-bet" type="number" placeholder={this.state.minimumBet}/></b> ether
	<ul>
               <li class="li_button" onClick={
                 () => {this.bet(1)}}>Player 1 Wins</li>
               <li class="li_button" onClick={
                 () => {this.bet(2)}}>Player 2 Wins</li>
               <li class="li_button" onClick={
                 () => {this.bet(3)}}>Draw</li>
            </ul>
<h3>Last Game Winners</h3>
           <div className="Last Game Winners">
	     {this.state.lastBetWinners}
	   </div>

<h3>Help</h3>

 <h4>Getting MetaMask and ETH to play with</h4>
  <ol>
    <li>Install the browser extension <a href="https://metamask.io/">MetaMask</a> to create a broswer Ethereum wallet. </li>
    <li>Click on MetaMask, and at the top, change the Network to use the <strong>Ropsten Test Network</strong>. This allows us to get free money to test the contract with. </li>
    <li>Go to <a href="https://faucet.metamask.io/">https://faucet.metamask.io/</a>, and 'request some ether from the faucet' for testing. </li>
    <li>On the JanKenPo Dapp, you can now bet and play.</li>
  </ol>

 <h4>Using the Site</h4>
  <ol>
    <li>Type in the amount you want to bet, (you can leave at 0.0 if you are just playing, otherwise it must be over the minimum amount), and then click the action you want to take, ie what move to use, or what to bet on. </li>
    <li>Accept the transaction in the MetaMask extension. </li>
    <li>Get someone else to play! (Or make a new account in MetaMask and play from that account.) </li>
  </ol>

<h3>About</h3>
  <p>
    By <a href="https://github.com/reubenng">reubenng</a>, <a href="https://github.com/akitololo">akitololo</a>, <a href="https://github.com/aloisklink">aloisklink</a>, and <a href="https://github.com/leedanieluk">leedanieluk</a>.
  </p>
  <p>
    You should be able to find the source code for this project on Github at <a href="https://github.com/reubenng/smartcontract">reubenng/smartcontract</a>.
  </p>
  <p>
    We would like to thank Merunas Grincalaitis for <a href="https://medium.com/@merunasgrincalaitis/the-ultimate-end-to-end-tutorial-to-create-and-deploy-a-fully-descentralized-dapp-in-ethereum-18f0cf6d7e0e">his extremely useful guide</a> on making a front-end for an Ethereum Dapp.
  </p>
  <p>
  Please be aware implementing this smart-contract on the actual Ethereum
  network may make you run afoul of UK's <a href="http://www.legislation.gov.uk/ukpga/2005/19/contents/enacted">Gamling Act 2005</a> and may give up to 51 weeks in prison if you have the incorrect license.
  </p>
  <p>
    The contract address is <a href="https://ropsten.etherscan.io/address/0x5398f5caa4b8f9b123e45da11bf51d531ef478f5">0x5398f5caa4b8f9b123e45da11bf51d531ef478f5</a> and the solidity source-code can be found on etherscan.
  </p>
         </div>
      )
   }
}

ReactDOM.render(
   <App />,
   document.querySelector('#root')
)
