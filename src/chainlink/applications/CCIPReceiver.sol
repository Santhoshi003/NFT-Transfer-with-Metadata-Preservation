// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Client} from "../libraries/Client.sol";

abstract contract CCIPReceiver {
    address internal immutable i_router;

    constructor(address router) {
        i_router = router;
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal virtual;

    function getRouter() public view returns (address) {
        return i_router;
    }
}
