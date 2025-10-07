## English Auction Bidding (with refund to previous highest bidder)

```mermaid
sequenceDiagram
    autonumber
    actor Bidder as Bidder (User/App)
    participant ARIO as ARIO Token Process (bidding token)
    participant Market as Marketplace Process (`src/process.lua`/`src/ucm.lua`/`src/english_auction.lua`)
    participant Activity as Activity Process (`src/activity.lua`)
    participant Prev as Previous Highest Bidder

    Bidder->>ARIO: sendMessage(... X-Order-Action=Create-Order, X-Order-Type=english, Quantity=bidAmount)
    ARIO->>Market: Transfer with forwarded X-* tags

    Note over Market: Build orderArgs; route to `ucm.createOrder` → `english_auction.handleAntOrder`

    Market->>Market: Validate auction exists, active, not expired
    Market->>Market: validateBidAmount(bidAmount, currentHighest?, minStartPrice)
    alt Invalid bid
        Market-->>Bidder: Validation-Error (message)
    else Valid bid
        opt There is a previous highest bid
            Market->>ARIO: Transfer(Recipient=Prev, Quantity=prevAmount)
            Market-->>Prev: Bid-Returned (OrderId, Amount)
        end
        Market->>Market: Record bid; update HighestBid/HighestBidder
        Market->>Activity: recordAuctionBid(...)
        Market-->>Bidder: Bid-Success (OrderId, BidAmount, X-Group-ID)
    end
```


