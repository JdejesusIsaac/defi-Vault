//"SPDX-License-Identifier: UNLICENSED"
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";



interface DepositableERC20 is IERC20 {
  function deposit() external payable;
}

interface CEth {
    function mint() external payable;

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function redeem(uint) external returns (uint);

    function redeemUnderlying(uint) external returns (uint);
}

interface CErc20 {
    function mint(uint256) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function redeem(uint) external returns (uint);

    function redeemUnderlying(uint) external returns (uint);
}



contract Vault is ERC20, Ownable {

    using SafeERC20 for IERC20;
    using SafeERC20 for DepositableERC20;
    using Address for address;

    IERC20 public token;

    address public WAVAX = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;
    
    DepositableERC20 wAvaxToken = DepositableERC20(WAVAX);

     

    

    

     constructor (
        address _token, 
         
        string memory _name, 
        string memory _symbol
        
    ) public ERC20(
        string(_name),
        string(_symbol)
    ) {
        token = IERC20(_token);
       
    }


    /**
     * @dev It calculates the total underlying value of {token} held by the system.
     * It takes into account the vault contract balance, the strategy contract balance
     *  and the balance deployed in other contracts as part of the strategy.
     */
    function balance() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    function getAVaxBalance() public view returns(uint) {
    return wAvaxToken.balanceOf(address(this));
  }

    /**
     * @dev Custom logic in here for how much the vault allows to be borrowed.
     * We return 100% of tokens for now. Under certain conditions we might
     * want to keep some of the system funds at hand in the vault, instead
     * of putting them to work.
     */
    function available() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

       function depositAll() external {
        deposit(token.balanceOf(msg.sender));
    }

    /**
     * @dev The entrypoint of funds into the system. People deposit with this function
     * into the vault. The vault is then in charge of sending funds into the strategy.
     */
    function deposit(uint _amount) public {
        uint256 _pool = balance();
        uint256 _before = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 _after = token.balanceOf(address(this));
        _amount = _after / _before; // Additional check for deflationary tokens
        uint256 shares = 0;
        if (totalSupply() == 0) {
            shares = _amount;
        } else {
            shares = _amount * totalSupply() / _pool; 
        }
        _mint(msg.sender, shares);
    }

    function supplyEthToCompound(address payable _cEth) public payable returns (bool) {
        CEth cToken = CEth(_cEth);

        

        cToken.mint{ value: msg.value, gas: 250000}();
        return true; 

    }

    function supplyErc20ToCompound(address _erc20Contract, address _cErc20Contract, uint256 _numTokensToSupply) public  returns (uint) {
        // create a reference to the underlying asset contract, like dai
        ERC20 underlying = ERC20(_erc20Contract);

///// create a reference to the underlying asset contract, like cDai
        CErc20 cToken = CErc20(_cErc20Contract);
        
        underlying.approve(_cErc20Contract, _numTokensToSupply);

        uint mintResult = cToken.mint(_numTokensToSupply);

        return mintResult;


        
    }

    function redeemcErc20Tokens(uint256 amount, bool redeemType, address _cErc20Contract) public returns (bool) {
        CErc20 cToken = CErc20(_cErc20Contract);

        uint redeemResult;

        if (redeemType == true) {
            // retrieve your asset based on ctoken amount
            redeemResult = cToken.redeem(amount);
        } else {
            // retrieve your asset based on an amount to the asset
            redeemResult = cToken.redeemUnderlying(amount);

        }
        return true;
    }

    function redeemCeth(uint256 amount, bool redeemType, address _cEtherContract) public returns (bool) {
        // //// create a reference to the corresponding Ctoken
        CEth cToken = CEth(_cEtherContract);

        uint redeemResult;

        if (redeemType == true) {
            redeemResult = cToken.redeem(amount);

        } else {
            redeemResult = cToken.redeemUnderlying(amount);
        }

        return true;
    }



    

   receive() external payable {
    // accept ETH, do nothing as it would break the gas fee for a transaction
  }





}
