package.path = package.path .. ';../src/?.lua'

local utils = require('utils')
local json = require('json')

-- Helper to build msg with Tags
local function msg(tags)
	return { Tags = tags or {} }
end

local testCases = {
	{
		description = 'defaults applied when optional tags missing',
		input = msg({}),
		expected = { cursor = nil, limit = 100, sortBy = nil, sortOrder = 'desc', filters = nil },
	},
	{
		description = 'respects cursor, limit, sort order asc, sort by and filters',
		input = msg({ Cursor = 'abc', ["Limit"] = '10', ["Sort-Order"] = 'ASC', ["Sort-By"] = 'CreatedAt', Filters = json.encode({ Status = 'active' }) }),
		expected = { cursor = 'abc', limit = 10, sortBy = 'CreatedAt', sortOrder = 'asc', filters = { Status = 'active' } },
	},
}

for _, tc in ipairs(testCases) do
	utils.test('parsePaginationTags - ' .. tc.description,
		function()
			return utils.parsePaginationTags(tc.input)
		end,
		tc.expected
	)
end

-- Expect errors: limit > 1000
utils.test('parsePaginationTags - limit exceeds 1000 should assert',
	function()
		local ok, err = pcall(function()
			return utils.parsePaginationTags(msg({ ["Limit"] = '1001' }))
		end)
		return ok
	end,
	false
)

-- Expect errors: invalid sort order
utils.test('parsePaginationTags - invalid sort order should assert',
	function()
		local ok, err = pcall(function()
			return utils.parsePaginationTags(msg({ ["Sort-Order"] = 'invalid' }))
		end)
		return ok
	end,
	false
)

-- Expect errors: invalid Filters JSON
utils.test('parsePaginationTags - invalid Filters JSON should assert',
	function()
		local ok = pcall(function()
			return utils.parsePaginationTags(msg({ Filters = '{invalid' }))
		end)
		return ok
	end,
	false
)

print('Utils parsePaginationTags Tests completed!')
utils.testSummary()
