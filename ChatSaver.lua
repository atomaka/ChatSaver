ChatSaver = LibStub('AceAddon-3.0'):NewAddon('ChatSaver','AceConsole-3.0','AceHook-3.0','AceEvent-3.0');
local core = ChatSaver;

local db;

function core:OnInitialize()
	self:RawHook(SlashCmdList,'JOIN','JoinChannel',true);
	self:RawHook(SlashCmdList,'LEAVE','JoinChannel',true);
	
	self:RegisterChatCommand('cs','SlashCommand');
	
	if(ChatSaverDB == nil) then ChatSaverDB = {}; end
end

function core:OnEnable()
	self:RegisterEvent('CHAT_MSG_CHANNEL_NOTICE','RejoinChannels');
end

function core:SlashCommand()
	core:RejoinChannels();
end

function core:RejoinChannels(event,message,...)
	if(message == 'YOU_LEFT') then
		return;
	end

	local channelList = {};
	for i = 1, select("#",GetChannelList()), 2 do
		local index,channel = select(i,GetChannelList());
		channelList[index] = channel;
	end
	
	for channel,information in pairs(ChatSaverDB) do
		local found = false;
		for jIndex,jChannel in pairs(channelList) do
			if(jChannel == channel) then 
				found = true;
			end
		end
		
		if(found == false) then
			JoinPermanentChannel(channel);
			DEFAULT_CHAT_FRAME.channelList[table.getn(DEFAULT_CHAT_FRAME.channelList) + 1] = channel;
		end
	end
end

function core:JoinChannel(msg)
	self.hooks[SlashCmdList].JOIN(msg);
	
	local name = gsub(msg, "%s*([^%s]+).*", "%1");

	ChatSaverDB[name] = {};
	ChatSaverDB[name]['frames'] = {};
	ChatSaverDB[name]['index'] = GetChannelName(name);
	ChatSaverDB[name]['frames'][DEFAULT_CHAT_FRAME:GetID()] = true;
end

function core:LeaveChannel(msg)
	self.hooks[SlashCmdList].LEAVE(msg);
	
	local number = gsub(msg, "%s*([^%s]+).*", "%1");
	local _,name = GetChannelName(number);
	
	ChatSaverDB[name] = nil;
end
