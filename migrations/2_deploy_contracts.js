var SMOLcontract = artifacts.require("SMOLcontract");
var SmolTing = artifacts.require("SmolTing");
var SmoltingPot = artifacts.require("SmoltingPot");

module.exports = function(deployer) {
  deployer.deploy(SMOLcontract, "55000000000000000000000");
  deployer.deploy(SmolTing).then(function() {
    return deployer.deploy(SmoltingPot, SmolTing.address, "0x632D9e7E75B7431633DFeFD30A8710bf9e78c6b1", "1000000000000000000", 8780904, 8785904);
  });
};