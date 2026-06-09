export type Signal<T...> = {
	Connect: (self: Signal<T...>, callback: (T...) -> ()) -> RBXScriptConnection,
	ConnectAsync: (self: Signal<T...>, callback: (T...) -> ()) -> RBXScriptConnection,
	Once: (self: Signal<T...>, callback: (T...) -> ()) -> RBXScriptConnection,
	Wait: (self: Signal<T...>) -> T...,
}

export type EventInfo = {
	name: string,
	Job: Folder,
	RemoteEvent: RemoteEvent,
	RemoteFunction: RemoteFunction
}

export type NetworkFunction<A..., B...> = {
	--server
	OnServerInvoke: (Player, A...) -> B...,
	OnServerInvokeAsync: (Player, A...) -> B...,	
	--shared
	SetRateLimit: (self: NetworkFunction<A..., B...>, max: number, timeWindow: number) -> NetworkFunction<A..., B...>,
	SetResponseTimeout: (self: NetworkFunction<A..., B...>, timeout: number) -> NetworkFunction<A..., B...>,
	--client
	InvokeServer: (self: NetworkFunction<A..., B...>, A...) -> B...,
}

export type NetworkEvent<A...> = {
	--server
	OnServerEvent: Signal<(Player, A...)>,
	FireClient: (self: NetworkEvent<A...>, player: Player, A...) -> (),
	FireClients: (self: NetworkEvent<A...>, players: {Player}, A...) -> (),
	FireAllClients: (self: NetworkEvent<A...>, A...) -> (),
	FireAllExcept: (self: NetworkEvent<A...>, excludePlayer: Player, A...) -> (),	
	--shared
	Response: <B...>(self: NetworkEvent<A...>, B...) -> NetworkFunction<A..., B...>,
	Unreliable: (self: NetworkEvent<A...>) -> NetworkEvent<A...>,
	SetRateLimit: (self: NetworkEvent<A...>, max: number, timeWindow: number) -> NetworkEvent<A...>,
	--client
	OnClientEvent: Signal<A...>,
	FireServer: (self: NetworkEvent<A...>, A...) -> (),
}

return {}
