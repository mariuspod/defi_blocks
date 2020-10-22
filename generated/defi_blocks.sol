// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;

import "@openzeppelinV2/contracts/token/ERC20/IERC20.sol";
import "@openzeppelinV2/contracts/math/SafeMath.sol";
import "@openzeppelinV2/contracts/utils/Address.sol";
import "@openzeppelinV2/contracts/token/ERC20/SafeERC20.sol";

import "../../interfaces/compound/cToken.sol";
import "../../interfaces/compound/Comptroller.sol";
import "../../interfaces/uniswap/Uni.sol";

import "../../interfaces/yearn/IController.sol";

contract BlocklyDAIStrategy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant want = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    Comptroller public constant rewardor = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    address public constant rewardorToken = address(0xc00e94Cb662C3520282E6f5717214004A7f26888);
    address public constant depositorToken = address(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
    address public constant exchange = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    // used for comp <> weth <> dai route
    address public constant intermediaryToken = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    unint256 public performanceFee = 50000;
    uint256 public constant performanceMax = 1000000;
    uint256 public withdrawalFee = 50;
    unint256 public constant withdrawalMax = 10000;

    address public governance;
    address public controller;
    address public strategist;

    constructor(address _controller) public {
        governance = msg.sender;
        strategist = msg.sender;
        controller = _controller;
    }

    function getName() external pure returns (string memory) {
        return "BlocklyDAIStrategy";
    }

    function setStrategist(address _strategist) external {
        require(msg.sender == governance, "!governance");
        strategist = _strategist;
    }

    function setWithdrawalFee(uint256 _withdrawalFee) external {
        require(msg.sender == governance, "!governance");
        withdrawalFee = _withdrawalFee;
    }

    function setPerformanceFee(uint256 _performanceFee) external {
        require(msg.sender == governance, "!governance");
        performanceFee = _performanceFee;
    }

    function deposit() public {
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            IERC20(want).safeApprove(depositorToken, 0);
            IERC20(want).safeApprove(depositorToken, _want);
            cToken(depositorToken).mint(_want);
        }
    }

    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        require(depositorToken != address(_asset), "depositorToken");
        require(rewardorToken != address(_asset), "rewardorToken");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint256 _amount) external {
        require(msg.sender == controller, "!controller");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }

        uint256 _fee = _amount.mul(withdrawalFee).div(withdrawalMax);

        IERC20(want).safeTransfer(IController(controller).rewards(), _fee);
        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds

        IERC20(want).safeTransfer(_vault, _amount.sub(_fee));
    }

    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        _withdrawAll();

        balance = IERC20(want).balanceOf(address(this));

        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds

        IERC20(want).safeTransfer(_vault, balance);
    }

    function _withdrawAll() internal {
        uint256 amount = balanceOfDepositToken();
        if (amount > 0) {
            _withdrawSome(balanceOfDepositTokenInWantToken().sub(1));
        }
    }

    function harvest() public {
        require(msg.sender == strategist || msg.sender == governance, "!authorized");
        rewardor.claimComp(address(this));
        uint256 _reward = IERC20(rewardorToken).balanceOf(address(this));
        if (_reward > 0) {
            IERC20(rewardorToken).safeApprove(exchange, 0);
            IERC20(rewardorToken).safeApprove(exchange, _reward);

            address[] memory path = new address[](3);
            path[0] = rewardorToken;
            path[1] = intermediaryToken;
            path[2] = want;

            Uni(exchange).swapExactTokensForTokens(_reward, unint256(0), path, address(this), now.add(1800));
        }
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            uint256 _fee = _want.mul(performanceFee).div(performanceMax);
            IERC20(want).safeTransfer(IController(controller).rewards(), _fee);
            deposit();
        }
    }

    function _withdrawSome(uint256 _amount) internal returns (uint256) {
        uint256 b = balanceOfDepositToken();
        uint256 bT = balanceOfDepositTokenInWantToken();
        // can have unintentional rounding errors
        uint256 amount = (b.mul(_amount)).div(bT).add(1);
        uint256 _before = IERC20(want).balanceOf(address(this));
        _withdrawDepositToken(amount);
        uint256 _after = IERC20(want).balanceOf(address(this));
        uint256 _withdrew = _after.sub(_before);
        return _withdrew;
    }

    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function _withdrawDepositToken(uint256 amount) internal {
        cToken(depositorToken).redeem(amount);
    }

    function balanceOfDepositTokenInWantToken() public view returns (uint256) {
        // Mantisa 1e18 to decimals
        uint256 b = balanceOfDepositToken();
        if (b > 0) {
            b = b.mul(cToken(depositorToken).exchangeRateStored().div(1e18));
        }
        return b;
    }

    function balanceOfDepositToken() public view returns (uint256) {
        return IERC20(depositorToken).balanceOf(address(this));
    }

    function balanceOf() public view returns (uint256) {
        return balanceOfWant().add(balanceOfDepositTokenInWantToken());
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
}
