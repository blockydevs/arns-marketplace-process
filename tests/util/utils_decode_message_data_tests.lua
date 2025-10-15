package.path = package.path .. ';../src/?.lua'

local utils = require('utils')
local json = require('json')

-- Each test returns { ok:boolean, decoded:any|nil }
local testCases = {
	{ input = json.encode({ a = 1, b = 'x' }), expected = { true, { a = 1, b = 'x' } }, description = 'valid JSON object' },
	{ input = json.encode({ 1, 2, 3 }), expected = { true, { 1, 2, 3 } }, description = 'valid JSON array' },
	{ input = '{"a":1,', expected = { false, nil }, description = 'malformed JSON' },
	{ input = '', expected = { false, nil }, description = 'empty string' },
	{ input = nil, expected = { false, nil }, description = 'nil input' },
}

for _, tc in ipairs(testCases) do
	utils.test('decodeMessageData should return ' .. tostring(tc.expected[1]) .. ' for ' .. tc.description,
		function()
			local ok, decoded = utils.decodeMessageData(tc.input)
			return { ok, decoded }
		end,
		{ tc.expected[1], tc.expected[2] }
	)
end

print('Utils decodeMessageData Tests completed!')
utils.testSummary()
