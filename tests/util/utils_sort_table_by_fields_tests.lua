package.path = package.path .. ';../../src/?.lua'

local utils = require('utils')

-- 1) Primitive list with nils, fields[1].field == nil
utils.test('sortTableByFields - primitives asc with nils at end',
	function()
		local input = { 3, nil, 1, 2, nil }
		return utils.sortTableByFields(input, { { field = nil, order = 'asc' } })
	end,
	{ 1, 2, 3, nil, nil }
)

utils.test('sortTableByFields - primitives desc with nils at end',
	function()
		local input = { 3, nil, 1, 2, nil }
		return utils.sortTableByFields(input, { { field = nil, order = 'desc' } })
	end,
	{ 3, 2, 1, nil, nil }
)

-- 2) Simple objects sort by single field asc/desc
local items = {
	{ id = 'b', value = 2 },
	{ id = 'a', value = 3 },
	{ id = 'c', value = 1 },
	{ id = 'd', value = nil },
}

utils.test('sortTableByFields - single field asc with nils last',
	function()
		return utils.sortTableByFields(items, { { field = 'value', order = 'asc' } })
	end,
	{
		{ id = 'c', value = 1 },
		{ id = 'b', value = 2 },
		{ id = 'a', value = 3 },
		{ id = 'd', value = nil },
	}
)

utils.test('sortTableByFields - single field desc with nils last',
	function()
		return utils.sortTableByFields(items, { { field = 'value', order = 'desc' } })
	end,
	{
		{ id = 'a', value = 3 },
		{ id = 'b', value = 2 },
		{ id = 'c', value = 1 },
		{ id = 'd', value = nil },
	}
)

-- 3) Nested field path
local nested = {
	{ id = 'x', meta = { score = 10 } },
	{ id = 'y', meta = { score = 5 } },
	{ id = 'z', meta = { score = 20 } },
}

utils.test('sortTableByFields - nested field asc',
	function()
		return utils.sortTableByFields(nested, { { field = 'meta.score', order = 'asc' } })
	end,
	{
		{ id = 'y', meta = { score = 5 } },
		{ id = 'x', meta = { score = 10 } },
		{ id = 'z', meta = { score = 20 } },
	}
)

-- 4) Multiple fields with tie-breaker (add 'id' asc for determinism)
local multi = {
	{ id = 'b', a = 1, b = 2 },
	{ id = 'a', a = 1, b = 1 },
	{ id = 'c', a = 1, b = 2 },
	{ id = 'd', a = 2, b = 1 },
}

utils.test('sortTableByFields - multiple fields (a asc, then b asc, then id asc)',
	function()
		return utils.sortTableByFields(multi, {
			{ field = 'a', order = 'asc' },
			{ field = 'b', order = 'asc' },
			{ field = 'id', order = 'asc' },
		})
	end,
	{
		{ id = 'a', a = 1, b = 1 },
		{ id = 'b', a = 1, b = 2 },
		{ id = 'c', a = 1, b = 2 },
		{ id = 'd', a = 2, b = 1 },
	}
)

-- 5) Invalid order should error (object field triggers validation)
utils.test('sortTableByFields - invalid order should error',
	function()
		local ok = pcall(function()
			utils.sortTableByFields(items, { { field = 'value', order = 'invalid' } })
		end)
		return ok
	end,
	false
)

print('Utils sortTableByFields Tests completed!')
utils.testSummary()
