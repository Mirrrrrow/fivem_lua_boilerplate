Client = {}
Client.Functions = {}

require 'client.config'
require 'client.utils'

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end

    Client.Functions.cleanup()
end)
