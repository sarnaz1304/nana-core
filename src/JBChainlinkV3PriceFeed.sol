// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import {IJBPriceFeed} from "./interfaces/IJBPriceFeed.sol";
import {JBFixedPointNumber} from "./libraries/JBFixedPointNumber.sol";

/// @notice An `IJBPriceFeed` implementation that reports prices from a Chainlink `AggregatorV3Interface`.
contract JBChainlinkV3PriceFeed is IJBPriceFeed {
    // A library that provides utility for fixed point numbers.
    using JBFixedPointNumber for uint256;

    //*********************************************************************//
    // --------------------------- custom errors ------------------------- //
    //*********************************************************************//

    error STALE_PRICE();
    error INCOMPLETE_ROUND();
    error NEGATIVE_PRICE();

    //*********************************************************************//
    // ---------------- public stored immutable properties --------------- //
    //*********************************************************************//

    /// @notice The Chainlink feed that prices are reported from.
    AggregatorV3Interface public immutable FEED;

    //*********************************************************************//
    // ------------------------- external views -------------------------- //
    //*********************************************************************//

    /// @notice Gets the current price (per 1 unit) from the feed.
    /// @param decimals The number of decimals the return value should use.
    /// @return The current unit price from the feed, as a fixed point number with the specified number of decimals.
    function currentUnitPrice(uint256 decimals) external view override returns (uint256) {
        // Get the latest round information from the feed.
        // slither-disable-next-line unused-return
        (uint80 roundId, int256 price,, uint256 updatedAt, uint80 answeredInRound) = FEED.latestRoundData();

        // Make sure the price isn't stale.
        if (answeredInRound < roundId) revert STALE_PRICE();

        // Make sure the round is finished.
        if (updatedAt == 0) revert INCOMPLETE_ROUND();

        // Make sure the price is positive.
        if (price < 0) revert NEGATIVE_PRICE();

        // Get a reference to the number of decimals the feed uses.
        uint256 feedDecimals = FEED.decimals();

        // Return the price, adjusted to the specified number of decimals.
        return uint256(price).adjustDecimals({decimals: feedDecimals, targetDecimals: decimals});
    }

    //*********************************************************************//
    // -------------------------- constructor ---------------------------- //
    //*********************************************************************//

    /// @param feed The Chainlink feed to report prices from.
    constructor(AggregatorV3Interface feed) {
        FEED = feed;
    }
}
