local data, isok, merror

--require("glon")
local function glon_encode(tbl)
	return util.TableToJSON(tbl)
end
local function glon_decode(str)
	return util.JSONToTable(str)
end


AddCSLuaFile("autorun/client/cl_sa_hud.lua")

if(type(SA) != "table") then
	SA = {}
end

local RD = nil

timer.Simple(1,function() RD = CAF.GetAddon("Resource Distribution") end)


WorldClasses = {}
local function AddWorldClass(name)
	table.insert(WorldClasses,name)
end
AddWorldClass("prop_door_rotating")
AddWorldClass("prop_dynamic")
AddWorldClass("func_useableladder")
AddWorldClass("func_rotating")
AddWorldClass("func_rot_button")
AddWorldClass("func_door")
AddWorldClass("func_door_rotating")
AddWorldClass("func_button")
AddWorldClass("func_movelinear")


local function SetupConvars(name)
	if (!ConVarExists(name)) then
		CreateConVar(name,0)
	end
end
SetupConvars("spaceage_autosave")
SetupConvars("spaceage_autosave_time")
SetupConvars("spaceage_autospawner")
SetupConvars("friendlyfire")
CreateConVar( "sa_pirating", "1", { FCVAR_NOTIFY, FCVAR_REPLICATED } )
CreateConVar("sa_faction_only", "0", { FCVAR_NOTIFY } )
local sa_faction_only = GetConVar("sa_faction_only")

local PlayerMeta = FindMetaTable("Player")
function PlayerMeta:AssignFaction(name)
	if name then self.UserGroup = name end
	if not self.UserGroup then self.UserGroup = "freelancer" end
	if self.UserGroup == "alliance" and self.allyuntil < os.time() then self.UserGroup = "freelancer" end
	for k,v in pairs(SA_Factions) do
		if self.UserGroup == v[2] then
			self.TeamIndex = k
		end
	end
	if not self.TeamIndex then
		self.TeamIndex = 1
		self.UserGroup = "freelancer"
	end
	self:SetTeam(self.TeamIndex)
end

local function LeaderRes(data, isok, merror, ply)
	if (isok) then
		for k, v in pairs(data) do
			net.Start("sa_doaddapp")
				net.WriteString(v['steamid'])
				net.WriteString(v['name'])
				net.WriteString(v['text'])
				net.WriteString(v['playtime'])
				net.WriteInt(v['score'])
			net.Send(ply)
		end
	else
		ply:ChatPrint(merror)
	end
end

hook.Add("Initialize","MapCleanInitialize",function()
	local map = game.GetMap()
	if map:lower() == "sb_forlorn_sb3_r2l" then
		timer.Simple(5,function()
			for k, v in pairs(ents.FindByClass("func_breakable")) do
				v:Remove()
			end
		end)
	elseif map:lower() == "gm_galactic_rc1" then
		timer.Simple(5,function()
			for k, v in pairs(ents.FindByClass("prop_physics_multiplayer")) do
				v:Remove()
			end
			ents.FindInSphere(Vector(1046, -7648, -3798.2813), 5)[1]:Fire("kill","",0) //:Remove() // Remove Teleporter Button (Spawns Hula Dolls)
			ents.FindInSphere(Vector(556, -7740, -3798.2813), 5)[1]:Fire("kill","",0) //:Remove() // Remove Jet Engine Button (Spams console with errors after a while)
		end)
	end
end)

local function NonLeaderRes(data, isok, merror, ply)
	if (isok) then
		local appfact = "Major Miners"
		local apptext = "Hi"
		if (data[1]) then
			local ffid = tonumber(data[1]['faction'])
			appfact = SA_Factions[ffid][1]
			apptext = data[1]['text']
		end
		net.Start("sa_dosetappdata")
			net.WriteString(appfact)
			net.WriteString(apptext)
		net.Send(ply)
	end
end

local function LoadFailed(ply)
	ply.Loaded = false
	ply.Credits = 0
	ply.TotalCredits = 0
	ply.IsLeader = false
	ply.TeamIndex = 1
	ply.MaxCap = 0
	ply.miningyield = 0
	ply.miningyield_ii = 0
	ply.miningyield_iii = 0
	ply.miningyield_iv = 0
	ply.miningyield_v = 0
	ply.miningyield_vi = 0
	ply.miningtheory = 0
	ply.miningenergy = 0
	ply.oremod = 0
	ply.fighterenergy = 0
	ply.hdpower = 0
	ply.rta = 0
	ply.gcombat = 0
	ply.oremod_ii = 0
	ply.oremod_iii = 0
	ply.oremod_iv = 0
	ply.oremod_v = 0
	ply.oremanage = 0
	ply.tiberiummod = 0
	ply.tiberiumyield = 0
	ply.tiberiummod_ii = 0
	ply.tiberiumyield_ii = 0
	
	ply.tibdrillmod = 0
	ply.tibstoragemod = 0
	
	ply.icerawmod = 0
	ply.iceproductmod = 0
	ply.icerefinerymod = 0
	ply.icelasermod = 0
	
	ply.devlimit = 1
	ply.allyuntil = 0
	
	SetupStorage(ply)
	ply:ChatPrint("There has been an error, changes to your account will not be saved this session to prevent loss of data. Loading will be retried all 30 seconds")
	ply:AssignFaction()
	timer.Simple(30,function()
		if not ply then return end
		SA_InitSpawn(ply)
		if(ply.Loaded == true) then
			ply:Spawn()
		end
	end)
end

local function LoadRes(data, isok, merror, ply, sid)
	print("Loaded:", ply:Name(), data, isok, merror)
	if (isok and sid != "STEAM_ID_PENDING") then
		if (data[1]) then
			local uid = ply:UniqueID()
			ply.Credits = data[1]["credits"]
			ply.TotalCredits = data[1]["score"]
			ply.UserGroup = data[1]["groupname"]
			ply.IsLeader = (tonumber(data[1]["isleader"]) == 1)
			ply.MaxCap = tonumber(data[1]["capacity"])
			ply.miningyield =  tonumber(data[1]["miningyield"])
			ply.miningenergy =  tonumber(data[1]["miningenergy"])
			ply.oremod = tonumber(data[1]["oremod"])
			ply.fighterenergy = tonumber(data[1]["fighterenergy"])
			ply.miningyield_ii =  tonumber(data[1]["miningyield_ii"])
			ply.miningyield_iii =  tonumber(data[1]["miningyield_iii"])
			ply.miningyield_iv =  tonumber(data[1]["miningyield_iv"])
			ply.miningyield_v =  tonumber(data[1]["miningyield_v"])
			ply.miningyield_vi =  tonumber(data[1]["miningyield_vi"])
			ply.miningtheory =  tonumber(data[1]["miningtheory"])
			ply.rta = tonumber(data[1]["rtadevice"])
			ply.oremod_ii = tonumber(data[1]["oremod_ii"])
			ply.oremod_iii = tonumber(data[1]["oremod_iii"])
			ply.oremod_iv = tonumber(data[1]["oremod_iv"])
			ply.oremod_v = tonumber(data[1]["oremod_v"])
			ply.oremanage = tonumber(data[1]["oremanage"])
			ply.hdpower = tonumber(data[1]["hdpower"])
			ply.gcombat = tonumber(data[1]["gcombat"])
			ply.tiberiumyield =  tonumber(data[1]["tiberiumyield"])
			ply.tiberiummod =  tonumber(data[1]["tiberiummod"])
			ply.tiberiumyield_ii =  tonumber(data[1]["tiberiumyield_ii"])
			ply.tiberiummod_ii =  tonumber(data[1]["tiberiummod_ii"])
			
			ply.tibdrillmod = tonumber(data[1]["tibdrillmod"])
			ply.tibstoragemod = tonumber(data[1]["tibstoragemod"])
			
			ply.icerawmod = tonumber(data[1]["icerawmod"])
			ply.iceproductmod = tonumber(data[1]["iceproductmod"])
			ply.icerefinerymod = tonumber(data[1]["icerefinerymod"])
			ply.icelasermod = tonumber(data[1]["icelasermod"])
			
			ply.devlimit = tonumber(data[1]["devlimit"])
			
			ply.allyuntil = tonumber(data[1]["allyuntil"])
			
			local tbl = {}
			if data[1]["stationres"] then
				if not pcall(function() tbl = glon_decode(data[1]["stationres"]) end) then
					pcall(function()
						tbl = util.KeyValuesToTable(data[1]["stationres"])
						MySQL:Query("UPDATE players SET stationres = '"..MySQL:Escape(glon_encode(tbl)).."' WHERE steamid = '"..sid.."'", function() end)
					end)
				end
			end
			SetupStorage(ply,tbl)
			ply:ChatPrint("Your account has been loaded, welcome on duty.")
			ply.Loaded = true
			ply:AssignFaction()
		else
			local username = MySQL:Escape(ply:Name())
			if not (username == false) then
				MySQL:Query("INSERT INTO players (steamid,name,groupname) VALUES ('"..sid.."','"..username.."','freelancer')", function() end)
				ply:ChatPrint("You have not been found in the database, an account has been created for you.")
				ply.Credits = 0
				ply.TotalCredits = 0
				ply.IsLeader = false
				ply.MaxCap = 0
				ply.Loaded = true
				ply.miningyield = 0
				ply.miningyield_ii = 0
				ply.miningyield_iii = 0
				ply.miningyield_iv = 0
				ply.miningyield_v = 0
				ply.miningyield_vi = 0
				ply.miningtheory = 0
				ply.miningenergy = 0
				ply.oremod = 0
				ply.oremod_iii = 0
				ply.oremod_iv = 0
				ply.oremod_v = 0
				ply.fighterenergy = 0
				ply.rta = 0
				ply.hdpower = 0
				ply.oremod_ii = 0
				ply.oremanage = 0
				ply.gcombat = 0
				ply.tiberiummod = 0
				ply.tiberiumyield = 0
				ply.tiberiummod_ii = 0
				ply.tiberiumyield_ii = 0
				
				ply.tibdrillmod = 0
				ply.tibstoragemod = 0
				
				ply.icerawmod = 0
				ply.iceproductmod = 0
				ply.icerefinerymod = 0
				ply.icelasermod = 0
				
				ply.allyuntil = 0
				
				ply.devlimit = 1
				
				SetupStorage(ply)
				
				ply:AssignFaction()
				
				SA_SaveUser(ply)
			end
		end
	else
		LoadFailed(ply)
	end
	
	if sa_faction_only:GetBool() and
	 ( ply.TeamIndex < SA_MinFaction or
	   ply.TeamIndex > SA_MaxFaction or
	   tonumber(ply.TotalCredits) < 100000000 ) then
			ply:Kick("You don't meet the requirements for this server!")
	end
	
	
	ply.InvitedTo = false
	ply.IsAFK = false
	ply.MayBePoked = false
	
	ply:SetNWBool("isleader",ply.IsLeader)
	
	ply:SetNWInt("Score",ply.TotalCredits)
	/*local mt = ply.miningtheory
	ply:SetNWInt("LaserMK",mt)
	local tmp = 0
	if mt == 0 then
		tmp = ply.miningyield
	elseif mt == 1 then
		tmp = ply.miningyield_ii
	elseif mt == 2 then
		tmp = ply.miningyield_iii
	elseif mt == 3 then
		tmp = ply.miningyield_iv
	elseif mt == 4 then
		tmp = ply.miningyield_v
	elseif mt == 5 then
		tmp = ply.miningyield_vi
	end
	ply:SetNWInt("LaserLV",tmp)
	tmp = 0
	mt = ply.oremanage
	ply:SetNWInt("OreMK",mt)
	if mt == 0 then
		tmp = ply.oremod
	elseif mt == 1 then
		tmp = ply.oremod_ii
	elseif mt == 2 then
		tmp = ply.oremod_iii
	elseif mt == 3 then
		tmp = ply.oremod_iv
	elseif mt == 4 then
		tmp = ply.oremod_v
	end
	ply:SetNWInt("OreLV",tmp)
	
	ply:SetNWInt("TibSLV",ply.tiberiummod)
	ply:SetNWInt("TibDLV",ply.tiberiumyield)
	ply:SetNWInt("IceLLV",ply.icelasermod)
	ply:SetNWInt("IceRLV",ply.icerefinerymod)
	ply:SetNWInt("IceRSLV",ply.icerawmod)
	ply:SetNWInt("IcePSLV",ply.iceproductmod)
	
	mt = nil
	tmp = nil*/

	if ply.devlimit <= 0 then ply.devlimit = 1 end
	
	if not ply.Level then ply.Level = 0 end
	
	timer.Simple(10,function()
		if not (ply and ply.IsValid and ply:IsValid()) then return end
		ply.MayBePoked = true
		SA_Send_AllInfos(ply)
		if ply.IsLeader then
			MySQL:Query("SELECT * FROM applications WHERE faction='"..ply.TeamIndex.."'", LeaderRes, ply)
		else
			local psid = MySQL:Escape(ply:SteamID())
			if ( psid ) then
				local psids = tostring(psid)
				if ( psids ) then
					data, isok, merror = MySQL:Query("SELECT * FROM applications WHERE steamid='"..psids.."'", NonLeaderRes, ply)
				end
			end
		end
	end)
	ply:SetNWBool("isloaded",true)
	if ply.Loaded then
		ply:Spawn()
	end
end

function SA_InitSpawn(ply)
	local sid = ply:SteamID()
	SA_giveRequests[sid] = nil
	print("Loading:", ply:Name())
	local isok = MySQL:Query("SELECT * FROM players WHERE steamid='"..MySQL:Escape(sid).."'", LoadRes, ply, sid)
	if not isok then
		LoadFailed(ply)
	end
end 
hook.Add("PlayerInitialSpawn", "SpaceageLoad", SA_InitSpawn)


function SA_SaveUser(ply,isautosave)
	if (isautosave == "spaceage_autosaver") then
		ply:SetNWInt("spaceage_save_int",GetConVarNumber("spaceage_autosave_time") * 60)
		ply:SetNWInt("spaceage_last_saved",CurTime())
	end
	local sid = ply:SteamID()
	if (ply.Loaded == true) then

		local isleader = 0
		local credits = ply.Credits
		local totalcred = ply.TotalCredits	
		local group = ply.UserGroup
		local cap = ply.MaxCap
		local miningyield = ply.miningyield
		local miningenergy = ply.miningenergy
		--local miningrange = ply.miningbeam
		local oremod = ply.oremod
		local fighterenergy = ply.fighterenergy 
		local perm = MySQL:Escape(glon_encode(GetPermStorage(ply)))
		local name = MySQL:Escape(ply:Name())
		
		if ply.devlimit <= 0 then ply.devlimit = 1 end
		
		if ply.IsLeader then
			isleader = 1
		end
		if username == false then return end
		MySQL:Query("UPDATE players SET credits='"..credits.."', name='"..name.."',score='"..totalcred.."', groupname='"..group.."', isleader='"..isleader.."', capacity='"..cap.."', miningyield='"..miningyield.."', miningenergy='"..miningenergy.."', oremod='"..oremod.."', stationres='"..perm.."', fighterenergy='"..fighterenergy.."', miningyield_ii='"..ply.miningyield_ii.."', miningyield_iii='"..ply.miningyield_iii.."', miningyield_iv='"..ply.miningyield_iv.."', miningyield_v='"..ply.miningyield_v.."', miningyield_vi='"..ply.miningyield_vi.."', miningtheory='"..ply.miningtheory.."', rtadevice='"..ply.rta.."', oremod_ii='"..ply.oremod_ii.."', oremanage='"..ply.oremanage.."', gcombat = '"..ply.gcombat.."', oremod_iii='"..ply.oremod_iii.."', oremod_iv='"..ply.oremod_iv.."', oremod_v='"..ply.oremod_v.."', hdpower = '"..ply.hdpower.."', tiberiummod = '"..ply.tiberiummod.."', tiberiumyield = '"..ply.tiberiumyield.."', icelasermod = '"..ply.icelasermod.."', icerawmod = '"..ply.icerawmod.."', icerefinerymod = '"..ply.icerefinerymod.."', iceproductmod = '"..ply.iceproductmod.."', tibdrillmod = '"..ply.tibdrillmod.."', tibstoragemod = '"..ply.tibstoragemod.."', tiberiumyield_ii = '"..ply.tiberiumyield_ii.."', tiberiummod_ii = '"..ply.tiberiummod_ii.."', devlimit = '"..ply.devlimit.."', allyuntil = '"..ply.allyuntil.."' WHERE steamid='"..sid.."'", SaveDone)
	else
		return false
	end
end
hook.Add("PlayerDisconnected", "SA_Save_Disconnect", SA_SaveUser)

local function SaveDone() return end

local function SA_SaveAllUsers()
	if (GetConVarNumber("spaceage_autosave") == 1) then
		timer.Adjust("SA_Autosave", GetConVarNumber("spaceage_autosave_time") * 60, 0, SA_SaveAllUsers)
		MySQL:Query('UPDATE factions AS f SET f.score = (SELECT Round(Avg(p.score)) FROM players AS p WHERE p.groupname = f.name) WHERE f.name != "noload"', SaveDone)
		for k,v in ipairs(player.GetHumans()) do
			timer.Simple(k, SA_SaveUser, v, "spaceage_autosaver")
		end
		SA_SaveAllPlanets()
	end
end
timer.Create("SA_Autosave", 60, 0, SA_SaveAllUsers)
concommand.Add("SavePlayers",function(ply) if ply:IsAdmin() then SA_SaveAllUsers() end end)

local function SA_Autospawner(ply)
	if (GetConVarNumber("spaceage_autospawner") == 1) then
		for k,v in ipairs(ents.GetAll()) do
			if v.RealAutospawned == true then
				if v.SASound then v.SASound:Stop() end
				v:Remove()
			end
		end
		local mapname = game.GetMap()
		local filename = "Spaceage/Autospawn/"..mapname..".txt"
		if file.Exists(filename, "DATA") then
			for k,v in pairs(util.KeyValuesToTable(file.Read(filename))) do
				local spawn = ents.Create("prop_physics")
				spawn:SetModel(v["model"])
				spawn:SetPos(Vector(v["x"],v["y"],v["z"]))
				spawn:SetAngles(Angle(v["pit"],v["yaw"],v["rol"]))
				SAPPShim.MakeOwner(spawn)
				spawn:Spawn()
				local phys = spawn:GetPhysicsObject()
				if phys then
					phys:EnableMotion(false)
				end
				spawn.CDSIgnore = true
				spawn.Autospawned = true
				spawn.RealAutospawned = true
			end
		end
		
		local filename = "Spaceage/Autospawn2/"..mapname..".txt"
		if file.Exists(filename, "DATA") then
			for k,v in pairs(util.KeyValuesToTable( file.Read(filename))) do
				local spawn = ents.Create(v["class"])
				spawn:SetPos(Vector(v["x"],v["y"],v["z"]))
				spawn:SetAngles(Angle(v["pit"],v["yaw"],v["rol"]))
				if v["model"] then
					spawn:SetModel(v["model"])
				end
				SAPPShim.MakeOwner(spawn)
				spawn:Spawn()
				local phys = spawn:GetPhysicsObject()
				if phys and phys:IsValid() then
					phys:EnableMotion(false)
				end
				spawn.CDSIgnore = true
				spawn.Autospawned = true
				spawn.RealAutospawned = true
				if v["sound"] then
					local mySND = CreateSound(spawn, Sound(v["sound"]))
					if mySND then
						spawn.SASound = mySND
						spawn.SASound:Play()
					end
				end
			end
		end			
	end
	if(ply and ply:IsPlayer()) then
		SystemSendMSG(ply,"respawned all SpaceAge stuff")
	end
end
timer.Simple(1, SA_Autospawner)
concommand.Add("NewAutospawn",function(ply) if ply.Level >= 3 then SA_Autospawner(ply) end end)

function SA_IsProtectedProp(ent)
	for k,v in pairs(WorldClasses) do
		if (ent:GetClass() == v) then
			return true
		end
	end
	if ent.Autospawned then return true end
	return false
end

local SA_Don_Toollist = util.KeyValuesToTable(file.Read("Spaceage/Donator/toollist.txt"))

local function SA_DonatorCanTool(ply,tr,mode)
	for k,v in pairs(SA_Don_Toollist) do
		if mode == v then
			if !ply.donator then
				ply:AddHint("This is a donator-only tool, a reward for contributing to the community.", NOTIFY_CLEANUP, 10)
				return false
			end
		end
	end
end
hook.Add("CanTool","DonatorCanTool", SA_DonatorCanTool)
