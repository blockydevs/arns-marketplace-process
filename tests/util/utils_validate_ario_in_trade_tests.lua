package.path = package.path .. ';../src/?.lua'

-- Hardcoded ARIO process ID for tests
local TEST_ARIO_ID = 'TEST_ARIO_PROCESS_ID_ABCDEFGHIJKLMNOPQRSTUVWXYZ'

local utils = require('utils')

-- Ensure utils uses our test ARIO ID
ARIO_TOKEN_PROCESS_ID = TEST_ARIO_ID

-- Each test expects a tuple: success:boolean, errorMessage:string|nil
local testCases = {
	{ dominant = TEST_ARIO_ID, swap = 'OTHER_TOKEN', expected = { true, nil }, description = 'dominant token is ARIO' },
	{ dominant = 'OTHER_TOKEN', swap = TEST_ARIO_ID, expected = { true, nil }, description = 'swap token is ARIO' },
	{ dominant = TEST_ARIO_ID, swap = TEST_ARIO_ID, expected = { true, nil }, description = 'both tokens are ARIO' },
	{ dominant = 'TOKEN_A', swap = 'TOKEN_B', expected = { false, 'At least one token in the trade must be ARIO' }, description = 'neither token is ARIO' },
	{ dominant = nil, swap = TEST_ARIO_ID, expected = { true, nil }, description = 'nil dominant but ARIO in swap' },
}

for _, tc in ipairs(testCases) do
	utils.test('validateArioInTrade should return ' .. (tc.expected[1] and 'success' or 'failure') .. ' when ' .. tc.description,
		function()
			local ok, err = utils.validateArioInTrade(tc.dominant, tc.swap)
			return { ok, err }
		end,
		{ tc.expected[1], tc.expected[2] }
	)
end

print('Utils validateArioInTrade Tests completed!')
utils.testSummary()
