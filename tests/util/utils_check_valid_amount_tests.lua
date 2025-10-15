package.path = package.path .. ';../src/?.lua'

local utils = require('utils')

local testCases = {
	-- Valid positive amounts
	{ input = '1', expected = true, description = 'positive amount as string' },
	{ input = 1, expected = true, description = 'positive amount as number' },
	{ input = '5000000000000000000000000', expected = true, description = 'very large positive amount as string' },

	-- Zero and negative
	{ input = '0', expected = false, description = 'zero amount as string' },
	{ input = '-1', expected = false, description = 'negative amount as string' },
}

for _, tc in ipairs(testCases) do
	utils.test('checkValidAmount should return ' .. tostring(tc.expected) .. ' for ' .. tc.description,
		function()
			return utils.checkValidAmount(tc.input)
		end,
		tc.expected
	)
end

print('Utils checkValidAmount Tests completed!')
utils.testSummary()
