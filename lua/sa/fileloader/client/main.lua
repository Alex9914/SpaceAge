local function RunOn(def, path)
	local data = file.Read(path, "GAME")
	if not data then
		notification.AddLegacy("File could not be read!", NOTIFY_ERROR, 2)
		return
	end
	if def == "clientside" then
		RunString(data)
		notification.AddLegacy("Script ran " .. def, NOTIFY_GENERIC, 5)
		return
	end

	net.Start("SA_RunLua")
		net.WriteString(def)
		net.WriteString(data)
	net.SendToServer()
end

net.Receive("SA_RunLua", function()
	local str = net.ReadString()
	if not str then
		return
	end
	RunString(str)
end)

local function OpenFileBrowser()
	local frame = vgui.Create("DFrame")
	frame:SetSize(500, 250)
	frame:SetSizable(true)
	frame:SetDraggable(true)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("SpaceAge File Browser")

	local browser = vgui.Create("DFileBrowser", frame)
	browser:Dock(FILL)

	browser:SetPath("GAME")
	browser:SetBaseFolder("")
	browser:SetOpen(true)
	browser:SetCurrentFolder("lua")

	function browser:OnRightClick(path, pnl)
		local menu = DermaMenu()
		local function AddSendOption(str)
			menu:AddOption("Run " .. str, function() RunOn(str, path) end)
		end
		AddSendOption("clientside")
		AddSendOption("serverside")
		AddSendOption("shared")
		AddSendOption("on all clients")
		menu:AddSpacer()
		for _, ply in pairs(player.GetHumans()) do
			local pid = ply:SteamID()
			menu:AddOption("Run on " .. ply:GetName(), function() RunOn(pid, path) end)
		end
		menu:Open()
	end
end
concommand.Add("sa_open_file_browser", function ()
	if not LocalPlayer():IsAdmin() then
		return
	end
	OpenFileBrowser()
end)