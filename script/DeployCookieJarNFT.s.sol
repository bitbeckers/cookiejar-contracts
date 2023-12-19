// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { Script } from "forge-std/Script.sol";
import { CookieNFT } from "src/ERC6551/nft/CookieNFT.sol";
import { ImpCookieJar6551 } from "src/ERC6551/ImpCookieJar6551.sol";
import { AccountERC6551 } from "src/ERC6551/erc6551/ERC6551Module.sol";
import { AccountRegistry } from "src/ERC6551/erc6551/ERC6551Registry.sol";

import { ZodiacBaalCookieJar } from "../src/SafeModule/BaalCookieJar.sol";
import { ZodiacERC20CookieJar } from "../src/SafeModule/ERC20CookieJar.sol";
import { ZodiacERC721CookieJar } from "../src/SafeModule/ERC721CookieJar.sol";
import { ZodiacListCookieJar } from "../src/SafeModule/ListCookieJar.sol";
import { ZodiacOpenCookieJar } from "../src/SafeModule/OpenCookieJar.sol";
import { CookieJarFactory } from "../src/factory/CookieJarFactory.sol";
import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";
import { ModuleProxyFactory } from "@gnosis.pm/zodiac/contracts/factory/ModuleProxyFactory.sol";

//import forge console
import { console } from "forge-std/console.sol";

error NoCookieJarFactory(string message);

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract DeployCookieJarNFT is Script {
    address internal deployer;
    uint256 internal deployerPk;

    address internal cookieJarFactory;

    // 6551
    address internal listCookieJar6551;
    address internal accountImp;
    address internal registry = 0x02101dfB77FDE026414827Fdc604ddAF224F0921;
    address internal nft;

    function setUp() public virtual {
        // string memory mnemonic = vm.envString("MNEMONIC");
        // if (bytes(mnemonic).length > 0) {
        //     console.log("Using mnemonic");

        //     (deployer,) = deriveRememberKey(mnemonic, 0);
        // } else {
        console.log("Using private key");

        deployerPk = vm.envUint("PRIVATE_KEY");
        // }
    }

    function run() public {
        console.log('"deployer": "%s",', deployer);

        if (deployer != address(0)) vm.startBroadcast(deployer);
        else vm.startBroadcast(deployerPk);

        // Zodiac
        cookieJarFactory = block.chainid == 100
            ? 0xD858ce60102BCEa272a6FA36B2E1770877B8Fa45
            : block.chainid == 5
                ? 0x8f60853B55847d91331106acc303F4A8676efc8B
                : block.chainid == 10
                    ? 0xD858ce60102BCEa272a6FA36B2E1770877B8Fa45
                    : block.chainid == 11_155_111 ? 0xD858ce60102BCEa272a6FA36B2E1770877B8Fa45 : address(0);

        if (cookieJarFactory == address(0)) {
            vm.stopBroadcast();
            revert NoCookieJarFactory("No cookie jar factory found for chain id");
        }

        // 6551
        listCookieJar6551 = address(new ImpCookieJar6551());
        accountImp = address(new AccountERC6551());
        nft = address(
            new CookieNFT(
                registry, // account registry
                accountImp,
                cookieJarFactory,
                listCookieJar6551
            )
        );

        // solhint-disable quotes
        console.log(block.chainid);
        console.log('"cookieJarFactory": "%s",', cookieJarFactory);
        console.log('"account": "%s",', accountImp);
        console.log('"registry": "%s",', registry);
        console.log('"nft": "%s",', nft);
        // solhint-enable quotes

        vm.stopBroadcast();
    }
}