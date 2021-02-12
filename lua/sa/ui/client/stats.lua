local SA_MaxNameLength = 24

SA.StatsTable = {}

local function sa_info_msg_credsc()
	local ply = LocalPlayer()
	if not ply.sa_data then
		ply.sa_data = {}
	end

	local c = net.ReadString()
	ply.sa_data.credits = tonumber(c)
	ply.sa_data.score = ply:GetNWString("score")
	ply.sa_data.playtime = net.ReadUInt(32)

	ply.sa_data.formatted_credits = SA.AddCommasToInt(c)
	ply.sa_data.formatted_score = SA.AddCommasToInt(sc)
	ply.sa_data.formatted_playtime = SA.FormatTime(ply.sa_data.playtime)
end
net.Receive("SA_SendBasicInfo", sa_info_msg_credsc)

timer.Create("SA_IncPlayTime", 1, 0, function()
	local ply = LocalPlayer()
	if not ply.sa_data then
		return
	end
	ply.sa_data.playtime = ply.sa_data.playtime + 1
	ply.sa_data.formatted_playtime = SA.FormatTime(ply.sa_data.playtime)
end)

local function SA_ReceiveStatsUpdate(body, code)
	if code ~= 200 then
		return
	end

	SA.StatsTable = {}
	for i, v in pairs(body) do

		local newEntry = {}
		newEntry.name = string.Left(v.name, SA_MaxNameLength)
		newEntry.score = SA.AddCommasToInt(v.score)
		local tempColor = SA.Factions.Colors[v.faction_name]
		if not tempColor then tempColor = Color(255, 100, 0, 255) end
		newEntry.faction_color = tempColor
		newEntry.info = v

		table.insert(SA.StatsTable, newEntry)
	end

	hook.Run("SA_StatsUpdate", SA.StatsTable)
end
local function SA_RequestStatsUpdate()
	SA.API.ListPlayers(SA_ReceiveStatsUpdate)
end
timer.Create("SA_StatsUpdater", 30, 0, SA_RequestStatsUpdate)
timer.Simple(2, SA_RequestStatsUpdate)
