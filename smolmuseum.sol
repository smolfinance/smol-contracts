pragma solidity ^0.5.0;


contract Context {
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "caller is not owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "new owner can't be the burn address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/*
 * @dev Stub contract until the actual NFT staking is up. 
*/
contract SmolMuseum  is Ownable {

	//Mapping data of booster of a user in a pool
	mapping(uint256 => mapping(address => uint256)) private boosterInfo;
    
    function getBoosterForUser(address _address, uint256 _pid)  public view returns (uint256) {
        return boosterInfo[_pid][_address];
    }
	
	// !!! WARNING!!!
	// Setter should be modifiable internally or controlled by a modifier when deploying the actual contract.
	function setBoosterForUser(address _address, uint256 _pid, uint256 _booster) public onlyOwner {
        boosterInfo[_pid][_address] = _booster;
    }
    
}