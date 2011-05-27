ChatSaver = LibStub('AceAddon-3.0'):NewAddon('ChatSaver','AceConsole-3.0','AceHook-3.0','AceEvent-3.0');
local core = ChatSaver;

function core:OnInitialize()	
	self:RawHook(SlashCmdList,'JOIN','JoinChannel',true);
	self:RawHook(SlashCmdList,'LEAVE','LeaveChannel',true);
	self:Hook('ToggleChatChannel','ToggleChatChannel',true);
	
	self:RegisterChatCommand('cs','SlashCommand');
	
	if(ChatSaverDB == nil) then 
		core.firstrun = true;
		ChatSaverDB = {}; 
	else
		core.firstrun = false;
	end
end

function core:OnEnable()
	self:RegisterEvent('CHAT_MSG_CHANNEL_NOTICE','RejoinChannels');
	
	--store curret channels if this is our first run
	if(core.firstrun) then
		for frame = 1,10 do 
			local frameChannels = { GetChatWindowChannels(frame) };
			for i = 1,#frameChannels,2 do
				local name,zone = frameChannels[i], frameChannels[i+1]
				
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
	end
end

function core:SlashCommand()
	core:RejoinChannels();
end

function core:RejoinChannels(event,message,...)
	local currentChannels = { GetChannelList() };
	
	for channel,information in pairs(ChatSaverDB) do
		if(currentChannels[channel] == nil) then
			JoinPermanentChannel(channel);
			for index,shown in pairs(ChatSaverDB[channel].frames) do
				if(shown) then
					ChatFrame_AddChannel(_G['ChatFrame'..index],channel);
				end
			end
		end
	end
	
	self:UnregisterEvent('CHAT_MSG_CHANNEL_NOTICE');
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
