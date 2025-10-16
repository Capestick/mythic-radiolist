local PlayerServerID = GetPlayerServerId(PlayerId())
local PlayersInRadio = {}
local firstTimeEventGetsTriggered = true
local RadioChannelsName = {}


RegisterNetEvent('JLRP-RadioList:Client:SyncRadioChannelPlayers')
AddEventHandler('JLRP-RadioList:Client:SyncRadioChannelPlayers', function(src, RadioChannelToJoin, PlayersInRadioChannel)
	if firstTimeEventGetsTriggered then
		for i, v in pairs(Config.RadioChannelsWithName) do
			local frequency = tonumber(i)
			local minFrequency, maxFrequency = frequency, frequency + 1
			for index = minFrequency, maxFrequency + 0.0, 0.01 do
				RadioChannelsName[tostring(index)] = tostring(v)
			end
			if frequency ~= 0 then
				RadioChannelsName[tostring(frequency)] = tostring(v) 
			end
		end	
		firstTimeEventGetsTriggered = false
	end
	PlayersInRadio = PlayersInRadioChannel
	if src == PlayerServerID then
		if RadioChannelToJoin > 0 then
			local radioChannelToJoin = tostring(RadioChannelToJoin)
			if RadioChannelsName[radioChannelToJoin] and RadioChannelsName[radioChannelToJoin] ~= nil then 
				HideTheRadioList() 
				for index, player in pairs(PlayersInRadio) do
					if player.Source ~= src then
						SendNUIMessage({ radioId = player.Source, radioName = player.Name, channel = RadioChannelsName[radioChannelToJoin] }) 
					else
						SendNUIMessage({ radioId = src, radioName = player.Name, channel = RadioChannelsName[radioChannelToJoin], self = true  }) 
					end
					
				end
				ResetTheRadioList() 
			else
				HideTheRadioList() 
				for index, player in pairs(PlayersInRadio) do
					if player.Source ~= src then
						SendNUIMessage({ radioId = player.Source, radioName = player.Name, channel = radioChannelToJoin }) 
					else
						SendNUIMessage({ radioId = src, radioName = player.Name, channel = radioChannelToJoin, self = true  }) 
					end
				end
				ResetTheRadioList() 
			end
		else
			ResetTheRadioList() 
			HideTheRadioList() 	
		end
	elseif src ~= PlayerServerID then
		if RadioChannelToJoin > 0 then
			local radioChannelToJoin = tostring(RadioChannelToJoin)
			if RadioChannelsName[radioChannelToJoin] and RadioChannelsName[radioChannelToJoin] ~= nil then 
				SendNUIMessage({ radioId = src, radioName = PlayersInRadio[src].Name, channel = RadioChannelsName[radioChannelToJoin] }) 
				ResetTheRadioList() 
			else
				SendNUIMessage({ radioId = src, radioName = PlayersInRadio[src].Name, channel = radioChannelToJoin }) 
			end
		else
			SendNUIMessage({ radioId = src }) 
		end
	end
	
end)


RegisterNetEvent('VOIP:Radio:Client:SetPlayerTalkState')
AddEventHandler('VOIP:Radio:Client:SetPlayerTalkState', function(src, talkingState)
	SendNUIMessage({ radioId = src, radioTalking = talkingState }) 
end)


RegisterNetEvent('VOIP:Radio:Client:SetPlayerRadio')
AddEventHandler('VOIP:Radio:Client:SetPlayerRadio', function(radioChannel)
	
	if radioChannel == 0 then
		
		TriggerEvent('JLRP-RadioList:Client:DisconnectPlayerCurrentChannel')
	end
end)

RegisterNetEvent('JLRP-RadioList:Client:DisconnectPlayerCurrentChannel')
AddEventHandler('JLRP-RadioList:Client:DisconnectPlayerCurrentChannel', function()
	ResetTheRadioList() 
	HideTheRadioList()
end)


RegisterNetEvent('Mythic-RadioList:Client:UpdateChannel')
AddEventHandler('Mythic-RadioList:Client:UpdateChannel', function(channel)
	
end)


function ResetTheRadioList()
	PlayersInRadio = {}
end


function HideTheRadioList()
	SendNUIMessage({ clearRadioList = true }) 
end

if Config.LetPlayersChangeVisibilityOfRadioList then
	local visibility = true
	RegisterCommand(Config.RadioListVisibilityCommand,function()
		visibility = not visibility
		SendNUIMessage({ changeVisibility = true, visible = visibility })
	end)
	TriggerEvent("chat:addSuggestion", "/"..Config.RadioListVisibilityCommand, "Show/Hide Radio List")
end

if Config.LetPlayersSetTheirOwnNameInRadio then
	TriggerEvent("chat:addSuggestion", "/"..Config.RadioListChangeNameCommand, "Customize your name to be shown in radio list", { { name = 'customized name', help = "Enter your desired name to be shown in radio list" } })
end
