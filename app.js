// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";

// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
//import metacoin_artifacts from '../../build/contracts/MetaCoin.json'
import test_artifacts from '../../build/contracts/Test.json'
/*
import ipfsAPI from 'ipfs-api'
var ipfs = ipfsAPI();
window.ipfs = ipfs;
*/
// MetaCoin is our usable abstraction, which we'll use through the code below.
//var MetaCoin = contract(metacoin_artifacts);
var Test = contract(test_artifacts);
//window.MetaCoin = MetaCoin;
window.Test = Test;
// The following code is simple to show off interacting with your contracts.
// As your needs grow you will likely need to change its form and structure.
// For application bootstrapping, check out window.addEventListener below.
var accounts;
var userAccount;
var responses;
var responseList = [];
window.App = {
  start: function() {
    var self = this;

    // Bootstrap the MetaCoin abstraction for Use.
    //MetaCoin.setProvider(web3.currentProvider);
    Test.setProvider(web3.currentProvider);
    // Get the initial account balance so it can be displayed.
    web3.eth.getAccounts(function(err, accs) {
      if (err != null) {
        alert("There was an error fetching your accounts.");
        return;
      }

      if (accs.length == 0) {
        alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
        return;
      }

      accounts = accs;
      let select = [
        document.getElementById('listeD'),
        document.getElementById('dest'),
      ];
      //select.firstChild.remove();
      //var addresses = self.getAddresses();
      for (let addresse of accounts){
        select[0].innerHTML+= '<option key='+addresse+' value='+addresse+'>'+addresse+'</option>'
        select[1].innerHTML+= '<option key='+addresse+' value='+addresse+'>'+addresse+'</option>'
        //select[2].innerHTML+= '<option key='+addresse+' value='+addresse+'>'+addresse+'</option>'
      }
      //console.log('addrs',addresses);
      //self.refreshBalance();
    });
  },

  /*setStatus: function(message) {
    var status = document.getElementById("status");
    status.innerHTML = message;
  },

  refreshBalance: function() {
    var self = this;

    var meta;
    MetaCoin.deployed().then(function(instance) {
      meta = instance;
      return meta.getBalance.call(account, {from: account});
    }).then(function(value) {
      var balance_element = document.getElementById("balance");
      balance_element.innerHTML = value.valueOf();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error getting balance; see log.");
    });
  },

  sendCoin: function() {
    var self = this;

    var amount = parseInt(document.getElementById("amount").value);
    var receiver = document.getElementById("receiver").value;

    this.setStatus("Initiating transaction... (please wait)");

    var meta;
    MetaCoin.deployed().then(function(instance) {
      meta = instance;
      return meta.sendCoin(receiver, amount, {from: account});
    }).then(function() {
      self.setStatus("Transaction complete!");
      self.refreshBalance();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error sending coin; see log.");
    });
  },
  getAddresses: function(){
    var addrs;
    Test.deployed()
      .then((instance)=> {
        var test = instance;
        return test.getAddresses()
      })
      .then((addresses)=> addresses);
  },*/
  getValue: function(){
    let data = {
      'type': null,
      'comment': null,
      'dateD': null,
      'dateF': null,
      'entreprise': null,
      'dest': null,
      'test': 10
    }
    userAccount = this.selectValue('listeD');
    data.type = this.selectValue('types');
    data.comment = document.getElementById('desc').value;
    data.dateD = document.getElementById('dateD').value;
    data.dateF = document.getElementById('dateF').value;
    data.entreprise = document.getElementById('entreprise').value;
    data.dest = this.selectValue('dest');
    console.log('test',data);
    Test.deployed()
      .then(instance=> instance.sendDemand(data.dest, data.test,{'from': userAccount,"gas":1000000} ))
      .then(()=>console.log('demande envoyée sans pb',userAccount),()=>console.log('erreur demande'))
  },
  selectValue: function(id){
    let type = document.getElementById(id);
    let a = type.selectedIndex ? type.selectedIndex : null;
    let b = type.options;
    return  a? b[a].value : null;
  },
  getResponse: function(){
    userAccount = this.selectValue('listeD');
    Test.deployed()
      .then(instance=> instance.getAllResponses(userAccount, {'from':userAccount,"gas":1000000}))
      .then(value=>{
          responses = value;
          console.log('rep:'+responses,typeof responses, userAccount);
          let objrep = {
            'dest': null,
            'test': null,
            'exp': null,
            'state': null,
            'id': null
          };
          let objnull = objrep;
          for (let j = 0; j < responses.map(t=> t.length)[0]; j++) {
            objrep = objnull;
            for (let i = 0; i < responses.length; i++){
              switch(i){
                case 0:
                  objrep.dest = responses[i][j].toString();
                case 1:
                  objrep.test = responses[i][j].toString(); 
                break;
                case 2:
                  objrep.exp = responses[i][j].toString(); 
                break;
                case 3:
                  objrep.state = responses[i][j].toString(); 
                break;
                case 4:
                  objrep.id = responses[i][j].toString();
                break;
              }
            }
            responseList[j] = Object.assign({},objrep); 
          }
          console.log('resp', responseList);
        },
        error=>{
          console.log('impossible d\'accéder à la liste de Response',error);
        }
      );
  }
};

window.addEventListener('load', function() {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 MetaCoin, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://localhost:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

  App.start();
});
