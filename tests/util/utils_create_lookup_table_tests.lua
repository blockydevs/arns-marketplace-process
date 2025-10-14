package.path = package.path .. ';../src/?.lua'

local utils = require('utils')

-- Test 1: nil input returns empty table
utils.test('createLookupTable - nil input returns empty table',
	function()
		return utils.createLookupTable(nil)
	end,
	{}
)

-- Test 2: empty table returns empty table
utils.test('createLookupTable - empty table returns empty table',
	function()
		return utils.createLookupTable({})
	end,
	{}
)

-- Test 3: array input with default valueFn returns true for each value
utils.test('createLookupTable - array values default to true',
	function()
		return utils.createLookupTable({ 'a', 'b', 'c' })
	end,
	{ a = true, b = true, c = true }
)

-- Test 4: object input with default valueFn returns true for each value
utils.test('createLookupTable - object values default to true',
	function()
		return utils.createLookupTable({ k1 = 'x', k2 = 'y' })
	end,
	{ x = true, y = true }
)

-- Test 5: custom valueFn uses key and value
utils.test('createLookupTable - custom valueFn maps to key:value',
	function()
		local input = { foo = 'X', bar = 'Y' }
		local result = utils.createLookupTable(input, function(key, value)
			return key .. ':' .. value
		end)
		return result
	end,
	{ X = 'foo:X', Y = 'bar:Y' }
)

print('Utils createLookupTable Tests completed!')
utils.testSummary()
