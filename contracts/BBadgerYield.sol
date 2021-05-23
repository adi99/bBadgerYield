// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./interfaces/ILendingProtocol.sol";
import "./interfaces/IToken.sol
import "./interfaces/ICurveFi.sol";
import "./interfaces/ICreamBBadger.sol";
import "./interfaces/ICreamDAI.sol";
import "./interfaces/ICreamYUSD.sol";

interface ICreamJumpRateModelV2 {
  function blocksPerYear() external view returns (uint);
  function getBorrowRate(uint cash, uint borrows, uint reserves) external view returns (uint);
  function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) external view returns (uint);
  function utilizationRate(uint cash, uint borrows, uint reserves) external pure returns (uint);
}

interface IBadger {
  function deposit(uint256 _amount) external;
  function withdraw(uint256 _amount) external;
  function token() external view returns(address);
  function getPricePerFullShare() external view returns(uint256);
}

contract BBadgerYield is ILendingProtocol, Ownable{

  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  // protocol token (crBBadger) address
  address public token;
  // underlying token (token eg BBadger) address
  address public underlying;
  bool public initialized;

  address public jumpRateModelV2 = 0x014872728e7D8b1c6781f96ecFbd262Ea4D2e1A6;
  address public constant dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  address public constant y = address(0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01);
  address public constant ycrv = address(0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8);
  address public constant yycrv = address(0x5dbcF33D8c2E976c6b560249878e6F1491Bca25c);
  address public constant curve = address(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);

  address public constant ydai = address(0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01);

  address public constant usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
  address public constant yusdc = address(0xd6aD7a6750A7593E092a9B218d66C0A814a3436e);

  address public constant usdt = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
  address public constant yusdt = address(0x83f798e925BcD4017Eb265844FDDAbb448f1707D);

  address public constant tusd = address(0x0000000000085d4780B73119b644AE5ecd22b376);
  address public constant ytusd = address(0x73a052500105205d34Daf004eAb301916DA8190f);

   /**
     * @param _token : crBBadger address
     */

   function initialize(address _token) public {
    require(!initialized, "Already initialized");
    require(_token != address(0), 'crBBadger: addr is 0');

    token = _token;
    underlying = address(ICreamBBadger(_token).underlying());
    IERC20(underlying).safeApprove(_token, uint256(-1));
    initialized = true;
  }

 function nextSupplyRateWithParams(uint256[] calldata)
    external view override
    returns (uint256) {
    return 0;
  }

  /**
   * Calculate next supply rate for bBadger, given an `_amount` supplied
   *
   * @param _amount : new underlying amount supplied (eg badger token)
   * @return : yearly net rate
   */
  function nextSupplyRate(uint256 _amount) public override view returns (uint256) {
    return 0;
  }

  /**
   * @return current price of bBadger Badger in underlying, Badger bBadger price is always 1
   */
  function getPriceInToken()
    public override view
    returns (uint256) {
      return IBadger(token).getPricePerFullShare();
  }

  /**
   * @return apr : current yearly net rate
   */
  function getAPR()
    external view override
    returns (uint256) {
      return 0; 
  }

 /**
   * Gets all underlying tokens in this contract and mints crTokens
   * tokens are then transferred to msg.sender
   * NOTE: underlying tokens needs to be sent here before calling this
   * NOTE2: given that crTokens price is always 1 token -> underlying.balanceOf(this) == token.balanceOf(this)
   *
   * @return cryUSD and crBBadger Tokens minted
   */
  function mint()
    external override
    returns (uint256 cryUSD, uint256 crBBadger) {
      uint256 balance = IERC20(underlying).balanceOf(address(this));
      if (balance == 0) {
        return crBBadger;
      }
      // Deposit bBadger in Cream
      crBBadger =ICreamBBadger(token).mint(balance); 
      // Borrow Dai 
      uint BorrowDAI =ICreamDAI(dai).borrow(balance/2);

      // Deposit Dai to get yyCRV(yyDAI+yUSDC+yUSDT+yTUSD)
      uint256 _dai = IERC20(dai).balanceOf(address(this));
        if (_dai > 0) {
            IERC20(dai).safeApprove(y, 0);
            IERC20(dai).safeApprove(y, _dai);
            yERC20(y).deposit(_dai);
        }
      uint256 _y = IERC20(y).balanceOf(address(this));
        if (_y > 0) {
            IERC20(y).safeApprove(curve, 0);
            IERC20(y).safeApprove(curve, _y);
            ICurveFi(curve).add_liquidity([_y, 0, 0, 0], 0);
        }
      uint256 _ycrv = IERC20(ycrv).balanceOf(address(this));
       if (_ycrv > 0) {
            IERC20(ycrv).safeApprove(yycrv, 0);
            IERC20(ycrv).safeApprove(yycrv, _ycrv);
            yERC20(yycrv).deposit(_ycrv);
        }
      uint256 _yycrv = IERC20(yycrv).balanceOf(address(this));  

      //Deposit yyCRV(yyDAI+yUSDC+yUSDT+yTUSD) in Cream.fi again
      ICreamYUSD(yycrv).mint(_yycrv);
      cryUSD = IERC20(yycrv).balanceOf(address(this));
      IERC20(yycrv).safeTransfer(msg.sender, cryUSD);
  }

  function withdrawUnderlying(uint256 _amount) internal returns (uint256) {
        IERC20(ycrv).safeApprove(curve, 0);
        IERC20(ycrv).safeApprove(curve, _amount);
        ICurveFi(curve).remove_liquidity(_amount, [uint256(0), 0, 0, 0]);

        uint256 _yusdc = IERC20(yusdc).balanceOf(address(this));
        uint256 _yusdt = IERC20(yusdt).balanceOf(address(this));
        uint256 _ytusd = IERC20(ytusd).balanceOf(address(this));

        if (_yusdc > 0) {
            IERC20(yusdc).safeApprove(curve, 0);
            IERC20(yusdc).safeApprove(curve, _yusdc);
            ICurveFi(curve).exchange(1, 0, _yusdc, 0);
        }
        if (_yusdt > 0) {
            IERC20(yusdt).safeApprove(curve, 0);
            IERC20(yusdt).safeApprove(curve, _yusdt);
            ICurveFi(curve).exchange(2, 0, _yusdt, 0);
        }
        if (_ytusd > 0) {
            IERC20(ytusd).safeApprove(curve, 0);
            IERC20(ytusd).safeApprove(curve, _ytusd);
            ICurveFi(curve).exchange(3, 0, _ytusd, 0);
        }

        uint256 _before = IERC20(dai).balanceOf(address(this));
        yERC20(ydai).withdraw(IERC20(ydai).balanceOf(address(this)));
        uint256 _after = IERC20(dai).balanceOf(address(this));

        return _after.sub(_before);
    }
  
  /**
   * Gets all crBBadger in this contract and redeems underlying tokens.
   * underlying tokens are then transferred to `_account`
   * NOTE: crBBAdger needs to be sent here before calling this
   *
   */
  function redeem(address _account)
    external 
    returns (uint256 tokens) {
    yycrv =ICreamYUSD(token).redeem(IERC20(token).balanceOf(address(this)));

    uint256 _yycrv = IERC20(yycrv).balanceOf(address(this));
        if (_yycrv > 0) {
            yERC20(yycrv).withdraw(_yycrv);
            withdrawUnderlying(IERC20(ycrv).balanceOf(address(this)));
        }
    uint balance = IERC20(dai).balanceOf(address(this));
    //Repay borrowed Dai
    ICreamDAI(dai).repayBorrow(balance);
    //Redeem crBBadger into BBadger
    ICreamBBadger(token).redeem(IERC20(token).balanceOf(address(this)));
    
    IERC20 _underlying = IERC20(underlying);
    tokens = _underlying.balanceOf(address(this));
    _underlying.safeTransfer(_account, tokens);
  }


  /**
   * Get the underlying balance on the lending protocol
   *
   * @return underlying tokens available
   */
  function availableLiquidity() external view returns (uint256) {
    return ICreamBBadger(token).getCash();
    return ICreamDAI(dai).getCash();
    return ICreamYUSD(yycrv).getCash();
  }
}