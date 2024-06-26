// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { ERC20Mintable } from "test/utils/ERC20Mintable.sol";
import { IPoster } from "@daohaus/baal-contracts/contracts/interfaces/IPoster.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { AccountRegistry } from "src/ERC6551/erc6551/ERC6551Registry.sol";
import { IRegistry } from "src/interfaces/IERC6551Registry.sol";
import { AccountERC6551 } from "src/ERC6551/erc6551/ERC6551Module.sol";
import { MinimalReceiver } from "src/lib/MinimalReceiver.sol";

import { CookieNFT } from "src/ERC6551/nft/CookieNFT.sol";
import { CookieJarCore } from "src/core/CookieJarCore.sol";
import { CookieJarFactory } from "src/factory/CookieJarFactory.sol";

import { ModuleProxyFactory } from "@gnosis.pm/zodiac/contracts/factory/ModuleProxyFactory.sol";

import { ERC20CookieJar6551 } from "src/ERC6551/ERC20CookieJar6551.sol";

contract ERC20CookieJar6551Test is PRBTest, StdCheats {
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal owner = makeAddr("owner");

    AccountERC6551 public implementation;
    AccountRegistry public accountRegistry;

    CookieJarCore public cookieJarImp;
    CookieJarFactory public cookieJarSummoner;
    CookieNFT public cookieJarNFT;

    ERC20CookieJar6551 public erc20CookieJarImpl;

    ERC20Mintable internal mockErc20 = new ERC20Mintable("Mock", "MCK");

    ModuleProxyFactory public moduleProxyFactory;

    function setUp() public {
        implementation = new AccountERC6551();
        accountRegistry = new AccountRegistry();

        cookieJarSummoner = new CookieJarFactory(owner);

        erc20CookieJarImpl = new ERC20CookieJar6551();

        moduleProxyFactory = new ModuleProxyFactory();

        vm.prank(owner);
        cookieJarSummoner.setProxyFactory(address(moduleProxyFactory));

        cookieJarNFT = new CookieNFT(address(accountRegistry), address(implementation), address(cookieJarSummoner));
    }

    function testCookieMint() public returns (address account, address cookieJar, uint256 tokenId) {
        uint256 cookieAmount = 1e16;
        uint256 periodLength = 3600;
        address cookieToken = address(cookieJarImp);
        address[] memory allowList = new address[](0);
        string memory details =
            "{\"type\":\"List\",\"name\":\"Moloch Pastries\",\"description\":\"This is where you add some more content\",\"link\":\"app.daohaus.club/0x64/0x0....666\"}";

        bytes memory _initializer =
            abi.encode(alice, periodLength, cookieAmount, cookieToken, address(mockErc20), 1 ether);
        (account, cookieJar, tokenId) =
            cookieJarNFT.cookieMint(address(erc20CookieJarImpl), _initializer, details, address(0), 0);

        (bool sent,) = payable(account).call{ value: 1 ether }("");
        require(sent, "Failed to send Ether?");

        assertEq(cookieJarNFT.balanceOf(alice), 1);
    }

    function testCookieErc20Withdraw() public {
        (address account, address cookieJar,) = testCookieMint();
        AccountERC6551 accountContract = AccountERC6551(payable(account));
        ERC20CookieJar6551 erc20CookieJarContract = ERC20CookieJar6551(cookieJar);

        vm.startPrank(bob);

        vm.expectRevert(abi.encodeWithSignature("NOT_ALLOWED(string)", "not a member"));
        ERC20CookieJar6551(cookieJar).reachInJar(bob, "test");

        mockErc20.mint(bob, 1 ether);

        ERC20CookieJar6551(cookieJar).reachInJar(bob, "test");
        // new balance should be 1 eth minus cookie amount
        assertEq(account.balance, 1e18 - 1e16);

        vm.stopPrank();
    }
}
