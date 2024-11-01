do
	local oldCreateGameControls = CreateGameControls

	CreateGameControls = function(isReplay)
		oldCreateGameControls(isReplay)

		if (not isReplay) then
			partyPanel = import('/Mods/Enhanced UI/partyPanel.lua').Create(gameParent.worldView)
			LayoutHelpers.CenteredAbove(partyPanel, HUDParent, -40)
			LayoutHelpers.DepthOverParent(partyPanel, HUDParent, 2)
			# Move the buffs panel above the party panel
			LayoutHelpers.CenteredAbove(buffs, partyPanel, -5)
		end
	end
end
