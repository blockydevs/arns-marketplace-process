package.path = package.path .. ';../src/?.lua'

local utils = require('utils')

-- 1) nil returns nil
utils.test('deepCopy - nil returns nil',
	function()
		return utils.deepCopy(nil)
	end,
	nil
)

-- 2) primitives return as-is
utils.test('deepCopy - number primitive returns as-is',
	function()
		return utils.deepCopy(42)
	end,
	42
)

utils.test('deepCopy - string primitive returns as-is',
	function()
		return utils.deepCopy('hello')
	end,
	'hello'
)

-- 3) deep nested table copy
utils.test('deepCopy - copies nested tables',
	function()
		local src = { a = 1, b = { c = 2, d = { e = 3 } } }
		local copy = utils.deepCopy(src)
		-- mutate source to ensure no aliasing
		src.b.d.e = 99
		return copy
	end,
	{ a = 1, b = { c = 2, d = { e = 3 } } }
)

-- 4) exclude simple top-level keys
utils.test('deepCopy - excludes top-level keys',
	function()
		local src = { a = 1, b = 2, c = 3 }
		return utils.deepCopy(src, { 'b' })
	end,
	{ a = 1, c = 3 }
)

-- 5) exclude nested keys via dot paths
utils.test('deepCopy - excludes nested dot-path keys',
	function()
		local src = { user = { id = 'u1', profile = { name = 'N', email = 'E' } }, other = 7 }
		return utils.deepCopy(src, { 'user.profile.email' })
	end,
	{ user = { id = 'u1', profile = { name = 'N' } }, other = 7 }
)

-- 6) exclude array indices and ensure reindexing
utils.test('deepCopy - excludes array indices and reindexes sequentially',
	function()
		local src = { 10, 20, 30, 40 }
		-- exclude the 2nd element
		return utils.deepCopy(src, { '2' })
	end,
	{ 10, 30, 40 }
)

-- 7) exclude nested array index via dot path
utils.test('deepCopy - excludes nested array index via dot path',
	function()
		local src = { users = { { id = 'a' }, { id = 'b' }, { id = 'c' } } }
		return utils.deepCopy(src, { 'users.2' })
	end,
	{ users = { { id = 'a' }, { id = 'c' } } }
)

print('Utils deepCopy Tests completed!')
utils.testSummary()
