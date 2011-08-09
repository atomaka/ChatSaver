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
	self:Hook('ToggleChatChannel','ToggleChatChannel',true);
	
	self:RegisterEvent('CHAT_MSG_CHANNEL_NOTICE','ProcessChannelChange');
	if(core.firstrun) then
		--self:RegisterEvent('CHAT_MSG_CHANNEL_NOTICE','SetupChatSaver');
	end
end

function core:SlashCommand()
	core:RejoinChannels();
end

--[[ 
--	CHANNEL FUNCTIONS 
--	Because GetChannelName() and GetChannelDisplayInfo() are less
--  than good.	
]] --

function core:GetChannelInfo(id)
	local channelNumber,channelName = GetChannelName(id);
	local channelTable = core:GetChannelTable();

	if(channelName == nil) then
		id = channelTable[id];
		
		if(id ~= nil) then
			channelNumber,channelName = GetChannelName(id);
		end
	end
	
	return channelNumber,channelName,core:GetChannelCategory(channelNumber);
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

function core:GetChannelCategory(number)
	for i = 1,GetNumDisplayChannels(),1 do
		local _,_,_,channelNumber,_,_,category = GetChannelDisplayInfo(i);
		
		if(channelNumber == number) then
			return category;
		end
	end
end

--[[ EVENT FUNCTIONS ]] --

function ProcessChannelChange(_,message,_,_,_,_,_,_,index,name)
	if message == 'YOU_JOINED' then
		local number,_,category = core:GetChannelInfo(name)
		
		if category == 'CHANNEL_CATEGORY_CUSTOM' then
			ChatSaverDB[name] = {};
			ChatSaverDB[name]['frames'] = {};
			ChatSaverDB[name]['index'] = number;
			ChatSaverDB[name]['frames'][DEFAULT_CHAT_FRAME:GetID()] = true;
		end
	elseif message == 'YOU_LEFT' then
		ChatSaverDB[name] = nil
	end
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
			local number,name,category = core:GetChannelInfo(chatWindowChannels[i]);

			if(category == 'CHANNEL_CATEGORY_CUSTOM') then
				if(ChatSaverDB[name] == nil) then
					ChatSaverDB[name] = {};
					ChatSaverDB[name]['frames'] = {};
					ChatSaverDB[name]['index'] = number;
				end
			
				ChatSaverDB[name]['frames'][frame] = true;
			end
		end
	end
	
	self:UnregisterEvent('CHAT_MSG_CHANNEL_NOTICE');
end

function core:StoreChannel(_,_,_,_,_,_,_,_,_,name)
	local number,channelName,category = core:GetChannelInfo(name);
	
	if(category == 'CHANNEL_CATEGORY_CUSTOM') then	
		ChatSaverDB[name] = {};
		ChatSaverDB[name]['frames'] = {};
		ChatSaverDB[name]['index'] = number;
		ChatSaverDB[name]['frames'][DEFAULT_CHAT_FRAME:GetID()] = true;
	end
	
	self:UnregisterEvent('CHAT_MSG_CHANNEL_NOTICE');
end

--[[ HOOKED FUNCTIONS ]] --

function core:JoinChannel(msg)
	self.hooks[SlashCmdList].JOIN(msg);
	
	local name = gsub(msg,"%s*([^%s]+).*","%1");
	
	if(strlen(name) > 0 and string.match(name,"%a+")) then
		self:RegisterEvent('CHAT_MSG_CHANNEL_NOTICE','StoreChannel');
	end
end

function core:LeaveChannel(msg)
	self.hooks[SlashCmdList].LEAVE(msg);
	
	local id = gsub(msg,"%s*([^%s]+).*","%1");
	
	if(strlen(id) > 0) then
		local _,name = core:GetChannelInfo(id);
		ChatSaverDB[name] = nil;
	end
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
