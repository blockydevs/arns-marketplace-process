package.path = package.path .. ';../src/?.lua'

local utils = require('utils')
local json = require('json')

-- Mock ao.send to capture outgoing messages per test
local sentMessages

ao = {
	send = function(msg)
		table.insert(sentMessages, msg)
	end
}

local function reset()
	sentMessages = {}
end

local validTarget = 'error-target-process'
local validTransferToken = 'refund-token-process'

local testCases = {
	{
		description = 'refund occurs then error notice when valid quantity and transfer token provided',
		args = {
			Target = validTarget,
			TransferToken = validTransferToken,
			Quantity = '1000',
			Action = 'Some-Error',
			Message = 'Something went wrong',
		},
		expected = {
			{
				Target = validTransferToken,
				Action = 'Transfer',
				Tags = { Recipient = validTarget, Quantity = '1000' }
			},
			{
				Target = validTarget,
				Action = 'Some-Error',
				Tags = { Status = 'Error', Message = 'Something went wrong', ['X-Group-ID'] = nil }
			}
		}
	},
	{
		description = 'no refund when transfer token missing; only error notice sent',
		args = {
			Target = validTarget,
			Quantity = '1000',
			Action = 'Another-Error',
			Message = 'Missing transfer token',
		},
		expected = {
			{
				Target = validTarget,
				Action = 'Another-Error',
				Tags = { Status = 'Error', Message = 'Missing transfer token', ['X-Group-ID'] = nil }
			}
		}
	},
	{
		description = 'no refund when quantity invalid (zero); only error notice sent',
		args = {
			Target = validTarget,
			TransferToken = validTransferToken,
			Quantity = '0',
			Action = 'Zero-Qty-Error',
			Message = 'Zero quantity',
		},
		expected = {
			{
				Target = validTarget,
				Action = 'Zero-Qty-Error',
				Tags = { Status = 'Error', Message = 'Zero quantity', ['X-Group-ID'] = nil }
			}
		}
	},
	{
		description = 'no refund when quantity missing; only error notice sent',
		args = {
			Target = validTarget,
			TransferToken = validTransferToken,
			Action = 'No-Qty-Error',
			Message = 'No quantity provided',
		},
		expected = {
			{
				Target = validTarget,
				Action = 'No-Qty-Error',
				Tags = { Status = 'Error', Message = 'No quantity provided', ['X-Group-ID'] = nil }
			}
		}
	},
	{
		description = 'error notice includes X-Group-ID when provided',
		args = {
			Target = validTarget,
			Action = 'Grouped-Error',
			Message = 'Grouped message',
			OrderGroupId = 'group-123',
		},
		expected = {
			{
				Target = validTarget,
				Action = 'Grouped-Error',
				Tags = { Status = 'Error', Message = 'Grouped message', ['X-Group-ID'] = 'group-123' }
			}
		}
	},
}

for _, tc in ipairs(testCases) do
	utils.test('handleError - ' .. tc.description,
		function()
			reset()
			utils.handleError(tc.args)
			return sentMessages
		end,
		tc.expected
	)
end

print('Utils handleError Tests completed!')
utils.testSummary()
