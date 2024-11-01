--Mithy: Using a modification of  BulletMagnet's doscript hook now instead of a UID-based solution that requires
--me to update the UID in two or three places every time I do a release, inevitably causing a re-release when
--I forget to do so and break the mod.  This is needed to batch the Ball Lightning fix, among other things.

--  doscript fix for mod support.
--
--      Lovingly made by BulletMagnet, in the space of an hour, one Summer afternoon.
--
--      TL; DR (the code).
--          The script should have some smarts about it, and only hokey about with the
--              doscript function once - no matter how many times, this code appears
--              in loaded mods.
--
--          When doscript is called, it first tries to run in the conventional manner.
--          If that fails, for whatever reason (primarily because files are 404),
--              it searches the folders listed in the __active_mods table for files
--              with matching a directory+name.
--          Each potential file is checked, and the first to successfully complete will
--              cause the script to return.
--          If the script still can't process any files successfully, it will then
--              error-out and return the error from the initial doscript call.
--
--      This script assumes that the first file found is the desired one, and won't bother
--          trying subsequent mods. If this were to change, or be added, then mod-order
--          would have to be checked too.
--
--      Hooking files that another mod introduces isn't recommended.
--          ...It probably doesn't work.
--
--      Script is such a weird looking word, like sombrero.


local m_ok, m_msg = pcall(function() return modscript end)
if not m_ok then
	modscript = true

	local olddoscript = doscript
	doscript = function(script, env)
		local ok, msg = pcall(olddoscript, script, env)

		if not ok then
			if not DiskGetFileInfo(script) then
				SPEW('doscript: Searching active mods for relative path: '.. repr(script))

				for index, info in __active_mods or {} do
					local script_mod = info.location .. script
					if DiskGetFileInfo(script_mod) then
						SPEW('\tTrying doscript on file ' .. script_mod)

						local ok, msg = pcall(olddoscript, script_mod, env)

						if ok then
							SPEW('\tFile successfully introduced from mod path ' .. info.location)
							return
						else
							continue
						end
					end
				end

				error("File '" .. script .. "' not found in any active mods.",2)
			else
				error(msg, 2)
			end
		end
	end
end