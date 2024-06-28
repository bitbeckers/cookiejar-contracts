// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { Script } from "forge-std/Script.sol";
import { CookieNFT } from "src/ERC6551/nft/CookieNFT.sol";
import { AccountERC6551 } from "src/ERC6551/erc6551/ERC6551Module.sol";
import { AccountRegistry } from "src/ERC6551/erc6551/ERC6551Registry.sol";

import { CookieJarFactory } from "../src/factory/CookieJarFactory.sol";
import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";
import { ModuleProxyFactory } from "@gnosis.pm/zodiac/contracts/factory/ModuleProxyFactory.sol";

//import forge console
import { console } from "forge-std/console.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract DeployCookieJarFactory is Script {
    address internal deployer;
    uint256 internal deployerPk;

    // Proxy factory
    address internal cookieJarFactory;
    address internal safeModuleSummoner;
    address internal moduleProxyFactory;

    // Deterministic deployment
    bytes32 salt = keccak256("v0.7");

    function setUp() public virtual {
        string memory mnemonic = vm.envString("MNEMONIC");
        console.log("Using mnemonic");

        (deployer,) = deriveRememberKey(mnemonic, 0);

        // Optimism
        if (block.chainid == 10) moduleProxyFactory = 0xC22834581EbC8527d974F8a1c97E1bEA4EF910BC;

        // Hardhat
        if (block.chainid == 31_337) moduleProxyFactory = address(new ModuleProxyFactory());
        // Default
        else moduleProxyFactory = 0x00000000000DC7F163742Eb4aBEf650037b1f588;
    }

    function run() public {
        console.log('"deployer": "%s",', deployer);

        if (deployer != address(0)) vm.startBroadcast(deployer);
        else vm.startBroadcast(deployerPk);

        // Zodiac
        cookieJarFactory = address(new CookieJarFactory{ salt: salt }(deployer));
        CookieJarFactory(cookieJarFactory).setProxyFactory(moduleProxyFactory);

        // solhint-disable quotes
        console.log(block.chainid);
        console.log('"cookieJarFactory": "%s",', cookieJarFactory);

        // solhint-enable quotes

        vm.stopBroadcast();
    }
}
