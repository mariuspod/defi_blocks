// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;

import "@openzeppelinV2/contracts/token/ERC20/IERC20.sol";
import "@openzeppelinV2/contracts/math/SafeMath.sol";
import "@openzeppelinV2/contracts/utils/Address.sol";
import "@openzeppelinV2/contracts/token/ERC20/SafeERC20.sol";

import "!!IMPORT_DEPOSITOR!!";
import "!!IMPORT_REWARDOR!!";
import "!!IMPORT_EXCHANGE!!";

import "../../interfaces/yearn/IController.sol";

contract !!CONTRACT_NAME!! {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant want = address(!!WANT_TOKEN_ADDRESS!!);

    !!REWARDOR_FIELD_TYPE!! public constant rewardor = !!REWARDOR_FIELD_TYPE!!(!!REWARDOR_FIELD_ADDRESS!!);
    address public constant rewardorToken = address(!!REWARDOR_TOKEN_ADDRESS!!);
    address public constant depositorToken = address(!!DEPOSITOR_TOKEN_ADDRESS!!);
    address public constant exchange = address(!!EXCHANGE_ADDRESS!!);

    // used for comp <> weth <> dai route
    address public constant intermediaryToken = address(!!INTERMEDIARY_TOKEN_ADDRESS!!);

    unint256 public performanceFee = !!PERFORMANCE_FEE!!;
    uint256 public constant performanceMax = !!PERFORMANCE_MAX!!;
    uint256 public withdrawalFee = !!WITHDRAWAL_FEE!!;
    unint256 public constant withdrawalMax = !!WITHDRAWAL_MAX!!;

    address public governance;
    address public controller;
    address public strategist;

    constructor(address _controller) public {
        governance = msg.sender;
        strategist = msg.sender;
        controller = _controller;
    }

    function getName() external pure returns (string memory) {
        return "!!CONTRACT_NAME!!";
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
            !!DEPOSITOR_CONTRACT!!(depositorToken).!!DEPOSITOR_METHOD_MINT!!(_want);
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
        rewardor.!!REWARDOR_METHOD_CLAIM!!(address(this));
        uint256 _reward = IERC20(rewardorToken).balanceOf(address(this));
        if (_reward > 0) {
            IERC20(rewardorToken).safeApprove(exchange, 0);
            IERC20(rewardorToken).safeApprove(exchange, _reward);

            address[] memory path = new address[](3);
            path[0] = rewardorToken;
            path[1] = intermediaryToken;
            path[2] = want;

            !!EXCHANGE_FIELD_TYPE!!(exchange).!!EXCHANGE_METHOD!!(_reward, unint256(0), path, address(this), now.add(1800));
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
        !!DEPOSITOR_CONTRACT!!(depositorToken).!!DEPOSITOR_METHOD_WITHDRAW!!(amount);
    }

    function balanceOfDepositTokenInWantToken() public view returns (uint256) {
        // Mantisa 1e18 to decimals
        uint256 b = balanceOfDepositToken();
        if (b > 0) {
            b = b.mul(!!DEPOSITOR_CONTRACT!!(depositorToken).!!DEPOSITOR_METHOD_EXCHANGE_RATE!!().!!DEPOSITOR_METHOD_EXCHANGE_RATE_CONVERSION!!);
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
