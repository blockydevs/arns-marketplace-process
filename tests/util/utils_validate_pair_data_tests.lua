package.path = package.path .. ';../src/?.lua'

local utils = require('utils')

-- Reuse known-valid 43-char addresses from other tests
local ANT = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10'
local ARIO = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8'

-- Each test returns a map { result = <table|nil>, error = <string|nil> }
local testCases = {
	{
		description = 'valid pair of two distinct addresses',
		input = { ANT, ARIO },
		expected = { result = { ANT, ARIO } },
	},
	{
		description = 'input not a 2-element list',
		input = { ANT },
		expected = { result = nil, error = 'Pair must be a list of exactly two strings - [TokenId, TokenId]' },
	},
	{
		description = 'elements are not strings',
		input = { 123, false },
		expected = { result = nil, error = 'Both pair elements must be strings' },
	},
	{
		description = 'elements are invalid addresses',
		input = { 'not_an_address', 'also_not_valid' },
		expected = { result = nil, error = 'Both pair elements must be valid addresses' },
	},
	{
		description = 'addresses cannot be equal',
		input = { ANT, ANT },
		expected = { result = nil, error = 'Pair addresses cannot be equal' },
	},
}

for _, tc in ipairs(testCases) do
	utils.test('validatePairData - ' .. tc.description,
		function()
			local res, err = utils.validatePairData(tc.input)
			return { result = res, error = err }
		end,
		tc.expected
	)
end

print('Utils validatePairData Tests completed!')
utils.testSummary()
