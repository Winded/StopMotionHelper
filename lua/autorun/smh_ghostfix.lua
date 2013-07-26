
if SERVER then

concommand.Add("smh_ghostfix",function(pl,cmd,args)
	local tr = pl:GetEyeTrace()
	if !IsValid(tr.Entity) then return end
	if !IsValid(tr.Entity.smhGhost) then return end
	tr.Entity.smhGhost:Remove()
	tr.Entity.smhGhost = nil
end)

end