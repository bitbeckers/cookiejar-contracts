// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { Script } from "forge-std/Script.sol";
import { CookieNFT } from "src/ERC6551/nft/CookieNFT.sol";
import { AccountERC6551 } from "src/ERC6551/erc6551/ERC6551Module.sol";
import { AccountRegistry } from "src/ERC6551/erc6551/ERC6551Registry.sol";

import { ZodiacBaalCookieJar } from "../src/SafeModule/BaalCookieJar.sol";
import { ZodiacERC20CookieJar } from "../src/SafeModule/ERC20CookieJar.sol";
import { ZodiacERC721CookieJar } from "../src/SafeModule/ERC721CookieJar.sol";
import { ZodiacListCookieJar } from "../src/SafeModule/ListCookieJar.sol";
import { ZodiacOpenCookieJar } from "../src/SafeModule/OpenCookieJar.sol";
import { CookieJarFactory } from "../src/factory/CookieJarFactory.sol";
import { ModuleProxyFactory } from "@gnosis.pm/zodiac/contracts/factory/ModuleProxyFactory.sol";

//import forge console
import { console } from "forge-std/console.sol";

error NoDeployer();

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract DeployCookieJarModule is Script {
    address internal deployer;
    uint256 internal deployerPk;

    // Zodiac
    address internal baalCookieJar;
    address internal erc20CookieJar;
    address internal erc721CookieJar;
    address internal listCookieJar;
    address internal openCookieJar;
    address internal cookieJarFactory;

    // Deterministic deployment
    bytes32 salt = keccak256("v0.2");

    function setUp() public virtual {
        string memory mnemonic = vm.envString("MNEMONIC");
        if (bytes(mnemonic).length > 0) {
            console.log("Using mnemonic");

            (deployer,) = deriveRememberKey(mnemonic, 0);
        }
    }

    function run() public {
        console.log('"deployer": "%s",', deployer);

        if (deployer == address(0)) {
            revert NoDeployer();
        }

        vm.startBroadcast(deployer);

        // Modules

        // Baal
        baalCookieJar = address(new ZodiacBaalCookieJar{ salt: salt }());

        // ERC20
        erc20CookieJar = address(new ZodiacERC20CookieJar{ salt: salt }());

        // ERC721
        erc721CookieJar = address(new ZodiacERC721CookieJar{ salt: salt }());

        // List
        listCookieJar = address(new ZodiacListCookieJar{ salt: salt }());

        // Open
        openCookieJar = address(new ZodiacOpenCookieJar{ salt: salt }());

        // solhint-disable quotes
        console.log(block.chainid);
        console.log('"baalCookieJar": "%s",', baalCookieJar);
        console.log('"erc20CookieJar": "%s",', erc20CookieJar);
        console.log('"erc721CookieJar": "%s",', erc721CookieJar);
        console.log('"listCookieJar": "%s",', listCookieJar);
        console.log('"openCookieJar": "%s",', openCookieJar);

        // solhint-enable quotes

        vm.stopBroadcast();
    }
}
