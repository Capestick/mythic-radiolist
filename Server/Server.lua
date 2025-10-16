
local Framework = 'Mythic'
local Core = nil

if Config.UseRPName then
	if GetResourceState('mythic-base') ~= 'missing' then
		Framework = 'Mythic'
		Core = exports['mythic-base']
	end
end

local CustomNames = {}
local PlayersInCurrentRadioChannel = {}


local voiceData = {}
local radioData = {}


local VOIP = nil
local Fetch = nil

AddEventHandler('VOIP:Shared:DependencyUpdate', function()
	VOIP = exports['mythic-base']:FetchComponent('VOIP')
	Fetch = exports['mythic-base']:FetchComponent('Fetch')
end)

AddEventHandler("playerDropped", function()
	local src = source
	
	local currentRadioChannel = Player(src).state.radioChannel
	
	local playersInCurrentRadioChannel = CreateFullRadioListOfChannel(currentRadioChannel)
	for _, player in pairs(playersInCurrentRadioChannel) do
		if player.Source ~= src then
			TriggerClientEvent("JLRP-RadioList:Client:SyncRadioChannelPlayers", player.Source, src, 0, playersInCurrentRadioChannel)
		end
	end
	playersInCurrentRadioChannel = {}
	
	if Config.LetPlayersSetTheirOwnNameInRadio and Config.ResetPlayersCustomizedNameOnExit then
		local playerIdentifier = GetIdentifier(src)
		if CustomNames[playerIdentifier] and CustomNames[playerIdentifier] ~= nil then
			CustomNames[playerIdentifier] = nil
		end
	end
end)





local radioChannels = {}

RegisterNetEvent('VOIP:Radio:Server:SetChannel')
AddEventHandler('VOIP:Radio:Server:SetChannel', function(channelToJoin)
	local src = source	
	local radioChannelToJoin = tonumber(channelToJoin)
	if not radioChannelToJoin then return end
	
	local currentChannel = Player(src).state.radioChannel or 0
	
	
	if currentChannel > 0 and radioChannels[currentChannel] then
		radioChannels[currentChannel][src] = nil
		if next(radioChannels[currentChannel]) == nil then
			radioChannels[currentChannel] = nil
		end
	end
	
	
	if radioChannelToJoin > 0 then
		radioChannels[radioChannelToJoin] = radioChannels[radioChannelToJoin] or {}
		radioChannels[radioChannelToJoin][src] = true
		
		Player(src).state.radioChannel = radioChannelToJoin
	else
		
		Player(src).state.radioChannel = 0
	end
	
	
	SetTimeout(200, function()
		if radioChannelToJoin == 0 then
			Disconnect(src, currentChannel)
		else
			Connect(src, currentChannel, radioChannelToJoin)
		end
	end)
end)


RegisterNetEvent('VOIP:Radio:Server:SetTalking')
AddEventHandler('VOIP:Radio:Server:SetTalking', function(isTalking)
	local src = source
	local radioChannel = Player(src).state.radioChannel or 0
	
	if radioChannel > 0 then
		
		if radioChannels[radioChannel] then
			for player, _ in pairs(radioChannels[radioChannel]) do
				TriggerClientEvent('VOIP:Radio:Client:SetPlayerTalkState', player, src, isTalking)
			end
		end
	end
end)

function Connect(src, currentRadioChannel, radioChannelToJoin)
	if currentRadioChannel > 0 then 
		Disconnect(src, currentRadioChannel)
	end
	Wait(100) 

	local playersInCurrentRadioChannel = CreateFullRadioListOfChannel(radioChannelToJoin, src)
	
	for _, player in pairs(playersInCurrentRadioChannel) do
		TriggerClientEvent("JLRP-RadioList:Client:SyncRadioChannelPlayers", player.Source, src, radioChannelToJoin, playersInCurrentRadioChannel)
	end
	playersInCurrentRadioChannel = {}
end

function Disconnect(src, currentRadioChannel) 
	local playersInCurrentRadioChannel = CreateFullRadioListOfChannel(currentRadioChannel, src)
	TriggerClientEvent("JLRP-RadioList:Client:SyncRadioChannelPlayers", src, src, 0, playersInCurrentRadioChannel)
	for _, player in pairs(playersInCurrentRadioChannel) do
		TriggerClientEvent("JLRP-RadioList:Client:SyncRadioChannelPlayers", player.Source, src, 0, playersInCurrentRadioChannel)
	end
	playersInCurrentRadioChannel = {}
end

function CreateFullRadioListOfChannel(RadioChannel, currentPlayer)
	local playersInRadio = {}
	
	if radioChannels[RadioChannel] then
		for source, _ in pairs(radioChannels[RadioChannel]) do
			playersInRadio[source] = {}
			playersInRadio[source].Source = source
			playersInRadio[source].Name = GetPlayerNameForRadio(source)
		end
	else
		if currentPlayer then
			playersInRadio[currentPlayer] = {}
			playersInRadio[currentPlayer].Source = currentPlayer
			playersInRadio[currentPlayer].Name = GetPlayerNameForRadio(currentPlayer)
		end
	end
	
	return playersInRadio
end

function GetPlayerNameForRadio(source)
    if Config.LetPlayersSetTheirOwnNameInRadio then
        local playerIdentifier = GetIdentifier(source)
        if CustomNames[playerIdentifier] and CustomNames[playerIdentifier] ~= nil then
            return CustomNames[playerIdentifier]
        end
    end
    
    if Config.UseRPName then    
        local name = nil
        if Framework == 'Mythic' then
            
            if Fetch then
                local character = Fetch:Source(source):GetData('Character')
                if character then
                    local first = character:GetData('First')
                    local last = character:GetData('Last')
                    
                    if first and last then
                        name = first .. ' ' .. last
                    elseif first then
                        name = first
                    end
                end
            end
        end    
        return name
    else
        return GetPlayerName(source)
    end
end

if Config.LetPlayersSetTheirOwnNameInRadio then
	local commandLength = string.len(Config.RadioListChangeNameCommand)
	local argumentStartIndex = commandLength + 2
	RegisterCommand(Config.RadioListChangeNameCommand, function(source, args, rawCommand)
		local _source = source
		if _source > 0 then
			local customizedName = rawCommand:sub(argumentStartIndex)
			if customizedName ~= "" and customizedName ~= " " and customizedName ~= nil then
				CustomNames[GetIdentifier(_source)] = customizedName			
				local currentRadioChannel = Player(_source).state.radioChannel
				if currentRadioChannel > 0 then
					Connect(_source, currentRadioChannel, currentRadioChannel)
				end				
			end
		end
	end)
end

function GetIdentifier(source)
	for _, v in ipairs(GetPlayerIdentifiers(source)) do
		if string.match(v, 'license:') then
			local identifier = string.gsub(v, 'license:', '')
			return identifier
		end
	end
end
