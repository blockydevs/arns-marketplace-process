package.path = package.path .. ';../src/?.lua'

local utils = require('utils')

-- Helpers
local function clone(tbl)
	local c = {}
	for i, v in ipairs(tbl) do c[i] = v end
	return c
end

-- Fixtures
local baseItems = {
	{ Id = 'A', CreatedAt = 1000, Status = 'active' },
	{ Id = 'B', CreatedAt = 1001, Status = 'inactive' },
	{ Id = 'C', CreatedAt = 1002, Status = 'active' },
	{ Id = 'D', CreatedAt = 1003, Status = 'active' },
}

-- 1) Empty array
utils.test('paginateTableWithCursor - empty input returns empty page',
	function()
		local res = utils.paginateTableWithCursor({}, nil, 'Id', 2, nil, 'desc', nil)
		return res
	end,
	{ items = {}, limit = 2, totalItems = 0, sortBy = 'CreatedAt', sortOrder = 'desc', nextCursor = nil, hasMore = false }
)

-- 2) Default sort (desc by CreatedAt), first page limit 2
utils.test('paginateTableWithCursor - first page default sort desc by CreatedAt',
	function()
		local items = clone(baseItems)
		local res = utils.paginateTableWithCursor(items, nil, 'Id', 2, nil, 'desc', nil)
		return res
	end,
	{
		items = {
			{ Id = 'D', CreatedAt = 1003, Status = 'active' },
			{ Id = 'C', CreatedAt = 1002, Status = 'active' },
		},
		limit = 2,
		totalItems = 4,
		sortBy = 'CreatedAt',
		sortOrder = 'desc',
		nextCursor = 'C',
		hasMore = true,
	}
)

-- 3) Next page using cursor at previous end (uses cursorField 'Id')
utils.test('paginateTableWithCursor - second page using cursor',
	function()
		local items = clone(baseItems)
		local res = utils.paginateTableWithCursor(items, 'C', 'Id', 2, nil, 'desc', nil)
		return res
	end,
	{
		items = {
			{ Id = 'B', CreatedAt = 1001, Status = 'inactive' },
			{ Id = 'A', CreatedAt = 1000, Status = 'active' },
		},
		limit = 2,
		totalItems = 4,
		sortBy = 'CreatedAt',
		sortOrder = 'desc',
		nextCursor = nil,
		hasMore = false,
	}
)

-- 4) Tie-breaker with cursorField when same CreatedAt
utils.test('paginateTableWithCursor - tie-breaker with cursorField for identical CreatedAt',
	function()
		local items = {
			{ Id = 'A', CreatedAt = 1000 },
			{ Id = 'B', CreatedAt = 1000 },
			{ Id = 'C', CreatedAt = 1000 },
		}
		-- Sort desc by CreatedAt (all equal), tie-breaker asc by Id
		local res1 = utils.paginateTableWithCursor(items, nil, 'Id', 2, 'CreatedAt', 'desc', nil)
		-- Cursor should be last item Id of page based on tie-break order asc by Id -> page: A,B then next starts at C
		local res2 = utils.paginateTableWithCursor(items, res1.items[#res1.items].Id, 'Id', 2, 'CreatedAt', 'desc', nil)
		return { first = res1, second = res2 }
	end,
	{
		first = {
			items = {
				{ Id = 'A', CreatedAt = 1000 },
				{ Id = 'B', CreatedAt = 1000 },
			},
			limit = 2,
			totalItems = 3,
			sortBy = 'CreatedAt',
			sortOrder = 'desc',
			nextCursor = 'B',
			hasMore = true,
		},
		second = {
			items = {
				{ Id = 'C', CreatedAt = 1000 },
			},
			limit = 2,
			totalItems = 3,
			sortBy = 'CreatedAt',
			sortOrder = 'desc',
			nextCursor = nil,
			hasMore = false,
		}
	}
)

-- 5) Asc sorting
utils.test('paginateTableWithCursor - asc sorting by CreatedAt',
	function()
		local items = clone(baseItems)
		local res = utils.paginateTableWithCursor(items, nil, 'Id', 3, 'CreatedAt', 'asc', nil)
		return res
	end,
	{
		items = {
			{ Id = 'A', CreatedAt = 1000, Status = 'active' },
			{ Id = 'B', CreatedAt = 1001, Status = 'inactive' },
			{ Id = 'C', CreatedAt = 1002, Status = 'active' },
		},
		limit = 3,
		totalItems = 4,
		sortBy = 'CreatedAt',
		sortOrder = 'asc',
		nextCursor = 'C',
		hasMore = true,
	}
)

-- 6) Filters applied
utils.test('paginateTableWithCursor - filters active only',
	function()
		local items = clone(baseItems)
		local res = utils.paginateTableWithCursor(items, nil, 'Id', 10, 'CreatedAt', 'asc', { Status = 'active' })
		return res
	end,
	{
		items = {
			{ Id = 'A', CreatedAt = 1000, Status = 'active' },
			{ Id = 'C', CreatedAt = 1002, Status = 'active' },
			{ Id = 'D', CreatedAt = 1003, Status = 'active' },
		},
		limit = 10,
		totalItems = 3,
		sortBy = 'CreatedAt',
		sortOrder = 'asc',
		nextCursor = nil,
		hasMore = false,
	}
)

print('Utils paginateTableWithCursor Tests completed!')
utils.testSummary()
