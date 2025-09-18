if PingCount == nil then
  PingCount = 0
end

Handlers.add(
  'ping-handler',
  Handlers.utils.hasMatchingTag('Action', 'Ping'),
  function (msg)
    PingCount = PingCount + 1
    ao.send({
      Target = msg.From,
      Tags = { Action = 'Pong' },
      Data = 'Received ping number: ' .. PingCount
    })
  end
)