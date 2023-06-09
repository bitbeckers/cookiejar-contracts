// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import {MappedAllowlist} from "src/core/allowlists/MappedAllowlist.sol";
import {ZodiacCookieJar} from "src/SafeModule/ZodiacCookieJar.sol";

contract ZodiacListCookieJar is MappedAllowlist, ZodiacCookieJar {
    function setUp(bytes memory _initializationParams) public override(MappedAllowlist, ZodiacCookieJar) {
        MappedAllowlist.setUp(_initializationParams);

        ZodiacCookieJar.setUp(_initializationParams);
    }

    function isAllowList(address user) public view override returns (bool) {
        return MappedAllowlist._isAllowList(user);
    }

    function setAllowList(address _address, bool _isAllowed) external onlyOwner {
        allowList[_address] = _isAllowed;
    }

    function batchAllowList(address[] memory _addresses, bool[] memory _isAllowed) external onlyOwner {
        MappedAllowlist._batchAllowList(_addresses, _isAllowed);
    }
}
