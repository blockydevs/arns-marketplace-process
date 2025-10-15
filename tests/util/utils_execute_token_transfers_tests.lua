package.path = package.path .. ';../src/?.lua'

local utils = require('utils')

-- Mock ao.send to capture messages per test
local sentMessages

ao = {
	send = function(msg)
		table.insert(sentMessages, msg)
	end
}

local function reset()
	sentMessages = {}
end

-- Helpers/fixtures
local SELL_TOKEN = 'SELL_TOKEN_PROCESS'
local BUY_TOKEN = 'BUY_TOKEN_PROCESS'

local function makeArgs(overrides)
	local base = {
		sender = 'buyer-addr',
		swapToken = BUY_TOKEN,
		target = 'ignored',
	}
	for k, v in pairs(overrides or {}) do base[k] = v end
	return base
end

local function makeOrderEntry(overrides)
	local base = {
		Creator = 'seller-addr'
	}
	for k, v in pairs(overrides or {}) do base[k] = v end
	return base
end

local testCases = {
	{
		description = 'sends tokens to seller and buyer with expected quantities (no fees recorded)',
		args = makeArgs({}),
		order = makeOrderEntry({}),
		pair = { SELL_TOKEN, BUY_TOKEN },
		calcSend = '995',
		calcFill = '1',
		accrueFrom = nil,
		expectedMessages = {
			{ Target = SELL_TOKEN, Action = 'Transfer', Tags = { Recipient = 'seller-addr', Quantity = '995' } },
			{ Target = BUY_TOKEN, Action = 'Transfer', Tags = { Recipient = 'buyer-addr', Quantity = '1' } },
		},
		expectedFeeDelta = 0,
	},
	{
		description = 'records fee when originalSendAmount greater than calculatedSendAmount',
		args = makeArgs({ originalSendAmount = '1000' }),
		order = makeOrderEntry({}),
		pair = { SELL_TOKEN, BUY_TOKEN },
		calcSend = '995',
		calcFill = '1',
		expectedMessages = {
			{ Target = SELL_TOKEN, Action = 'Transfer', Tags = { Recipient = 'seller-addr', Quantity = '995' } },
			{ Target = BUY_TOKEN, Action = 'Transfer', Tags = { Recipient = 'buyer-addr', Quantity = '1' } },
		},
		expectedFeeDelta = 5,
	},
	{
		description = 'does not record fee when original equals calculated',
		args = makeArgs({ originalSendAmount = '995' }),
		order = makeOrderEntry({}),
		pair = { SELL_TOKEN, BUY_TOKEN },
		calcSend = '995',
		calcFill = '1',
		expectedMessages = {
			{ Target = SELL_TOKEN, Action = 'Transfer', Tags = { Recipient = 'seller-addr', Quantity = '995' } },
			{ Target = BUY_TOKEN, Action = 'Transfer', Tags = { Recipient = 'buyer-addr', Quantity = '1' } },
		},
		expectedFeeDelta = 0,
	},
	{
		description = 'does not record fee when original less than calculated',
		args = makeArgs({ originalSendAmount = '990' }),
		order = makeOrderEntry({}),
		pair = { SELL_TOKEN, BUY_TOKEN },
		calcSend = '995',
		calcFill = '1',
		expectedMessages = {
			{ Target = SELL_TOKEN, Action = 'Transfer', Tags = { Recipient = 'seller-addr', Quantity = '995' } },
			{ Target = BUY_TOKEN, Action = 'Transfer', Tags = { Recipient = 'buyer-addr', Quantity = '1' } },
		},
		expectedFeeDelta = 0,
	},
}

for _, tc in ipairs(testCases) do
	utils.test('executeTokenTransfers - ' .. tc.description,
		function()
			reset()
			local beforeFees = AccruedFeesAmount or 0
			utils.executeTokenTransfers(tc.args, tc.order, tc.pair, tc.calcSend, tc.calcFill)
			local afterFees = AccruedFeesAmount or 0
			return { messages = sentMessages, feeDelta = afterFees - beforeFees }
		end,
		{ messages = tc.expectedMessages, feeDelta = tc.expectedFeeDelta }
	)
end

print('Utils executeTokenTransfers Tests completed!')
utils.testSummary()
