AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

function ENT:GetPlayerLevel(ply)
	return ply.miningyield_iii
end
