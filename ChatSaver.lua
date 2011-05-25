ChatSaver = LibStub('AceAddon-3.0'):NewAddon('ChatSaver','AceHook-3.0','AceEvent-3.0');
local core = ChatSaver;

function core:OnInitialize()
	self:RegisterEvent('PLAYER_LOGIN','ReloadUI');
end

function core:ReloadUI()
	channelList = {};
	
	for i = 1, select("#",GetChannelList()), 2 do
		local index,channel = select(i,GetChannelList());
		channelList[index] = channel;
	end
	
	myChannels = {};
	
	myChannels[1] = 'General';
	myChannels[2] = 'Trade';
	myChannels[3] = 'LocalDefense';
	myChannels[4] = 'ncaheal';
	myChannels[5] = 'ncabads';
	myChannels[6] = 'ncafail';
	
	for index,channel in pairs(myChannels) do
		if(channel ~= channelList[index]) then 
			print('Channel ',channel,' not joined.  Rejoining now!');
			JoinPermanentChannel(channel);
		end
	end
end

--AddChatWindowChannel(chatFrameIndex, "channel") - Make a chat channel visible in a specific ChatFrame.
--Chat output architecture has changed since release; calling this function alone is no longer sufficient to add a channel to a particular frame in the default UI. Use ChatFrame_AddChannel(chatFrame, "channelName") instead, like so:
