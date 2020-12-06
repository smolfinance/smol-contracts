pragma solidity ^0.5.0;


/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface SmolTing {
    function balanceOf(address owner) external view returns (uint256);
    function burn(address _account, uint256 value) external;
}

interface SmolStudio {
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;
    function mint(address _to, uint256 _id, uint256 _quantity, bytes calldata _data) external;
    function totalSupply(uint256 _id) external view returns (uint256);
    function maxSupply(uint256 _id) external view returns (uint256);
}


contract SmolMart is Ownable {
    using SafeMath for uint256;
    SmolStudio public smolStudio;
    SmolTing public Ting;
    mapping(uint256 => uint256) public cardCosts;

    event CardAdded(uint256[] cardIds, uint256[] points);
    event Redeemed(address indexed user, uint256 amount);

    constructor(SmolStudio _SmolStudioAddress, SmolTing _tingAddress) public {
        smolStudio = _SmolStudioAddress;
        Ting = _tingAddress;
    }

    function addCard(uint256[] memory _cardIds, uint256[] memory _amounts) public onlyOwner {
        require(_cardIds.length == _amounts.length, "_cardIds and _amounts have different length");
        for (uint256 i = 0; i < _cardIds.length; ++i) {
            cardCosts[_cardIds[i]] = _amounts[i];
        }
        emit CardAdded(_cardIds, _amounts);
    }

        // Mint 1 card directly to the user wallet from Studio 
    function redeem(uint256 _card) public {
        require(cardCosts[_card] != 0, "card not found");
        require(Ting.balanceOf(msg.sender) >= cardCosts[_card], "not enough TINGs to redeem for a ting");
        require(smolStudio.totalSupply(_card) < smolStudio.maxSupply(_card), "max cards minted");

        Ting.burn(msg.sender, cardCosts[_card]);
        smolStudio.mint(msg.sender, _card, 1, "");
        emit Redeemed(msg.sender, cardCosts[_card]);
    }
    
            // Mint 1 card directly to the user wallet from Studio 
    function redeemMultiple(uint256 _card, uint256 _amount) public {
        require(cardCosts[_card] != 0, "card not found");
        require(Ting.balanceOf(msg.sender) >= cardCosts[_card].mul(_amount), "not enough TINGs to redeem for a ting");
        require(smolStudio.totalSupply(_card).add(_amount) <= smolStudio.maxSupply(_card), "max cards minted");

        Ting.burn(msg.sender, cardCosts[_card].mul(_amount));
        smolStudio.mint(msg.sender, _card, _amount, "");
        emit Redeemed(msg.sender, cardCosts[_card].mul(_amount));
    }
    
        // Transfer multiple cards from Mart to the user wallet (need the cards to be minted to Mart first)
    function transferMultiple(uint256[] memory _cardIds, uint256[] memory _amounts) public {
        uint256 totalCost = 0;
        for (uint256 i = 0; i < _cardIds.length; ++i) {
            require(cardCosts[_cardIds[i]] != 0, "card not found");
            require(smolStudio.totalSupply(_cardIds[i]).add(_amounts[i]) <= smolStudio.maxSupply(_cardIds[i]), "max cards minted");
            uint256 toAdd = cardCosts[_cardIds[i]].mul(_amounts[i]);
            totalCost = totalCost.add(toAdd);
        }
        require(Ting.balanceOf(msg.sender) >= totalCost, "not enough TINGs to redeem tings");

        Ting.burn(msg.sender, totalCost);
        smolStudio.safeBatchTransferFrom(address(this), msg.sender, _cardIds, _amounts, "");
        emit Redeemed(msg.sender, totalCost);
    }



    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _amount, bytes calldata _data) external returns(bytes4) {
        return 0xf23a6e61;
    }
    
    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external returns(bytes4) {
        return 0xbc197c81;
    }

    function supportsInterface(bytes4 interfaceID) external view returns (bool) {
        return  interfaceID == 0x01ffc9a7 ||    // ERC-165 support (i.e. `bytes4(keccak256('supportsInterface(bytes4)'))`).
        interfaceID == 0x4e2312e0;      // ERC-1155 `ERC1155TokenReceiver` support (i.e. `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")) ^ bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`).
    }
}
