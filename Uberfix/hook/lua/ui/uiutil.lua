--[[ Mithy: UIFile hook for mod UI texture support
Allows textures included in mod folders to be referenced using standard paths,
and allows them to override base game textures (or each other) in mod load order.

It works for any 'skinnable' in-game UI texture inside /textures/ui/common, which
includes most of the normal UI textures, buttons, ability and buff icons, etc.
Exceptions include area target decals, HUD and window frames, and cursors.
Some of these can be specified in the skin.lua skin definition itself, but not all.
Search the lua for '/textures/ui/common/' to see all exceptions.

None of the textures outside of this path can be substituted with this method,
since they are not considered 'skinnable' and do not get their paths via UIFile.
Each non-skinnable file has its path specified explicitly in a local value within
the function that sets up that particular HUD or UI element, and cannot be
replaced non-destructively. Replacing all of these would require 50+ file hooks
and hundreds of function overrides.

NOTE: This does not work in the lobby, frontend, or any other state prior to game load,
for the obvious reason that mods (including this one) have not yet loaded.


For example, including a texture in your mod folder with the path:
	/mods/mymod/textures/ui/common/mymod_texture.dds
..will be found by any UIFile call of '/mymod_texture.dds'.

Overrides of existing game UI textures are done the same way:
	/mods/mymod/textures/ui/common/buttons/close_btn_small_up.dds
..will replace the normal window close button in-game (but not in the frontend).

With buff and ability icons, including a texture with the path:
	/mods/mymod/textures/ui/common/abilities/icons/mymod_icon.dds
..allows you to reference it in your Buff or Ability blueprint via:
	Icon = 'mymod_icon'

--]]

--Converts the provided path to a mod texture path, if available
function GetModTexture(file)
    return ModTextureCache[file:lower()] or file
end

--Allows the original UIFile custom skin logic to find mod texture files
local prevDGFI = DiskGetFileInfo
function DiskGetFileInfo(path)
	return prevDGFI(GetModTexture(path))
end

local prevUIFile = UIFile
function UIFile(filespec)
	return GetModTexture(prevUIFile(filespec))
end