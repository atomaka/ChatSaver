ChatSaver = LibStub('AceAddon-3.0'):NewAddon('ChatSaver','AceHook-3.0','AceEvent-3.0');
local core = ChatSaver;

local db;

function core:OnInitialize()
	self:RegisterEvent('PLAYER_LOGIN','ReloadUI');
	self:Hook(SlashCmdList,'JOIN','JoinChannel',true);
end

function core:ReloadUI()
	channelList = {};
	
	for i = 1, select("#",GetChannelList()), 2 do
		local index,channel = select(i,GetChannelList());
		channelList[index] = channel;
	end
	
	--force channel list for now
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
			
			local i = 1;
			while ( DEFAULT_CHAT_FRAME.channelList[i] ) do
				i = i + 1;
			end
			DEFAULT_CHAT_FRAME.channelList[i] = channel;
		end
	end
end

function core:JoinChannel()
	--need to store channel in db
end