// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {KittyPool} from "../../src/KittyPool.sol";
import {KittyCoin} from "../../src/KittyCoin.sol";
import {KittyVault, IAavePool} from "src/KittyVault.sol";
import {DeployKittyFi, HelperConfig} from "script/DeployKittyFi.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";
import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./utils/Cheats.sol";

contract InvariantTest {
    StdCheats cheats = StdCheats(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    KittyCoin kittyCoin;
    KittyPool kittyPool;
    KittyVault wethVault;
    HelperConfig.NetworkConfig config;

    address meowntainer;
    address weth;
    uint256 AMOUNT = 10e18;
    uint256 COLLATERAL_PERCENT = 169;
    uint256 COLLATERAL_PRECISION = 100;

    constructor() {
        HelperConfig helperConfig = new HelperConfig();
        config = helperConfig.getNetworkConfig();
        weth = config.weth;
        meowntainer = msg.sender;

        kittyPool = new KittyPool(meowntainer, config.euroPriceFeed, config.aavePool);

        cheats.prank(meowntainer);
        kittyPool.meownufactureKittyVault(weth, config.ethUsdPriceFeed);

        kittyCoin = KittyCoin(kittyPool.getKittyCoin());
        wethVault = KittyVault(kittyPool.getTokenToVault(weth));
    }

    function testConstructorValuesSetUpCorrectly() public {
        assert(address(kittyPool.getMeowntainer()) == meowntainer);
        assert(address(kittyPool.getKittyCoin()) == address(kittyCoin));
        assert(address(kittyPool.getTokenToVault(weth)) == address(wethVault));
        assert(address(kittyPool.getAavePool()) == config.aavePool);
    }

    function testInvariant_noUserIsUnderCollateralized() public {
        uint256 userDebt = kittyPool.getKittyCoinMeownted(msg.sender);

        uint256 userCollateral = kittyPool.getUserMeowllateralInEuros(msg.sender);
        uint256 requiredCollateral = (userDebt * COLLATERAL_PERCENT) / COLLATERAL_PRECISION;

        assert(userCollateral >= requiredCollateral);
    }

    function testUserDepositAndMintsKittyCoin(uint256 _amount, uint128 amountToMint) public {
        cheats.startPrank(msg.sender);
        ERC20Mock(weth).mint(address(msg.sender), _amount);
        IERC20(weth).approve(address(wethVault), _amount);
        kittyPool.depawsitMeowllateral(weth, _amount);

        kittyPool.meowintKittyCoin(amountToMint);

        cheats.stopPrank();
        assert(kittyPool.getKittyCoinMeownted(msg.sender) == amountToMint);
    }

    function invariant_kittyCoinSupplyIntegrity() public {
        uint256 totalSupply = kittyCoin.totalSupply();
        uint256 sumMinted = kittyPool.getKittyCoinMeownted(msg.sender);
        assert(totalSupply == sumMinted);
    }

    function invariant_kittyCoinBurnt(uint256 amount) public {
        if (amount = 0) {
            uint256 totalSupply = kittyCoin.totalSupply();
            kittyPool.burnKittyCoin(msg.sender, amount);
            uint256 totalSupplyAfter = kittyCoin.totalSupply();
            assert(totalSupplyAfter < totalSupply);
        }
    }
}
