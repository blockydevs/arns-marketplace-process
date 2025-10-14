package.path = package.path .. ';../src/?.lua'

local utils = require('utils')

local testCases = {
	-- Valid addresses
	{
		input = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64M',
		expected = true,
		description = 'valid 43-character alphanumeric address'
	},
	{
		input = 'SaXnsUgxJLkJRghWQOUs9_wB0npVviewTkUbh2Yk64M',
		expected = true,
		description = 'valid address with underscores'
	},
	{
		input = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64M',
		expected = true,
		description = 'valid address with hyphens'
	},
	{
		input = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64M',
		expected = true,
		description = 'valid address with mixed alphanumeric, underscore, and hyphen'
	},
	{
		input = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQ',
		expected = true,
		description = 'valid 43-character address with only letters'
	},
	{
		input = '1234567890123456789012345678901234567890123',
		expected = true,
		description = 'valid 43-character address with only numbers'
	},
	{
		input = '___________________________________________',
		expected = true,
		description = 'valid 43-character address with only underscores'
	},
	{
		input = '-------------------------------------------',
		expected = true,
		description = 'valid 43-character address with only hyphens'
	},
	{
		input = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64M',
		expected = true,
		description = 'valid address with mixed case letters'
	},
	{
		input = '_aXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64M',
		expected = true,
		description = 'valid address starting with underscore'
	},
	{
		input = '-aXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64M',
		expected = true,
		description = 'valid address starting with hyphen'
	},
	{
		input = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64_',
		expected = true,
		description = 'valid address ending with underscore'
	},
	{
		input = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64-',
		expected = true,
		description = 'valid address ending with hyphen'
	},
	
	-- Invalid addresses
	{
		input = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64',
		expected = false,
		description = 'address that is too short (42 characters)'
	},
	{
		input = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64Mx',
		expected = false,
		description = 'address that is too long (44 characters)'
	},
	{
		input = 'SaXnsUgxJLkJRghWQOUs9 wB0npVviewTkUbh2Yk64M',
		expected = false,
		description = 'address containing spaces'
	},
	{
		input = 'SaXnsUgxJLkJRghWQOUs9@wB0npVviewTkUbh2Yk64M',
		expected = false,
		description = 'address containing special symbols'
	},
	{
		input = 'SaXnsUgxJLkJRghWQOUs9.wB0npVviewTkUbh2Yk64M',
		expected = false,
		description = 'address containing dots'
	},
	{
		input = 'SaXnsUgxJLkJRghWQOUs9\nwB0npVviewTkUbh2Yk64M',
		expected = false,
		description = 'address containing newline character'
	},
	{
		input = 'SaXnsUgxJLkJRghWQOUs9\twB0npVviewTkUbh2Yk64M',
		expected = false,
		description = 'address containing tab character'
	},
	{
		input = nil,
		expected = false,
		description = 'nil input'
	},
	{
		input = '',
		expected = false,
		description = 'empty string'
	},
	{
		input = 123456789,
		expected = false,
		description = 'non-string input (number)'
	},
	{
		input = {},
		expected = false,
		description = 'non-string input (table)'
	},
	{
		input = true,
		expected = false,
		description = 'non-string input (boolean)'
	}
}

-- Run all test cases
for i, testCase in ipairs(testCases) do
	utils.test('checkValidAddress should return ' .. tostring(testCase.expected) .. ' for ' .. testCase.description,
		function()
			return utils.checkValidAddress(testCase.input)
		end,
		testCase.expected
	)
end

print('Utils checkValidAddress Tests completed!')
utils.testSummary()
