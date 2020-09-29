const Web3 = require('web3');
const Migrations = artifacts.require("Migrations");

const TruffleConfig = require('../truffle-config');

module.exports = function(deployer, network, addresses) {
  const config = TruffleConfig.networks[network];
  
  const web3 = new Web3(new Web3.providers.HttpProvider('http://' + config.host + ':' + config.port));

  console.log('>> Unlocking account ' + config.from);
  web3.eth.personal.unlockAccount(config.from, process.env.ACCOUNT_PASSWORD, 36000).then((response) => {
		console.log(response);
	}).catch((error) => {
		console.error(error);
	});

  deployer.deploy(Migrations);
};