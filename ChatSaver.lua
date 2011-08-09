ChatSaver = LibStub('AceAddon-3.0'):NewAddon('ChatSaver','AceConsole-3.0','AceHook-3.0','AceEvent-3.0')
local core = ChatSaver

function core:OnInitialize()	
	if ChatSaverDB == nil then 
		core.firstrun = true
		ChatSaverDB = {} 
	else
		core.firstrun = false
	end
end

function core:OnEnable()
	self:Hook('ToggleChatChannel','ToggleChatChannel',true)
	
	self:RegisterEvent('CHAT_MSG_CHANNEL_NOTICE','ProcessChannelChange')
	if core.firstrun then
		self:RegisterEvent('CHANNEL_UI_UPDATE','SetupChatSaver')
	else
		self:RegisterEvent('CHANNEL_UI_UPDATE','RejoinChannels')
	end
end

--[[ 
--	CHANNEL FUNCTIONS 
--	Because GetChannelName() and GetChannelDisplayInfo() are less
--  than good.	
]] --

function core:GetChannelInfo(id)
	local channelNumber,channelName = GetChannelName(id)
	local channelTable = core:GetChannelTable()

	if channelName == nil then
		id = channelTable[id]
		
		if id ~= nil then
			channelNumber,channelName = GetChannelName(id)
		end
	end
	
	return channelNumber,channelName,core:GetChannelCategory(channelNumber)
end

function core:GetChannelTable()
	local channelList = { GetChannelList() }
	local channelTable = {}
	for i = 1,#channelList,2 do
		channelTable[channelList[i]] = channelList[i + 1]
		channelTable[channelList[i + 1]] = channelList[i]
		if type(channelList[i + 1]) == 'string' then
			channelTable[channelList[i + 1]:lower()] = channelList[i]
		end
	end

	return channelTable
end

function core:GetChannelCategory(number)
	for i = 1,GetNumDisplayChannels(),1 do
		local _,_,_,channelNumber,_,_,category = GetChannelDisplayInfo(i)
		
		if channelNumber == number then
			return category
		end
	end
end

--[[ EVENT FUNCTIONS ]] --

function core:ProcessChannelChange(_,message,_,_,_,_,_,_,index,name)
	if message == 'YOU_JOINED' then
		local number,_,category = core:GetChannelInfo(name)
		
		if category == 'CHANNEL_CATEGORY_CUSTOM' then
			ChatSaverDB[name] = {}
			ChatSaverDB[name]['frames'] = {}
			ChatSaverDB[name]['index'] = number
			ChatSaverDB[name]['frames'][DEFAULT_CHAT_FRAME:GetID()] = true
		end
	elseif message == 'YOU_LEFT' then
		--ChatSaverDB[name] = nil
	end
end

function core:RejoinChannels(...)
	local currentChannels = {}
	for i = 1,select('#',GetChannelList()) do
		currentChannels[select(i,GetChannelList())] = true
	end
	
	local sortedChannels = {}
	for channel,_ in pairs(ChatSaverDB) do
		table.insert(sortedChannels,channel)
	end
	table.sort(sortedChannels,function(a,b) return ChatSaverDB[a].index < ChatSaverDB[b].index end)
	
	for _,channel in pairs(sortedChannels) do
		if currentChannels[channel] == nil then
			JoinPermanentChannel(channel) -- does not place in chat frame properly
			for index,_ in pairs(ChatSaverDB[channel].frames) do
				ChatFrame_AddChannel(_G['ChatFrame'..index],channel)
			end
		end
	end
	
	self:UnregisterEvent('CHANNEL_UI_UPDATE')
end

function core:SetupChatSaver(...)
	for frame = 1,NUM_CHAT_WINDOWS do 
		local chatWindowChannels = { GetChatWindowChannels(frame) }
		for i = 1,#chatWindowChannels,2 do
			local number,name,category = core:GetChannelInfo(chatWindowChannels[i])

			if category == 'CHANNEL_CATEGORY_CUSTOM' then
				if ChatSaverDB[name] == nil then
					ChatSaverDB[name] = {}
					ChatSaverDB[name]['frames'] = {}
					ChatSaverDB[name]['index'] = number
				end
			
				ChatSaverDB[name]['frames'][frame] = true
			end
		end
	end
	
	self:UnregisterEvent('CHANNEL_UI_UPDATE')
end

--[[ HOOKED FUNCTIONS ]] --

function core:ToggleChatChannel(checked,channel)
	if ChatSaverDB[channel] == nil then 
		return
	end
	
	if checked then
		ChatSaverDB[channel]['frames'][FCF_GetCurrentChatFrameID()] = true
	else
		ChatSaverDB[channel]['frames'][FCF_GetCurrentChatFrameID()] = nil
	end
end
