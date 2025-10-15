package.path = package.path .. ';../src/?.lua'

local utils = require('utils')

local items = {
	{ id = 'a', status = 'active', count = 1 },
	{ id = 'b', status = 'inactive', count = 2 },
	{ id = 'c', status = 'active', count = 2 },
	{ id = 'd', status = 'active', count = '2' },
}

-- 1) Single-field match
utils.test('createFilterFunction - single field match',
	function()
		local filterFn = utils.createFilterFunction({ status = 'active' })
		return utils.filterArray(items, function(_, v) return filterFn(v) end)
	end,
	{
		{ id = 'a', status = 'active', count = 1 },
		{ id = 'c', status = 'active', count = 2 },
		{ id = 'd', status = 'active', count = '2' },
	}
)

-- 2) Multi-field match
utils.test('createFilterFunction - multi-field match',
	function()
		local filterFn = utils.createFilterFunction({ status = 'active', count = 2 })
		return utils.filterArray(items, function(_, v) return filterFn(v) end)
	end,
	{
		{ id = 'c', status = 'active', count = 2 },
	}
)

-- 3) Non-matching filter
utils.test('createFilterFunction - non-matching filter returns empty',
	function()
		local filterFn = utils.createFilterFunction({ status = 'pending' })
		return utils.filterArray(items, function(_, v) return filterFn(v) end)
	end,
	{}
)

-- 4) Empty filter (should allow all)
utils.test('createFilterFunction - empty filter allows all',
	function()
		local filterFn = utils.createFilterFunction({})
		return utils.filterArray(items, function(_, v) return filterFn(v) end)
	end,
	items
)

-- 5) Type sensitivity (number vs string)
utils.test('createFilterFunction - type sensitive comparisons',
	function()
		local filterFn = utils.createFilterFunction({ count = 2 })
		return utils.filterArray(items, function(_, v) return filterFn(v) end)
	end,
	{
		{ id = 'b', status = 'inactive', count = 2 },
		{ id = 'c', status = 'active', count = 2 },
	}
)

print('Utils createFilterFunction Tests completed!')
utils.testSummary()
