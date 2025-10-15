package.path = package.path .. ';../src/?.lua'

local utils = require('utils')

-- Parameterized tests for utils.calculateFillAmount
-- Note: calculateFillAmount uses math.floor on the numeric value and returns string
local testCases = {
	{ input = 0, expected = '0', description = 'zero integer' },
	{ input = 1, expected = '1', description = 'positive integer' },
	{ input = 1.0, expected = '1', description = 'integer as float' },
	{ input = 1.999999, expected = '1', description = 'positive float truncation' },
	{ input = 123456789.987, expected = '123456789', description = 'large float truncation' },
	{ input = -1.1, expected = '-2', description = 'negative float floors down' },
}

for _, tc in ipairs(testCases) do
	utils.test('calculateFillAmount returns ' .. tc.expected .. ' for ' .. tc.description,
		function()
			return utils.calculateFillAmount(tc.input)
		end,
		tc.expected
	)
end

print('Utils calculateFillAmount Tests completed!')
utils.testSummary()
