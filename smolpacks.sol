// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface SmolStudio {
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;
    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool isOperator);
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);
    function totalSupply(uint256 _id) external view returns (uint256);
    function maxSupply(uint256 _id) external view returns (uint256);
    function mint(address _to, uint256 _id, uint256 _quantity, bytes memory _data) external;
}

interface Ting {
    function totalSupply() external view returns (uint256);
    function totalClaimed() external view returns (uint256);
    function addClaimed(uint256 _amount) external;
    function setClaimed(uint256 _amount) external;
    function transfer(address receiver, uint numTokens) external returns (bool);
    function transferFrom(address owner, address buyer, uint numTokens) external returns (bool);
    function balanceOf(address owner) external view returns (uint256);
    function mint(address _to, uint256 _amount) external;
    function burn(address _account, uint256 value) external;
}

contract SmolPacks is Ownable {
    using SafeMath for uint256;

    SmolStudio public studio;
    Ting public ting;

    struct Pack {
        uint256[] cardIdList;
        uint256[] cardWeightList;
        uint256 price;
        uint256 redeemed;
    }

    struct PackCardData {
        uint256 cardId;
        uint256 cardWeight;
    }

    uint256[] public packIdList;
    mapping (uint256 => Pack) public packs;

    event Redeemed(address indexed _user, uint256 indexed _cardIds, uint256 indexed _amounts);

    constructor(SmolStudio _studioAddr, Ting _tingAddr) public {
        studio = _studioAddr;
        ting = _tingAddr;
    }

    modifier onlyEOA() {
        require(msg.sender == tx.origin, "Not eoa");
        _;
    }

    /////
    /////
    /////

    // Returns the list of cardIds which are part of a pack
    function getCardIdListOfPack(uint256 _packId) external view returns(uint256[] memory) {
        return packs[_packId].cardIdList;
    }
    
    // Returns the list of cards' weights for cards which are part of a pack
    function getCardWeightListOfPack(uint256 _packId) external view returns(uint256[] memory) {
        return packs[_packId].cardWeightList;
    }

    function _getPackCardData(uint256 _packId) internal view returns(PackCardData[] memory) {
        uint256[] memory _cardIdList = packs[_packId].cardIdList;
        uint256[] memory _cardWeights = packs[_packId].cardWeightList;
        PackCardData[] memory result = new PackCardData[](_cardIdList.length);

        for (uint256 i = 0; i < _cardIdList.length; ++i) {
            uint256 _cardId = _cardIdList[i];
            uint256 _cardWeight = _cardWeights[i];
            result[i] = PackCardData(_cardId, _cardWeight);
        }

        return result;
    }


    /////////
    /////////
    /////////

    // Returns cumulated weight of all cards from a pack
    function getPackTotalWeight(uint256 _packId) public view returns(uint256) {
        uint256[] memory _cardWeights = packs[_packId].cardWeightList;

        uint256 total = 0;
        for (uint256 i = 0; i < _cardWeights.length; ++i) {
            uint256 cardWeight = _cardWeights[i];

            total = total.add(cardWeight);
        }

        return total;
    }

    // Returns probability to get each card (Value must be divided by 1e5)
    function getPackProbabilities(uint256 _packId) public view returns(uint256[] memory) {
        uint256[] memory _cardWeights = packs[_packId].cardWeightList;
        uint256[] memory proba = new uint256[](_cardWeights.length);

        for (uint256 i = 0; i < _cardWeights.length; ++i) {
            proba[i] = _cardWeights[i].mul(1e5).div(getPackTotalWeight(_packId));
        }

        return proba;
    }

    function getTotalRedeemed() public view returns(uint256) {
        uint256 totalRedeemed = 0;

        for (uint256 i = 0; i < packIdList.length; ++i) {
            totalRedeemed = totalRedeemed.add(packs[packIdList[i]].redeemed);
        }

        return totalRedeemed;
    }


    /////
    /////
    /////

    function addPack(uint256 _packId, uint256[] memory _cardIdList, uint256[] memory _cardWeightList, uint256 _price) public onlyOwner {
        require(_cardIdList.length > 0, "CardIdList cannot be empty");
        require(_price > 0, "Price cannot be 0");
        require(_cardIdList.length == _cardWeightList.length, "Arrays must be the same size");

        if (_isInArray(_packId, packIdList) == false) {
            packIdList.push(_packId);
        }

        packs[_packId] = Pack(_cardIdList, _cardWeightList, _price, 0);
    }


    function removePack(uint256 _packId) public onlyOwner {
        delete packs[_packId].cardIdList;
        packs[_packId].price = 0;
    }

    //

    // Redeem a random card from a pack (Not callable by contract, to prevent exploits on RNG)
    function redeem(uint256 _packId) public onlyEOA {
        Pack storage pack = packs[_packId];
        require(pack.price > 0, "Pack does not exist");
        require(ting.balanceOf(msg.sender) >= pack.price, "Not enough ting for pack");

        PackCardData[] memory data = _getPackCardData(_packId);

        ting.burn(msg.sender, pack.price);
        pack.redeemed = pack.redeemed.add(1);

        uint256 rng = _rng(getTotalRedeemed()) % getPackTotalWeight(_packId);


        uint256 cardIdWon = 0;
        uint256 cumul = 0;
        for (uint256 i = 0; i < data.length; ++i) {
            uint256 cardId = data[i].cardId;

            cumul = cumul.add(data[i].cardWeight);
            if (rng < cumul) {
                cardIdWon = cardId;
                break;
            }
        }

        require(cardIdWon != 0, "Error during card redeeming RNG");

        studio.mint(msg.sender, cardIdWon, 1, "");
        emit Redeemed(msg.sender, cardIdWon, 1);
    }

    //////////////
    // Internal //
    //////////////

    // Utility function to check if a value is inside an array
    function _isInArray(uint256 _value, uint256[] memory _array) internal pure returns(bool) {
        uint256 length = _array.length;
        for (uint256 i = 0; i < length; ++i) {
            if (_array[i] == _value) {
                return true;
            }
        }

        return false;
    }

    // This is a pseudo random function, but considering the fact that redeem function is not callable by contract,
    // and the fact that Ting is not transferable, this should be enough to protect us from an attack
    // I would only expect a miner to be able to exploit this, and the attack cost would not be worth it in our case
    function _rng(uint256 _seed) internal view returns(uint256) {
        return uint256(keccak256(abi.encodePacked((block.timestamp).add(_seed).add
        (block.difficulty).add
        ((uint256(keccak256(abi.encodePacked(block.coinbase)))) /
            block.timestamp).add
        (block.gaslimit).add
        ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
            block.timestamp).add
            (block.number)
            )));
    }
}
