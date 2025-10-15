package.path = package.path .. ';../src/?.lua'

local utils = require('utils')
local json = require('json')

local testCases = {
	{ input = nil, expected = nil, description = 'nil input returns nil' },
	{ input = '', expected = nil, description = 'empty string returns nil' },
	{ input = '{"a":1,', expected = nil, description = 'malformed JSON returns nil' },
	{ input = json.encode({ a = 1, b = 'x' }), expected = { a = 1, b = 'x' }, description = 'valid JSON object' },
	{ input = json.encode({ 1, 2, 3 }), expected = { 1, 2, 3 }, description = 'valid JSON array' },
	{ input = 123, expected = nil, description = 'non-string input returns nil' },
}

for _, tc in ipairs(testCases) do
	utils.test('safeDecodeJson - ' .. tc.description,
		function()
			return utils.safeDecodeJson(tc.input)
		end,
		tc.expected
	)
end

print('Utils safeDecodeJson Tests completed!')
utils.testSummary()
