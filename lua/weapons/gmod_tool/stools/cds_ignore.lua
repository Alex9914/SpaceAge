TOOL.Tab = "Utilities"
TOOL.Category = "Admin"
TOOL.Name = "CDS Prop Toggler"
TOOL.Command = nil
TOOL.ConfigName = ""

if (CLIENT) then
	language.Add("tool.cds_ignore.name", "CDS Prop Toggler")
	language.Add("tool.cds_ignore.desc", "Change CDSIgnore on props")
	language.Add("tool.cds_ignore.0", "Left Click: Enable CDS Damage. Right Click: Disable CDS Damage.")
end
function TOOL:LeftClick(tr)
	if CLIENT then return end
	local owner = self:GetOwner()
	if not owner:IsAdmin() then owner:ChatPrint("You are not authorized to use this.") return false end
	if tr.Entity then
		local ent = tr.Entity
		if ent:IsValid() and not ent.Autospawned then
			ent.CDSIgnore = true
			owner:ChatPrint("CDS Damage Enabled")
		end
	end
end

function TOOL:RightClick(tr)
	if CLIENT then return end
	local owner = self:GetOwner()
	if not owner:IsAdmin() then owner:ChatPrint("You are not authorized to use this.") return false end
	if tr.Entity then
		local ent = tr.Entity
		if ent:IsValid() and not ent.Autospawned  then
			ent.CDSIgnore = false
			owner:ChatPrint("CDS Damage Disabled")
		end
	end
end
