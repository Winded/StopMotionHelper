
SMH.OnionSkinEnts = {};

function SMH.EnableOnionSkin()

	SMH.DisableOnionSkin();

	local data = SMH.Data.OnionSkinData;
	if not data or table.Count(data) == 0 then
		return;
	end

	for _, eData in pairs(data) do
		
		local entity = ClientsideModel(eData.Model);

		-- TODO

	end

end

function SMH.DisableOnionSkin()
	for _, ent in pairs(SMH.OnionSkinEnts) do
		ent:Remove();
	end
	table.Empty(SMH.OnionSkinEnts);
end