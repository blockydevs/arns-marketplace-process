local json = require('json')
local u = require('utils')

local H = {}

-- Minimal ETH address helpers with best-effort EIP-55 formatting
local function isValidEthAddress(address)
	return type(address) == 'string' and #address == 42 and string.match(address, '^0x[%x]+$') ~= nil
end

local function isValidArweaveAddress(address)
	return type(address) == 'string' and #address == 43 and string.match(address, '^[%w-_]+$') ~= nil
end

local function isValidUnsafeAddress(address)
	if not address then return false end
	local match = string.match(address, '^[%w_-]+$')
	return match ~= nil and #address >= 1 and #address <= 128
end

function H.isValidAOAddress(address, allowUnsafe)
	allowUnsafe = allowUnsafe or false
	if not address then return false end
	if allowUnsafe then return isValidUnsafeAddress(address) end
	return isValidArweaveAddress(address) or isValidEthAddress(address)
end

local function tryKeccak256Hex(lowerHexNoPrefix)
	-- Attempt to use a crypto provider if available (e.g., .common.crypto from aos blueprints)
	local ok, crypto = pcall(require, '.common.crypto')
	if ok and crypto and crypto.digest and crypto.digest.keccak256 then
		local hash = crypto.digest.keccak256(lowerHexNoPrefix)
		if hash and hash.asHex then
			return hash.asHex()
		end
	end
	return nil
end

function H.formatEIP55Address(address)
	local hex = string.lower(string.sub(address, 3))
	local hashHex = tryKeccak256Hex(hex)
	if not hashHex then
		-- Fallback: if keccak not available, return as-is (already valid ETH)
		return address
	end
	local checksumAddress = '0x'
	for i = 1, #hashHex do
		local hexChar = string.sub(hashHex, i, i)
		local hexCharValue = tonumber(hexChar, 16)
		local char = string.sub(hex, i, i)
		if hexCharValue > 7 then
			char = string.upper(char)
		end
		checksumAddress = checksumAddress .. char
	end
	return checksumAddress
end

function H.formatAddress(address)
	if isValidEthAddress(address) then
		return H.formatEIP55Address(address)
	end
	return address
end

local function formatKnownAddresses(msg)
	if H.isValidAOAddress(msg.From) then
		msg.From = H.formatAddress(msg.From)
	end
	local known = { 'Recipient', 'Controller', 'Sender' }
	for _, k in ipairs(known) do
		if msg.Tags[k] then
			if H.isValidAOAddress(msg.Tags[k]) then
				msg.Tags[k] = H.formatAddress(msg.Tags[k])
			end
			msg[k] = msg.Tags[k]
		end
	end
end

local function errorTraceback(err)
	return debug.traceback(err)
end

function H.createHandler(tagName, tagValue, handler, position)
	local where = position or 'add'
	return Handlers[where](
		tagValue,
		Handlers.utils.continue(Handlers.utils.hasMatchingTag(tagName, tagValue)),
		function(msg)
			formatKnownAddresses(msg)

			local ok, res = xpcall(function()
				return handler(msg)
			end, errorTraceback)

			if not ok then
				u.handleError({
					Target = msg.From,
					Action = tagValue .. '-Error',
					Message = tostring(res),
					Quantity = msg.Tags.Quantity,
					TransferToken = msg.From,
					OrderGroupId = msg.Tags['X-Group-ID'] or 'None'
				})
				return
			end

			if res ~= nil then
				local payload = type(res) == 'string' and res or json.encode(res)
				ao.send({
					Target = msg.From,
					Action = tagValue .. '-Notice',
					Data = payload
				})
			end
		end
	)
end

function H.createActionHandler(action, handler, position)
	return H.createHandler('Action', action, handler, position)
end

return H


