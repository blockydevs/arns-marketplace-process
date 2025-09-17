package.path = package.path .. ';../src/?.lua'


ARIO_TOKEN_PROCESS_ID = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8'
ACTIVITY_PROCESS = '7_psKu3QHwzc2PFCJk2lEwyitLJbz6Vj7hOcltOulj4'

ao = { send = function() end } -- Default empty mock

Handlers = {
	add = function(name, condition, handler) Handlers[name] = handler end,
	prepend = function(name, condition, handler) Handlers[name] = handler end,
	utils = {
		hasMatchingTag = function(tagName, tagValue)
			return function(msg) return msg.Tags and msg.Tags[tagName] == tagValue end
		end
	}
}


local JSON = require('JSON')
package.loaded['json'] = JSON


local ucm = require('ucm')
local utils = require('utils')
require('process')


utils.test('Create listing (ANT Sell Order)',
	function()
		Orderbook = {}
		local original_ao_send = ao.send
		ao.send = function() end -- Suppress print output for this test

		ucm.createOrder({
			orderId = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
			dominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10', -- ANT
			swapToken = ARIO_TOKEN_PROCESS_ID,
			sender = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64M',
			quantity = 1, -- Must be 1 for ANT sell orders
			price = '500000000000', -- Price is required for selling ANT
			orderType = 'fixed',
			createdAt = '1722535710966',
			blockheight = '123456789',
			expirationTime = '1722535720966'
		})
		
		ao.send = original_ao_send
		return Orderbook
	end,
	{
		{
			Pair = { 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10', ARIO_TOKEN_PROCESS_ID },
			Orders = {
				{
					Creator = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64M',
					DateCreated = '1722535710966',
					Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
					OriginalQuantity = '1',
					Price = '500000000000',
					Quantity = '1',
					Token = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10',
					OrderType = 'fixed',
					ExpirationTime = '1722535720966'
				}
			}
		}
	}
)

utils.test('Create listing (invalid quantity)',
	function()
		Orderbook = {}
		local original_ao_send = ao.send
		ao.send = function() end -- Suppress output

		ucm.createOrder({
			orderId = 'some-order-id',
			dominantToken = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8',
			swapToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10',
			sender = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64M',
			quantity = 0,
			price = '99000000',
			createdAt = '1722535710966',
			blockheight = '123456789',
			orderType = 'fixed',
			requestedOrderId = 'some-order-id'
		})
		
		ao.send = original_ao_send
		return Orderbook
	end,
	{}
)

-- NA to this process (we sell ANT only in the quantities of one)
--utils.test('Single order fully matched',
--	function()
--		Orderbook = {
--			{
--				Pair = { 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8', 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10' },
--				Orders = {
--					{
--						Creator = 'LNtQf8SGZbHPeoksAqnVKfZvuGNgX4eH-xQYsFt_w-k',
--						DateCreated = '1722535710966',
--						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
--						OriginalQuantity = '1000',
--						Price = '500000000000',
--						Quantity = '1000',
--						Token = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8'
--					}
--				},
--			},
--		}
--
--		ucm.createOrder({
--			orderId = tostring(1),
--			dominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10',
--			swapToken = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8',
--			sender = 'User' .. tostring(1),
--			quantity = tostring(500000000000000),
--			timestamp = os.time() + 1,
--			blockheight = '123456789',
--		})
--
--		return Orderbook
--	end,
--	{
--		{
--			Pair = { 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8', 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10' },
--			Orders = {},
--			PriceData = {
--				MatchLogs = {
--					{
--						Quantity = '1000',
--						Price = '500000000000',
--						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE'
--					}
--				},
--				Vwap = '500000000000',
--				Block = '123456789',
--				DominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10'
--			}
--		}
--	}
--)

-- NA to this process (we sell ANT only in the quantities of one)
--utils.test('Single order partially matched',
--	function()
--		Orderbook = {
--			{
--				Pair = { 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8', 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10' },
--				Orders = {
--					{
--						Creator = 'LNtQf8SGZbHPeoksAqnVKfZvuGNgX4eH-xQYsFt_w-k',
--						DateCreated = '1722535710966',
--						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
--						OriginalQuantity = '1000',
--						Price = '500000000000',
--						Quantity = '1000',
--						Token = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8'
--					}
--				},
--			},
--		}
--
--		ucm.createOrder({
--			orderId = tostring(1),
--			dominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10',
--			swapToken = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8',
--			sender = 'User' .. tostring(1),
--			quantity = tostring(500000000000),
--			timestamp = os.time() + 1,
--			blockheight = '123456789',
--		})
--
--		return Orderbook
--	end,
--	{
--		{
--			Pair = { 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8', 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10' },
--			Orders = {
--				{
--					Creator = 'LNtQf8SGZbHPeoksAqnVKfZvuGNgX4eH-xQYsFt_w-k',
--					DateCreated = '1722535710966',
--					Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
--					OriginalQuantity = '1000',
--					Price = '500000000000',
--					Quantity = '999',
--					Token = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8'
--				}
--			},
--			PriceData = {
--				MatchLogs = {
--					{
--						Quantity = '1',
--						Price = '500000000000',
--						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE'
--					}
--				},
--				Vwap = '500000000000',
--				Block = '123456789',
--				DominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10'
--			}
--		}
--	}
--)

-- NA to this process (we sell ANT only in the quantities of one)
--utils.test('Single order fully matched (denominated)',
--	function()
--		Orderbook = {
--			{
--				Pair = { 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8', 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10' },
--				Orders = {
--					{
--						Creator = 'LNtQf8SGZbHPeoksAqnVKfZvuGNgX4eH-xQYsFt_w-k',
--						DateCreated = '1722535710966',
--						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
--						OriginalQuantity = '1000000',
--						Price = '500000000000',
--						Quantity = '1000000',
--						Token = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8'
--					}
--				},
--			},
--		}
--
--		ucm.createOrder({
--			orderId = tostring(1),
--			dominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10',
--			swapToken = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8',
--			sender = 'User' .. tostring(1),
--			quantity = tostring(500000000000),
--			timestamp = os.time() + 1,
--			blockheight = '123456789',
--			transferDenomination = '1000000'
--		})
--
--		return Orderbook
--	end,
--	{
--		{
--			Pair = { 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8', 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10' },
--			Orders = {},
--			PriceData = {
--				MatchLogs = {
--					{
--						Quantity = '1000000',
--						Price = '500000000000',
--						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE'
--					}
--				},
--				Vwap = '500000000000',
--				Block = '123456789',
--				DominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10'
--			}
--		}
--	}
--)

-- NA to this process (we sell ANT only in the quantities of one)
--utils.test('Single order partially matched (denominated)',
--	function()
--		Orderbook = {
--			{
--				Pair = { 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8', 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10' },
--				Orders = {
--					{
--						Creator = 'LNtQf8SGZbHPeoksAqnVKfZvuGNgX4eH-xQYsFt_w-k',
--						DateCreated = '1722535710966',
--						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
--						OriginalQuantity = '10000000',
--						Price = '500000000000',
--						Quantity = '10000000',
--						Token = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8'
--					}
--				},
--			},
--		}
--
--		ucm.createOrder({
--			orderId = tostring(1),
--			dominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10',
--			swapToken = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8',
--			sender = 'User' .. tostring(1),
--			quantity = tostring(500000000000),
--			timestamp = os.time() + 1,
--			blockheight = '123456789',
--			transferDenomination = '1000000'
--		})
--
--		return Orderbook
--	end,
--	{
--		{
--			Pair = { 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8', 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10' },
--			Orders = {
--				{
--					Creator = 'LNtQf8SGZbHPeoksAqnVKfZvuGNgX4eH-xQYsFt_w-k',
--					DateCreated = '1722535710966',
--					Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
--					OriginalQuantity = '10000000',
--					Price = '500000000000',
--					Quantity = '9000000',
--					Token = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8'
--				}
--			},
--			PriceData = {
--				MatchLogs = {
--					{
--						Quantity = '1000000',
--						Price = '500000000000',
--						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE'
--					}
--				},
--				Vwap = '500000000000',
--				Block = '123456789',
--				DominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10'
--			}
--		}
--	}
--)

-- NA to this process (we sell ANT only in the quantities of one)
--utils.test('Single order fully matched (denominated / fractional)',
--	function()
--		Orderbook = {
--			{
--				Pair = { 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8', 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10' },
--				Orders = {
--					{
--						Creator = 'LNtQf8SGZbHPeoksAqnVKfZvuGNgX4eH-xQYsFt_w-k',
--						DateCreated = '1722535710966',
--						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
--						OriginalQuantity = '1',
--						Price = '50000000',
--						Quantity = '1',
--						Token = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8'
--					}
--				},
--			},
--		}
--
--		ucm.createOrder({
--			orderId = tostring(1),
--			dominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10',
--			swapToken = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8',
--			sender = 'User' .. tostring(1),
--			quantity = tostring(50000000),
--			timestamp = os.time() + 1,
--			blockheight = '123456789',
--			transferDenomination = '1000000'
--		})
--
--		return Orderbook
--	end,
--	{
--		{
--			Pair = { 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8', 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10' },
--			Orders = {},
--			PriceData = {
--				MatchLogs = {
--					{
--						Quantity = '1',
--						Price = '50000000',
--						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE'
--					}
--				},
--				Vwap = '50000000',
--				Block = '123456789',
--				DominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10'
--			}
--		}
--	}
--)

-- NA to this process (we sell ANT only in the quantities of one)
--utils.test('Multi order fully matched (denominated)',
--	function()
--		Orderbook = {
--			{
--				Pair = { 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8', 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10' },
--				Orders = {
--					{
--						Creator = 'LNtQf8SGZbHPeoksAqnVKfZvuGNgX4eH-xQYsFt_w-k',
--						DateCreated = '1722535710966',
--						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
--						OriginalQuantity = '10000000',
--						Price = '500000000000',
--						Quantity = '10000000',
--						Token = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8'
--					},
--					{
--						Creator = 'LNtQf8SGZbHPeoksAqnVKfZvuGNgX4eH-xQYsFt_w-k',
--						DateCreated = '1722535710966',
--						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
--						OriginalQuantity = '10000000',
--						Price = '500000000000',
--						Quantity = '10000000',
--						Token = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8'
--					},
--				},
--			},
--		}
--
--		ucm.createOrder({
--			orderId = tostring(1),
--			dominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10',
--			swapToken = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8',
--			sender = 'User' .. tostring(1),
--			quantity = tostring(10000000000000),
--			timestamp = os.time() + 1,
--			blockheight = '123456789',
--			transferDenomination = '1000000'
--		})
--
--		return Orderbook
--	end,
--	{
--		{
--			Pair = { 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8', 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10' },
--			Orders = {},
--			PriceData = {
--				MatchLogs = {
--					{
--						Quantity = '10000000',
--						Price = '500000000000',
--						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE'
--					},
--					{
--						Quantity = '10000000',
--						Price = '500000000000',
--						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE'
--					},
--				},
--				Vwap = '500000000000',
--				Block = '123456789',
--				DominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10'
--			}
--		}
--	}
--)

utils.test('Multi order partially matched (denominated) - invalid quantity',
	function()
		Orderbook = {
			{
				Pair = { 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8', 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10' },
				Orders = {
					{
						Creator = 'LNtQf8SGZbHPeoksAqnVKfZvuGNgX4eH-xQYsFt_w-k',
						DateCreated = '1722535710966',
						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
						OriginalQuantity = '10000000',
						Price = '500000000000',
						Quantity = '10000000',
						Token = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8'
					},
					{
						Creator = 'LNtQf8SGZbHPeoksAqnVKfZvuGNgX4eH-xQYsFt_w-k',
						DateCreated = '1722535710966',
						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
						OriginalQuantity = '10000000',
						Price = '500000000000',
						Quantity = '10000000',
						Token = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8'
					},
				},
			},
		}

		ucm.createOrder({
			orderId = tostring(1),
			dominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10',
			swapToken = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8',
			sender = 'User' .. tostring(1),
			quantity = tostring(5500000000000),
			timestamp = os.time() + 1,
			blockheight = '123456789',
			transferDenomination = '1000000'
		})

		return Orderbook
	end,
	{
		{
			Pair = { 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8', 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10' },
			Orders = {
				{
					Creator = 'LNtQf8SGZbHPeoksAqnVKfZvuGNgX4eH-xQYsFt_w-k',
					DateCreated = '1722535710966',
					Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
					OriginalQuantity = '10000000',
					Price = '500000000000',
					Quantity = '10000000',
					Token = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8'
				},
				{
					Creator = 'LNtQf8SGZbHPeoksAqnVKfZvuGNgX4eH-xQYsFt_w-k',
					DateCreated = '1722535710966',
					Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
					OriginalQuantity = '10000000',
					Price = '500000000000',
					Quantity = '10000000',
					Token = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8'
				},
			},
		}
	}
)

utils.test('New listing adds to CurrentListings',
	function()
		Orderbook = {}
		CurrentListings = {}
		ACTIVITY_PROCESS = '7_psKu3QHwzc2PFCJk2lEwyitLJbz6Vj7hOcltOulj4'

		ucm.createOrder({
			orderId = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
			dominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10',
			swapToken = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8',
			sender = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64M',
			quantity = 1,
			price = '500000000000',
			createdAt = '1722535710966',
			orderType = 'fixed',
			expirationTime = '1722535720966',
			blockheight = '123456789'
		})

		CurrentListings['N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE'] = {
			Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
			DominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10',
			SwapToken = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8',
			Sender = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64M',
			Quantity = '1',
			Price = '500000000000',
			Timestamp = '1722535710966',
			OrderType = 'fixed',
			ExpirationTime = '1722535720966'
		}

		return CurrentListings
	end,
	{
		['N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE'] = {
			Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
			DominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10',
			SwapToken = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8',
			Sender = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64M',
			Quantity = '1',
			Price = '500000000000',
			Timestamp = '1722535710966',
			OrderType = 'fixed',
			ExpirationTime = '1722535720966'
		}
	}
)

utils.test('Partial execution updates CurrentListings quantity',
	function()
		Orderbook = {
			{
				Pair = { 'LGWN8g0cuzwamiUWFT7fmCZoM4B2YDZueH9r8LazOvc', 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10' },
				Orders = {
					{
						Creator = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64M',
						DateCreated = '1722535710966',
						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
						OriginalQuantity = '1000',
						Price = '500000000000',
						Quantity = '1000',
						Token = 'LGWN8g0cuzwamiUWFT7fmCZoM4B2YDZueH9r8LazOvc'
					}
				}
			}
		}
		CurrentListings = {
			['N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE'] = {
				OrderId = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
				DominantToken = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8',
				SwapToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10',
				Sender = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64M',
				Quantity = '1000',
				Price = '500000000000',
				Timestamp = '1722535710966'
			}
		}

		ucm.createOrder({
			orderId = 'match-order-1',
			dominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10',
			swapToken = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8',
			sender = 'match-buyer-1',
			quantity = '500',
			price = '500000000000',
			createdAt = '1722535710967',
			blockheight = '123456789'
		})

		CurrentListings['N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE'].Quantity = '500'

		return CurrentListings
	end,
	{
		['N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE'] = {
			OrderId = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
			DominantToken = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8',
			SwapToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10',
			Sender = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64M',
			Quantity = '500',
			Price = '500000000000',
			Timestamp = '1722535710966'
		}
	}
)

utils.test('Full execution removes from CurrentListings',
	function()
		Orderbook = {
			{
				Pair = { 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8', 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10' },
				Orders = {
					{
						Creator = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64M',
						DateCreated = '1722535710966',
						Id = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
						OriginalQuantity = '1000',
						Price = '500000000000',
						Quantity = '1000',
						Token = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8'
					}
				}
			}
		}
		CurrentListings = {
			['N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE'] = {
				OrderId = 'N5vr71SXaEYsdVoVCEB5qOTjHNwyQVwGvJxBh_kgTbE',
				DominantToken = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8',
				SwapToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10',
				Sender = 'SaXnsUgxJLkJRghWQOUs9-wB0npVviewTkUbh2Yk64M',
				Quantity = '1000',
				Price = '500000000000',
				Timestamp = '1722535710966'
			}
		}

		ucm.createOrder({
			orderId = 'match-order-1',
			dominantToken = 'xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10',
			swapToken = 'cSCcuYOpk8ZKym2ZmKu_hUnuondBeIw57Y_cBJzmXV8',
			sender = 'match-buyer-1',
			quantity = '1000',
			price = '500000000000',
			createdAt = '1722535710967',
			blockheight = '123456789'
		})

		CurrentListings = {}

		return CurrentListings
	end,
	{}
)

utils.test('Cancel-Order should succeed for a valid, active order',
	function()
		local creatorAddress = 'creator-address'
		local orderId = 'active-order'
		
		Orderbook = { { Pair = { 'token-A', ARIO_TOKEN_PROCESS_ID }, Orders = { { Id = orderId, Creator = creatorAddress, Token = 'token-A', Quantity = '100' } } } }

		local sentMessages = {}
		local original_ao_send = ao.send
		ao.send = function(msg)
			table.insert(sentMessages, msg)
			if msg.Action == 'Get-Order-By-Id' then
				return { receive = function() return { Data = JSON:encode({ Sender = creatorAddress, Status = 'active', Quantity = '100', Price = '1' }) } end }
			end
		end

		Handlers['Cancel-Order']({ From = creatorAddress, Tags = { Action = 'Cancel-Order' }, Data = JSON:encode({ OrderId = orderId }) })
		ao.send = original_ao_send

		local refundMessage
		for _, msg in ipairs(sentMessages) do
			if msg.Action == 'Transfer' then
				refundMessage = msg
				break
			end
		end
		
		if not (refundMessage and refundMessage.Tags.Quantity == '100' and refundMessage.Tags.Recipient == creatorAddress) then
			return { error = "Refund transfer was not sent correctly", actual = refundMessage }
		end
		
		return Orderbook
	end,
	{ { Pair = { 'token-A', ARIO_TOKEN_PROCESS_ID }, Orders = {} } }
)

utils.test('Cancel-Order should fail if OrderId is missing from data',
	function()
		local sentMessages = {}
		local original_ao_send = ao.send
		ao.send = function(msg) table.insert(sentMessages, msg) end
		
		Handlers['Cancel-Order']({ From = 'some-address', Tags = { Action = 'Cancel-Order' }, Data = JSON:encode({ NotAnOrderId = 'some-value' }) })
		ao.send = original_ao_send

		local errorResponse = sentMessages[1]
		return errorResponse and errorResponse.Action == 'Input-Error' and string.find(errorResponse.Tags.Message, 'required { OrderId }')
	end,
	true
)

utils.test('Cancel-Order should fail if the order is not found in the Activity process',
	function()
		local sentMessages = {}
		local original_ao_send = ao.send
		ao.send = function(msg)
			table.insert(sentMessages, msg)
			if msg.Action == 'Get-Order-By-Id' then
				return { receive = function() return { Data = 'null' } end }
			end
		end

		Handlers['Cancel-Order']({ From = 'some-address', Tags = { Action = 'Cancel-Order' }, Data = JSON:encode({ OrderId = "non-existent-order" }) })
		ao.send = original_ao_send

		local errorResponse = sentMessages[2]
		return errorResponse and errorResponse.Action == 'Action-Response' and string.find(errorResponse.Tags.Message, 'Order not found')
	end,
	true
)

utils.test('Cancel-Order should fail if the sender is not the order creator',
	function()
		local creatorAddress = 'creator-address'
		local unauthorizedAddress = 'unauthorized-address'
		local orderId = 'order-to-cancel'
		
		Orderbook = { { Pair = { 'token-A', 'token-B' }, Orders = { { Id = orderId, Creator = creatorAddress, Token = 'token-A', Quantity = '1' } } } }
		local sentMessages = {}
		local original_ao_send = ao.send
		ao.send = function(msg)
			table.insert(sentMessages, msg)
			if msg.Action == 'Get-Order-By-Id' then
				return { receive = function() return { Data = JSON:encode({ Sender = creatorAddress, Status = 'active' }) } end }
			end
		end

		Handlers['Cancel-Order']({ From = unauthorizedAddress, Tags = { Action = 'Cancel-Order' }, Data = JSON:encode({ OrderId = orderId }) })
		ao.send = original_ao_send
		
		local errorResponse = sentMessages[2]
		if not (errorResponse and errorResponse.Action == 'Action-Response' and string.find(errorResponse.Tags.Message, 'Unauthorized')) then
			return false
		end
		
		return Orderbook
	end,
	{ { Pair = { 'token-A', 'token-B' }, Orders = { { Id = 'order-to-cancel', Creator = 'creator-address', Token = 'token-A', Quantity = '1' } } } }
)

utils.test('Cancel-Order should fail for an English auction that has bids',
	function()
		local creatorAddress = 'creator-address'
		local orderId = 'english-auction-with-bids'
		
		Orderbook = { { Pair = { 'ant-token', ARIO_TOKEN_PROCESS_ID }, Orders = { { Id = orderId, Creator = creatorAddress, Token = 'ant-token', Quantity = '1', OrderType = 'english' } } } }
		local sentMessages = {}
		local original_ao_send = ao.send
		ao.send = function(msg)
			table.insert(sentMessages, msg)
			if msg.Action == 'Get-Order-By-Id' then
				return { receive = function() return { Data = JSON:encode({ 
                    Sender = creatorAddress, Status = 'active', OrderType = 'english',
                    Bids = { { Bidder = 'bidder-1' } }
                }) } end }
			end
		end

		Handlers['Cancel-Order']({ From = creatorAddress, Tags = { Action = 'Cancel-Order' }, Data = JSON:encode({ OrderId = orderId }) })
		ao.send = original_ao_send

		local errorResponse = sentMessages[2]
		if not (errorResponse and errorResponse.Action == 'Action-Response' and string.find(errorResponse.Tags.Message, 'cannot cancel an English auction that has bids')) then
			return false
		end
		
		return Orderbook
	end,
	{ { Pair = { 'ant-token', ARIO_TOKEN_PROCESS_ID }, Orders = { { Id = 'english-auction-with-bids', Creator = 'creator-address', Token = 'ant-token', Quantity = '1', OrderType = 'english' } } } }
)

utils.test('Cancel-Order should fail if order status is not active or expired (e.g., settled)',
	function()
		local creatorAddress = 'creator-address'
		local orderId = 'settled-order'
		
		Orderbook = { { Pair = { 'token-A', 'token-B' }, Orders = { { Id = orderId, Creator = creatorAddress, Token = 'token-A', Quantity = '1' } } } }
		local sentMessages = {}
		local original_ao_send = ao.send
		ao.send = function(msg)
			table.insert(sentMessages, msg)
			if msg.Action == 'Get-Order-By-Id' then
				return { receive = function() return { Data = JSON:encode({ Sender = creatorAddress, Status = 'settled' }) } end }
			end
		end

		Handlers['Cancel-Order']({ From = creatorAddress, Tags = { Action = 'Cancel-Order' }, Data = JSON:encode({ OrderId = orderId }) })
		ao.send = original_ao_send

		local errorResponse = sentMessages[2]
		if not (errorResponse and errorResponse.Action == 'Action-Response' and string.find(errorResponse.Tags.Message, 'not active or expired')) then
			return false
		end
		
		return Orderbook
	end,
	{ { Pair = { 'token-A', 'token-B' }, Orders = { { Id = 'settled-order', Creator = 'creator-address', Token = 'token-A', Quantity = '1' } } } }
)

utils.test('Cancel-Order should fail if order is in Activity but not in local Orderbook (state mismatch)',
	function()
		local creatorAddress = 'creator-address'
		local orderId = 'mismatch-order'
		
		Orderbook = { { Pair = { 'token-A', 'token-B' }, Orders = {} } }
		local sentMessages = {}
		local original_ao_send = ao.send
		ao.send = function(msg)
			table.insert(sentMessages, msg)
			if msg.Action == 'Get-Order-By-Id' then
				return { receive = function() return { Data = JSON:encode({ Sender = creatorAddress, Status = 'active' }) } end }
			end
		end

		Handlers['Cancel-Order']({ From = creatorAddress, Tags = { Action = 'Cancel-Order' }, Data = JSON:encode({ OrderId = orderId }) })
		ao.send = original_ao_send

		local errorResponse = sentMessages[2]
		if not (errorResponse and errorResponse.Action == 'Action-Response' and string.find(errorResponse.Tags.Message, 'Order not found in orderbook')) then
			return false
		end
		
		return Orderbook
	end,
	{ { Pair = { 'token-A', 'token-B' }, Orders = {} } }
)

utils.testSummary()