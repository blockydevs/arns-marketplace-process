package.path = package.path .. ';../src/?.lua'

local utils = require('utils')
local bint = require('bint')(256)

-- Helper to compute expected using same math
local function expectedSend(amount)
	return tostring((bint(amount) * bint(995)) // bint(1000))
end

local function expectedFee(amount)
	return tostring((bint(amount) * bint(5)) // bint(10000))
end

local cases = {
	{ amount = '0', desc = 'zero amount' },
	{ amount = '1', desc = 'smallest positive amount' },
	{ amount = '1000', desc = 'round division threshold' },
	{ amount = '999999999999999999999999', desc = 'very large amount' },
	{ amount = '123456789012345678901234567890', desc = 'extremely large amount' },
}

for _, c in ipairs(cases) do
	utils.test('calculateSendAmount for ' .. c.desc,
		function()
			return utils.calculateSendAmount(c.amount)
		end,
		expectedSend(c.amount)
	)

	utils.test('calculateFeeAmount for ' .. c.desc,
		function()
			return utils.calculateFeeAmount(c.amount)
		end,
		expectedFee(c.amount)
	)
end

print('Utils calculate amounts Tests completed!')
utils.testSummary()
