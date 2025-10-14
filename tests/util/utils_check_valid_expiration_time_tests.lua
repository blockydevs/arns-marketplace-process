package.path = package.path .. ';../src/?.lua'

local utils = require('utils')

-- Parameterized tests for utils.checkValidExpirationTime(expirationTime, timestamp)
-- Returns tuple { ok:boolean, err:string|nil }
local testCases = {
	{ exp = nil, ts = '1000', expected = { true, nil }, description = 'nil expiration allowed' },
	{ exp = '0', ts = '1000', expected = { false, 'Expiration time must be a valid positive integer' }, description = 'zero is invalid' },
	{ exp = '-1', ts = '1000', expected = { false, 'Expiration time must be a valid positive integer' }, description = 'negative is invalid' },
	{ exp = 'abc', ts = '1000', expected = { false, 'Expiration time must be a valid positive integer' }, description = 'non-numeric expiration' },
	{ exp = '1000', ts = '1000', expected = { false, 'Expiration time must be greater than current timestamp' }, description = 'equal to current timestamp' },
	{ exp = '999', ts = '1000', expected = { false, 'Expiration time must be greater than current timestamp' }, description = 'less than current timestamp' },
	{ exp = '1001', ts = '1000', expected = { true, nil }, description = 'greater than current timestamp' },
	{ exp = '1001', ts = 'abc', expected = { false, 'Expiration time must be a valid timestamp' }, description = 'invalid current timestamp' },
}

for _, tc in ipairs(testCases) do
	utils.test('checkValidExpirationTime - ' .. tc.description,
		function()
			local ok, err = utils.checkValidExpirationTime(tc.exp, tc.ts)
			return { ok, err }
		end,
		{ tc.expected[1], tc.expected[2] }
	)
end

print('Utils checkValidExpirationTime Tests completed!')
utils.testSummary()
