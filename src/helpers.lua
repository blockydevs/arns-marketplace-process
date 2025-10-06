local activity = require('activity')

local helpers = {}

-- Helper function to record match and send activity data
function helpers.recordMatch(args, currentOrderEntry, validPair, calculatedFillAmount)
	-- Record the successful match
	local match = {
		Id = currentOrderEntry.Id,
		Quantity = calculatedFillAmount,
		Price = tostring(currentOrderEntry.Price)
	}

	-- Record execution internally (no messaging)
	activity.recordExecutedOrder({
		Id = currentOrderEntry.Id,
		MatchId = args.orderId,
		DominantToken = validPair[2],
		SwapToken = validPair[1],
		Sender = currentOrderEntry.Creator,
		Receiver = args.sender,
		Quantity = calculatedFillAmount,
		Price = args.executionPrice or tostring(currentOrderEntry.Price),
		CreatedAt = args.createdAt,
		EndedAt = args.createdAt,
		ExecutionTime = args.createdAt
	})

	return match
end

return helpers