//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {IAggregatorV3Interface} from "./interfaces/IAggregatorV3Interface.sol";

import {PythStructs} from "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";
import {IPyth} from "@pythnetwork/pyth-sdk-solidity/IPyth.sol";

interface SwitchPairDynamic {
    function current(
        address token,
        uint256 amountIn
    ) external view returns (uint256);
}

contract MuteAggreagator is IAggregatorV3Interface {
    SwitchPairDynamic pool =
        SwitchPairDynamic(0xb85feb6aF3412d690DFDA280b73EaED73a2315bC);

    IAggregatorV3Interface ethAggregrator =
        IAggregatorV3Interface(0x517F9cd13fE63e698d0466ad854cDba5592eeA73);

    address mute = 0x0e97C7a0F8B2C9885C8ac9fC6136e829CbC21d42;

    function _getPrice() internal view returns (int256) {
        IAggregatorV3Interface pyth = IAggregatorV3Interface(ethAggregrator);

        int256 tokenPrice = int256(pool.current(mute, 1e18));
        int256 ethOraclePrice = pyth.latestAnswer() * 1e10;

        return (tokenPrice * int256(ethOraclePrice)) / 1e28;
    }

    function decimals() external pure override returns (uint8) {
        return 8;
    }

    function description() external pure override returns (string memory) {
        return "";
    }

    function version() external pure override returns (uint256) {
        return 0;
    }

    function getRoundData(
        uint80 _roundId
    )
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (_roundId, _getPrice(), 0, 0, _roundId);
    }

    function latestRoundData()
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (0, _getPrice(), 0, 0, 0);
    }

    function latestAnswer() external view override returns (int256) {
        return _getPrice();
    }
}
