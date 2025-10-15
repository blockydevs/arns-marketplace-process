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

local TEST_TREASURY = 'TEST_TREASURY_ADDRESS_ABCDEFGHIJKLMNOPQRSTUVWXYZ'
local DEFAULT_TREASURY = 'cqnFNTEDGuWOOpnrrdoQZ262Be8e_kGT2na-BlGFyks'

local testCases = {
	{
		description = 'sends fee when original > calculated',
		setup = function()
			TREASURY_ADDRESS = TEST_TREASURY
			reset()
		end,
		args = { original = '1000', calculated = '995', feeToken = 'ARIO_TOKEN' },
		expected = {
			{ Target = 'ARIO_TOKEN', Action = 'Transfer', Tags = { Recipient = TEST_TREASURY, Quantity = '5' } }
		}
	},
	{
		description = 'no send when fee equals zero',
		setup = function()
			TREASURY_ADDRESS = TEST_TREASURY
			reset()
		end,
		args = { original = '1000', calculated = '1000', feeToken = 'ARIO_TOKEN' },
		expected = {}
	},
	{
		description = 'no send when fee negative',
		setup = function()
			TREASURY_ADDRESS = TEST_TREASURY
			reset()
		end,
		args = { original = '900', calculated = '995', feeToken = 'ARIO_TOKEN' },
		expected = {}
	},
	{
		description = 'no send when TREASURY_ADDRESS is nil',
		setup = function()
			TREASURY_ADDRESS = nil
			reset()
		end,
		args = { original = '1000', calculated = '995', feeToken = 'ARIO_TOKEN' },
		expected = {}
	},
	{
		description = 'no send when TREASURY_ADDRESS is default placeholder',
		setup = function()
			TREASURY_ADDRESS = DEFAULT_TREASURY
			reset()
		end,
		args = { original = '1000', calculated = '995', feeToken = 'ARIO_TOKEN' },
		expected = {}
	},
}

for _, tc in ipairs(testCases) do
	utils.test('sendFeeToTreasury - ' .. tc.description,
		function()
			tc.setup()
			utils.sendFeeToTreasury(tc.args.original, tc.args.calculated, tc.args.feeToken)
			return sentMessages
		end,
		tc.expected
	)
end

print('Utils sendFeeToTreasury Tests completed!')
utils.testSummary()
