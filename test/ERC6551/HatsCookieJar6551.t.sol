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

import { HatsCookieJar6551 } from "src/ERC6551/HatsCookieJar6551.sol";

import { IHats } from "src/interfaces/IHats.sol";

contract HatsCookieJar6551Test is PRBTest, StdCheats {
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal owner = makeAddr("owner");

    AccountERC6551 public implementation;
    AccountRegistry public accountRegistry;

    CookieJarCore public cookieJarImp;
    CookieJarFactory public cookieJarSummoner;
    CookieNFT public cookieJarNFT;

    HatsCookieJar6551 public hatsCookieJar6551Impl;

    ModuleProxyFactory public moduleProxyFactory;

    /// @notice https://docs.hatsprotocol.xyz/using-hats/hats-protocol-supported-chains
    /// @notice The address of the Hats Protocol contract.
    address public constant HATS_ADDRESS = 0x3bc1A0Ad72417f2d411118085256fC53CBdDd137;

    uint256 public hatId;

    function setUp() public {
        implementation = new AccountERC6551();
        accountRegistry = new AccountRegistry();

        cookieJarSummoner = new CookieJarFactory(owner);

        hatsCookieJar6551Impl = new HatsCookieJar6551();

        moduleProxyFactory = new ModuleProxyFactory();

        vm.prank(owner);
        cookieJarSummoner.setProxyFactory(address(moduleProxyFactory));

        cookieJarNFT = new CookieNFT(address(accountRegistry), address(implementation), address(cookieJarSummoner));
    }

    function testCookieMint() public returns (address account, address cookieJar, uint256 tokenId) {
        uint256 cookieAmount = 1e16;
        uint256 periodLength = 3600;
        address cookieToken = address(cookieJarImp);
        string memory details =
            "{\"type\":\"List\",\"name\":\"Moloch Pastries\",\"description\":\"This is where you add some more content\",\"link\":\"app.daohaus.club/0x64/0x0....666\"}";

        bytes memory _initializer = abi.encode(alice, periodLength, cookieAmount, cookieToken, hatId);
        (account, cookieJar, tokenId) =
            cookieJarNFT.cookieMint(address(hatsCookieJar6551Impl), _initializer, details, address(0), 0);

        (bool sent,) = payable(account).call{ value: 1 ether }("");
        require(sent, "Failed to send Ether?");

        assertEq(cookieJarNFT.balanceOf(alice), 1);
    }

    function testCookieHatsWithdraw() public {
        (address account, address cookieJar,) = testCookieMint();
        HatsCookieJar6551 hatsCookieJar = HatsCookieJar6551(cookieJar);

        vm.startPrank(bob);

        vm.mockCall(HATS_ADDRESS, abi.encodeWithSelector(IHats.isWearerOfHat.selector), abi.encode(false));

        vm.expectRevert(abi.encodeWithSignature("NOT_ALLOWED(string)", "not a member"));
        hatsCookieJar.reachInJar(bob, "test");

        assertEq(account.balance, 1e18);

        vm.mockCall(HATS_ADDRESS, abi.encodeWithSelector(IHats.isWearerOfHat.selector), abi.encode(true));

        hatsCookieJar.reachInJar(bob, "test");

        // new balance should be 1 eth minus cookie amount
        assertEq(account.balance, 1e18 - 1e16);

        vm.stopPrank();
    }
}
