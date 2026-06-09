local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Signal = require("../Signal")

local SharedEvents

if RunService:IsClient() then
	SharedEvents = ReplicatedStorage:WaitForChild("SharedEvents")
else
	SharedEvents = Instance.new("Folder")
	SharedEvents.Name = "SharedEvents"
	SharedEvents.Parent = ReplicatedStorage
end

local Netfire = script.Parent
local Types = require(Netfire.Types)

local NetworkEvent = {}
NetworkEvent.__index = NetworkEvent

export type newEvent = typeof(setmetatable({} :: Types.EventInfo, NetworkEvent))

--Server
function NetworkEvent:FireClient(...)
	assert(RunService:IsServer(), `[{script.Name}] - FireClient must be ran on the server.`)

	return self.RemoteEvent:FireClient(...)
end

function NetworkEvent:FireAllClients(...)
	assert(RunService:IsServer(), `[{script.Name}] - FireAllClients must be ran on the server.`)

	return self.RemoteEvent:FireAllClients(...)
end

function NetworkEvent:FireAllExcept(excludePlayer: Player, ...)
	assert(RunService:IsServer(), `[{script.Name}] - FireAllExcept must be ran on the server.`)
	
	for i, Player in Players:GetPlayers() do
		if Player ~= excludePlayer then
			self:FireClient(Player, ...)
		end
	end
end

function NetworkEvent:InvokeClient(...)
	assert(RunService:IsServer(), `[{script.Name}] - InvokeClient must be ran on the server.`)

	return self.RemoteFunction:InvokeClient(...)
end

--Client
function NetworkEvent:FireServer(...)
	assert(RunService:IsClient(), `[{script.Name}] - FireServer must be ran on the client.`)
	
	return self.RemoteEvent:FireServer(...)
end

function NetworkEvent:InvokeServer(...)
	assert(RunService:IsClient(), `[{script.Name}] - InvokeServer must be ran on the client.`)
	
	return self.RemoteFunction:InvokeServer()
end

--Shared
function NetworkEvent:Response()
	-- change type checker to Invokes
	return self
end

function NetworkEvent.createJobHousing(name: string): Folder
	if SharedEvents:FindFirstChild(name) then
		return SharedEvents[name]
	end
	
	local Folder = Instance.new("Folder")
	Folder.Name = name
	Folder.Parent = SharedEvents
	
	local RemoteEvent = Instance.new("RemoteEvent")
	RemoteEvent.Parent = Folder
	
	local RemoteFunction = Instance.new("RemoteFunction")
	RemoteFunction.Parent = Folder
	
	return Folder
end

function NetworkEvent.new(JobName: string): newEvent
	local thisEvent = setmetatable({}, NetworkEvent)
	
	thisEvent.name = JobName
	
	thisEvent.Job = NetworkEvent.createJobHousing(JobName)
	thisEvent.RemoteEvent = thisEvent.Job.RemoteEvent
	thisEvent.RemoteFunction = thisEvent.Job.RemoteFunction
	
	thisEvent.OnServerEvent = Signal.new("OnServerEvent")
	thisEvent.OnClientEvent = Signal.new("OnClientEvent")
	
	if RunService:IsServer() then
		thisEvent.RemoteEvent.OnServerEvent:Connect(function(...)
			thisEvent.OnServerEvent:Fire(...)
		end)
		
		thisEvent.RemoteFunction.OnServerInvoke = function(...)
			if thisEvent.OnServerInvoke then
				return thisEvent.OnServerInvoke(...)
			end
			
			return error(`{JobName} is not returning a valid response.`)
		end
	elseif RunService:IsClient() then
		thisEvent.RemoteEvent.OnClientEvent:Connect(function(...)
			thisEvent.OnClientEvent:Fire(...)
		end)
		
		thisEvent.RemoteFunction.OnClientInvoke = function(...)
			if thisEvent.OnClientInvoke then
				return thisEvent.OnClientInvoke(...)
			end

			return error(`{JobName} is not returning a valid response.`)
		end
	end
	
	return thisEvent
end

return NetworkEvent
