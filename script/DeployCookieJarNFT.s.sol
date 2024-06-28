// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { Script } from "forge-std/Script.sol";
import { CookieNFT } from "src/ERC6551/nft/CookieNFT.sol";
import { AccountERC6551 } from "src/ERC6551/erc6551/ERC6551Module.sol";
import { AccountRegistry } from "src/ERC6551/erc6551/ERC6551Registry.sol";

// 6551
import { BaalCookieJar6551 } from "../src/ERC6551/BaalCookieJar6551.sol";
import { ERC20CookieJar6551 } from "../src/ERC6551/ERC20CookieJar6551.sol";
import { ERC721CookieJar6551 } from "../src/ERC6551/ERC721CookieJar6551.sol";
import { ListCookieJar6551 } from "../src/ERC6551/ListCookieJar6551.sol";
import { OpenCookieJar6551 } from "../src/ERC6551/OpenCookieJar6551.sol";
import { HatsCookieJar6551 } from "../src/ERC6551/HatsCookieJar6551.sol";

// Deploys
import { CookieJarFactory } from "../src/factory/CookieJarFactory.sol";
import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";
import { ModuleProxyFactory } from "@gnosis.pm/zodiac/contracts/factory/ModuleProxyFactory.sol";

//import forge console
import { console } from "forge-std/console.sol";

error NoCookieJarFactory(string message);

error NoDeployer();

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract DeployCookieJarNFT is Script {
    address internal deployer;
    uint256 internal deployerPk;

    address internal cookieJarFactory;

    // Implementations
    address internal baalCookieJar;
    address internal erc20CookieJar;
    address internal erc721CookieJar;
    address internal listCookieJar;
    address internal openCookieJar;
    address internal hatsCookieJar;

    // 6551
    address internal accountImp;
    address internal registry = 0x02101dfB77FDE026414827Fdc604ddAF224F0921;
    address internal nft;

    // Deterministic deployment
    bytes32 salt = keccak256("v0.7");

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

        // Get factory address
        cookieJarFactory = block.chainid == 11_155_111 ? 0x10864D3b5552735fD8B1Ddd6d5BddcF437e26Ae9 : 0x2f98e26f53D80315d70f6D4Cc76C21dfd2BF8F40;
        // cookieJarFactory = block.chainid == 10 ? 0x2f98e26f53D80315d70f6D4Cc76C21dfd2BF8F40 : address(0);


        if (cookieJarFactory == address(0)) {
            vm.stopBroadcast();
            revert NoCookieJarFactory("No cookie jar factory found for chain id");
        }

        // Deploy 6551 implementations

        // Baal
        console.log("Deploying BaalCookieJar");
        baalCookieJar = address(new BaalCookieJar6551{ salt: salt }());

        // ERC20
        console.log("Deploying ERC20CookieJar");
        erc20CookieJar = address(new ERC20CookieJar6551{ salt: salt }());

        // ERC721
        console.log("Deploying ERC721CookieJar");
        erc721CookieJar = address(new ERC721CookieJar6551{ salt: salt }());

        // List
        console.log("Deploying ListCookieJar");
        listCookieJar = address(new ListCookieJar6551{ salt: salt }());

        // Open
        openCookieJar = address(new OpenCookieJar6551{ salt: salt }());

        // Hats
        console.log("Deploying HatsCookieJar");
        hatsCookieJar = address(new HatsCookieJar6551{ salt: salt }());

        // 6551
        accountImp = address(new AccountERC6551());
        nft = address(
            new CookieNFT(
                registry, // account registry
                accountImp,
                cookieJarFactory
            )
        );

        // solhint-disable quotes
        console.log(block.chainid);
        console.log('"account": "%s",', accountImp);
        console.log('"registry": "%s",', registry);
        console.log('"nft": "%s",', nft);
        console.log('"baalCookieJar": "%s",', baalCookieJar);
        console.log('"erc20CookieJar": "%s",', erc20CookieJar);
        console.log('"erc721CookieJar": "%s",', erc721CookieJar);
        console.log('"listCookieJar": "%s",', listCookieJar);
        console.log('"openCookieJar": "%s",', openCookieJar);
        console.log('"hatsCookieJar": "%s",', hatsCookieJar);

        // solhint-enable quotes

        vm.stopBroadcast();
    }
}
