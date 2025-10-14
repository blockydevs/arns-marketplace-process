package.path = package.path .. ';../../src/?.lua'

local utils = require('utils')

-- 1) Empty input returns empty array
utils.test('filterArray - empty input returns empty array',
	function()
		return utils.filterArray({}, function() return true end)
	end,
	{}
)

local items = { 1, 2, 3, 4, 5 }

-- 2) Match all
utils.test('filterArray - match all',
	function()
		return utils.filterArray(items, function() return true end)
	end,
	{ 1, 2, 3, 4, 5 }
)

-- 3) Match none
utils.test('filterArray - match none',
	function()
		return utils.filterArray(items, function() return false end)
	end,
	{}
)

-- 4) Value-based predicate (even numbers)
utils.test('filterArray - value-based predicate keeps evens',
	function()
		return utils.filterArray(items, function(_, v) return v % 2 == 0 end)
	end,
	{ 2, 4 }
)

-- 5) Index-based predicate (odd indices)
utils.test('filterArray - index-based predicate keeps odd indices',
	function()
		return utils.filterArray(items, function(i) return i % 2 == 1 end)
	end,
	{ 1, 3, 5 }
)

-- 6) Order preservation with mixed predicate
utils.test('filterArray - preserves order of passing elements',
	function()
		local input = { 'a', 'b', 'c', 'd' }
		return utils.filterArray(input, function(_, v) return v ~= 'b' and v ~= 'd' end)
	end,
	{ 'a', 'c' }
)

print('Utils filterArray Tests completed!')
utils.testSummary()
