ChatSaver = LibStub('AceAddon-3.0'):NewAddon('ChatSaver','AceConsole-3.0','AceHook-3.0','AceEvent-3.0');
local core = ChatSaver;

core.verified = false;

function core:OnInitialize()
	self:RawHook(SlashCmdList,'JOIN','JoinChannel',true);
	self:RawHook(SlashCmdList,'LEAVE','LeaveChannel',true);
	self:Hook('ToggleChatChannel','ToggleChatChannel',true);
	
	self:RegisterChatCommand('cs','SlashCommand');
	
	if(ChatSaverDB == nil) then ChatSaverDB = {}; end
end

function core:OnEnable()
	self:RegisterEvent('CHAT_MSG_CHANNEL_NOTICE','RejoinChannels');
end

function core:SlashCommand()
	core.verified = false
	core:RejoinChannels();
end

function core:RejoinChannels(event,message,...)
	if(core.verified == true) then
		return;
	end
	
	local currentChannels = {};
	for i = 1,select("#",GetChannelList()),2 do
		local index,channel = select(i,GetChannelList());
		currentChannels[channel] = true;
	end
	
	for channel,information in pairs(ChatSaverDB) do
		if(currentChannels[channel] == nil) then
			JoinPermanentChannel(channel);
			for index,shown in pairs(ChatSaverDB[channel].frames) do
				if(shown) then
					_G['ChatFrame'..index].channelList[table.getn(_G['ChatFrame'..index].channelList) + 1] = channel;
				end
			end
		end
	end
	
	core.verified = true;
end

function core:JoinChannel(msg)
	self.hooks[SlashCmdList].JOIN(msg);
	
	local name = gsub(msg, "%s*([^%s]+).*", "%1");

	if(strlen(name) > 0 and string.match(name,"%a+")) then
		ChatSaverDB[name] = {};
		ChatSaverDB[name]['frames'] = {};
		ChatSaverDB[name]['index'] = GetChannelName(name);
		ChatSaverDB[name]['frames'][DEFAULT_CHAT_FRAME:GetID()] = true;
	end
end

function core:LeaveChannel(msg)
	self.hooks[SlashCmdList].LEAVE(msg);
	
	local number = gsub(msg, "%s*([^%s]+).*", "%1");
	local _,name = GetChannelName(number);
	
	--ChatSaverDB[name] = nil;
end

function core:ToggleChatChannel(checked,channel)
	if(ChatSaverDB[channel] == nil) then 
		return;
	end
	
	if(checked) then
		ChatSaverDB[channel]['frames'][FCF_GetCurrentChatFrameID()] = true;
	else
		ChatSaverDB[channel]['frames'][FCF_GetCurrentChatFrameID()] = false;
	end
end
