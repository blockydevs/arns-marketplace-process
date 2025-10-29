package.path = package.path .. ';../src/?.lua'

-- Hardcoded ARIO process ID for tests (do not rely on production var)
local TEST_ARIO_ID = 'TEST_ARIO_PROCESS_ID_ABCDEFGHIJKLMNOPQRSTUVWXYZ' -- 43 chars not required, only equality matters

local utils = require('utils')

-- Override the global used by utils.isArioToken so tests are deterministic
ARIO_TOKEN_PROCESS_ID = TEST_ARIO_ID

local testCases = {
	{ input = TEST_ARIO_ID, expected = true, description = 'exact match to ARIO token id' },
	{ input = TEST_ARIO_ID .. 'X', expected = false, description = 'non-match different string' },
	{ input = string.lower(TEST_ARIO_ID), expected = false, description = 'case-sensitive non-match' },
	{ input = 'some-other-token-id', expected = false, description = 'completely different token id' },
	{ input = nil, expected = false, description = 'nil input' },
}

for _, tc in ipairs(testCases) do
	utils.test('isArioToken should return ' .. tostring(tc.expected) .. ' for ' .. tc.description,
		function()
			return utils.isArioToken(tc.input)
		end,
		tc.expected
	)
end

print('Utils isArioToken Tests completed!')
utils.testSummary()
