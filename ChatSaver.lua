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
	
	self:RegisterEvent('CHANNEL_UI_UPDATE','RejoinChannels');
	self:RegisterEvent('CHAT_MSG_CHANNEL_NOTICE','ProcessChannelChanges');
end

function core:SlashCommand()
	core:RejoinChannels();
end

function core:RejoinChannels(...)
	if(core.firstrun) then
		core:SetupChatSaver();
	end
	
	local currentChannels = {};
	for i = 1,select('#',GetChannelList()) do
		currentChannels[select(i,GetChannelList())] = true
	end
	
	for channel,_ in pairs(ChatSaverDB) do
		if(currentChannels[channel] == nil) then
			JoinPermanentChannel(channel); -- does not place in chat frame properly
			for index,_ in pairs(ChatSaverDB[channel].frames) do
				ChatFrame_AddChannel(_G['ChatFrame'..index],channel);
			end
		end
	end
	
	self:UnregisterEvent('CHANNEL_UI_UPDATE');
end

function core:SetupChatSaver()
	for frame = 1,NUM_CHAT_WINDOWS do 
		local chatWindowChannels = { GetChatWindowChannels(frame) };
		for i = 1,#chatWindowChannels,2 do
			local name,zone = chatWindowChannels[i], chatWindowChannels[i + 1];
			
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

function core:ProcessChannelChanges(_,message,_,_,_,_,_,_,index,name,...)
	if(message == 'YOU_JOINED') then
		local zone = 1;
		for frame = 1,NUM_CHAT_WINDOWS do 
			local chatWindowChannels = { GetChatWindowChannels(frame) };
			for i = 1,#chatWindowChannels,2 do
				if(chatWindowChannels[i] == name) then
					print(chatWindowChannels[i],chatWindowChannels[i + 1]);
					zone = chatWindowChannels[i + 1];
					break;
				end				
			end
		end

		if(zone == 0) then
			ChatSaverDB[name] = {};
			ChatSaverDB[name]['frames'] = {};
			ChatSaverDB[name]['index'] = index;
			ChatSaverDB[name]['frames'][DEFAULT_CHAT_FRAME:GetID()] = true;
		end
	elseif(message == 'YOU_LEFT') then
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
