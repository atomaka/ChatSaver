ChatSaver = LibStub('AceAddon-3.0'):NewAddon('ChatSaver','AceHook-3.0','AceEvent-3.0');
local core = ChatSaver;

function core:OnEnable()
	self:RegisterEvent('PLAYER_LOGIN','ReloadUI');
end

function core:ReloadUI()
	channels = ListChannels();
	print('Channels' .. channels);
end

function core:JoinChannelByName(chatFrameIndex,channel)

end

--AddChatWindowChannel(chatFrameIndex, "channel") - Make a chat channel visible in a specific ChatFrame.
--Chat output architecture has changed since release; calling this function alone is no longer sufficient to add a channel to a particular frame in the default UI. Use ChatFrame_AddChannel(chatFrame, "channelName") instead, like so:
