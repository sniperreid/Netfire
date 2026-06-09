local NetworkEvent = require(script.NetworkEvent)
local Types = require(script.Types)

local Signal = require("./Signal")

export type NetworkEvent<A... = ()> = Types.NetworkEvent<A...>

local EventsCache = {} :: {NetworkEvent.newEvent}

local Netfire = {}

function Netfire:GetEvent(JobName: string)
	for i, Event in EventsCache do
		if Event.name == JobName then
			return Event
		end
	end
end

--[[
	@param JobName string,
	@param typecasters enums
]]--
function Netfire:Bind<A..., B...>(JobName: string, ...: A...): NetworkEvent<A...>
	assert(not self:GetEvent(JobName), `{JobName} has already been registered.`)
	
	local newEvent = NetworkEvent.new(JobName)
	
	table.insert(EventsCache, newEvent)
	
	return newEvent
end

return Netfire
