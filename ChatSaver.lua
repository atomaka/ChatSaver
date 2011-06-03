ChatSaver = LibStub('AceAddon-3.0'):NewAddon('ChatSaver','AceConsole-3.0','AceHook-3.0','AceEvent-3.0');
local core = ChatSaver;

function core:OnInitialize()	
	self:RegisterChatCommand('cs','SlashCommand');
	
	if(ChatSaverDB == nil) then 
		core.firstrun = true;
		ChatSaverDB = {}; 
	else
		core.firstrun = false;
	end
end

function core:OnEnable()
	self:RawHook(SlashCmdList,'JOIN','JoinChannel',true);
	self:RawHook(SlashCmdList,'LEAVE','LeaveChannel',true);
	self:Hook('ToggleChatChannel','ToggleChatChannel',true);
	
	self:RegisterEvent('CHANNEL_UI_UPDATE','RejoinChannels');
	if(core.firstrun) then
		self:RegisterEvent('CHAT_MSG_CHANNEL_NOTICE','SetupChatSaver');
	end
end

function core:SlashCommand()
	core:RejoinChannels();
end

function core:RejoinChannels(...)
	local currentChannels = {};
	for i = 1,select('#',GetChannelList()) do
		currentChannels[select(i,GetChannelList())] = true
	end
	
	local sortedChannels = {};
	for channel,_ in pairs(ChatSaverDB) do
		table.insert(sortedChannels,channel);
	end
	
	table.sort(sortedChannels,function(a,b) return ChatSaverDB[a].index < ChatSaverDB[b].index end);
	
	for _,channel in pairs(sortedChannels) do
		if(currentChannels[channel] == nil) then
			JoinPermanentChannel(channel); -- does not place in chat frame properly
			for index,_ in pairs(ChatSaverDB[channel].frames) do
				ChatFrame_AddChannel(_G['ChatFrame'..index],channel);
			end
		end
	end
	
	self:UnregisterEvent('CHANNEL_UI_UPDATE');
end

function core:SetupChatSaver(...)
	for frame = 1,NUM_CHAT_WINDOWS do 
		local chatWindowChannels = { GetChatWindowChannels(frame) };
		for i = 1,#chatWindowChannels,2 do
			local name,zone = chatWindowChannels[i],chatWindowChannels[i + 1];
			
			if(zone == 0) then
				if(ChatSaverDB[name] == nil) then
					ChatSaverDB[name] = {};
					ChatSaverDB[name]['frames'] = {};
					ChatSaverDB[name]['index'] = GetChannelName(name);
				end
			
				ChatSaverDB[name]['frames'][frame] = true;
			end
		end
	end
	
	self:UnregisterEvent('CHAT_MSG_CHANNEL_NOTICE');
end

function core:GetChannelInfo(id)
	--addon.lua:373
	--channelapi.lua:65
	--channelapi.lua:55
	local channelTable = core:GetChanneltable();
end

function core:GetChannelTable()
	local channelList = { GetChannelList() };
	local channelTable = {};
	for i = 1,#channelList,2 do
		channelTable[channelList[i]] = channelList[i + 1];
		channelTable[channelList[i + 1]] = channelList[i];
		if(type(channelList[i + 1]) == 'string') then
			channelTable[channelList[i + 1]:lower()] = channelList[i];
		end
	end
	
	return channelTable;
end

function core:JoinChannel(msg)
	self.hooks[SlashCmdList].JOIN(msg);
	
	local name = gsub(msg, "%s*([^%s]+).*", "%1");
	
	if(strlen(name) == 0 or not string.match(name,"%a+")) then
		return;
	end
	
	local index = GetChannelName(name); -- in game function does not handle "General" or "Trade"
	
	local _,_,_,_,_,_,category,_,_ = GetChannelDisplayInfo(index);
	print(category);

	if(category == CHANNEL_CATEGORY_CUSTOM) then	
		ChatSaverDB[name] = {};
		ChatSaverDB[name]['frames'] = {};
		ChatSaverDB[name]['index'] = index;
		ChatSaverDB[name]['frames'][DEFAULT_CHAT_FRAME:GetID()] = true;
	end
end

function core:LeaveChannel(msg)
	self.hooks[SlashCmdList].LEAVE(msg);
	
	local number = gsub(msg, "%s*([^%s]+).*", "%1");
	local _,name = GetChannelName(number);
	
	ChatSaverDB[name] = nil;
end

function core:ToggleChatChannel(checked,channel)
	if(ChatSaverDB[channel] == nil) then 
		return;
	end
	
	if(checked) then
		ChatSaverDB[channel]['frames'][FCF_GetCurrentChatFrameID()] = true;
	else
		ChatSaverDB[channel]['frames'][FCF_GetCurrentChatFrameID()] = nil;
	end
end
