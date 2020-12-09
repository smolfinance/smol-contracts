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
    function burn(address _account, uint256 _id, uint256 _amount) external;
    function mint(address _to, uint256 _id, uint256 _quantity, bytes calldata _data) external;
    function totalSupply(uint256 _id) external view returns (uint256);
    function maxSupply(uint256 _id) external view returns (uint256);
}


contract SmolCraft is Ownable {
    using SafeMath for uint256;
    SmolStudio public smolStudio;
    SmolTing public Ting;
    
    struct Recipes {
        uint256[] ingredientIds;
        uint256[] ingredientAmounts;
        uint256 craftedItemId;
        uint256 tingPrice;
    }
    
    uint256[] public recipeIdList;
    mapping(uint256 => uint256) public cardCosts;
    mapping(uint256 => Recipes) internal recipes;

    event RecipeAdded(uint256[] ingredients, uint256[] amounts, uint256 craftedItem, uint256 price);
    event RecipeRemoved(uint256 recipeId);
    event CraftedItem(address indexed user, uint256 indexed cardId);

    constructor(SmolStudio _SmolStudioAddress, SmolTing _tingAddress) public {
        smolStudio = _SmolStudioAddress;
        Ting = _tingAddress;
    }
    
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

        // Add a recipe or modify a recipe
    function addRecipe(uint256 _recipeId, uint256[] memory _ingredientIds, uint256[] memory _ingredientAmounts, uint256 _craftedItemId, uint256 _tingPrice) public onlyOwner {
        require(_ingredientIds.length > 0, "New recipe cannot be empty");
        require(_ingredientIds.length == _ingredientAmounts.length, "Arrays have different length");
        if (_isInArray(_recipeId, recipeIdList) == false) {
            recipeIdList.push(_recipeId);
        }
        
        recipes[_recipeId] = Recipes(_ingredientIds, _ingredientAmounts, _craftedItemId, _tingPrice);
        
        emit RecipeAdded(_ingredientIds, _ingredientAmounts, _craftedItemId, _tingPrice);
    }
    
        // Remove a recipe
    function removeRecipe(uint256 _recipeId) public onlyOwner {
        require(_isInArray(_recipeId, recipeIdList) == true, "Recipe doesn't exist");
        uint256[] memory emptyArray;
        recipes[_recipeId] = Recipes(emptyArray,emptyArray,0,0);
        
        emit RecipeRemoved(_recipeId);
    }

        // Mint 1 crafted item directly to the user wallet from Studio and burn the ingredients from the recipe
    function craft(uint256 _recipeId) public {
        Recipes storage recipe = recipes[_recipeId];
        uint256 length = recipe.ingredientIds.length;
        require(recipe.craftedItemId != 0, "recipe not found");
        
        if (recipe.tingPrice > 0) {
            require(Ting.balanceOf(msg.sender) >= recipe.tingPrice, "not enough TINGs to craft tings");
            Ting.burn(msg.sender, recipe.tingPrice);
        }
        
        for (uint256 i = 0; i < length; ++i) {
            smolStudio.burn(msg.sender, recipe.ingredientIds[i], recipe.ingredientAmounts[i]); 
        }
        
        smolStudio.mint(msg.sender, recipe.craftedItemId, 1, "");
        emit CraftedItem(msg.sender, recipe.craftedItemId);
    }
}
