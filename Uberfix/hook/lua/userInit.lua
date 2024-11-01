--Mithy: Support for mod UI textures
--Precaches relative paths for all .dds files in __active_mods locations
--These are used by a UIFile hook to display mod-specific and mod-overridden UI textures

--In the case of a two mods using the same relative texture path, or a mod using the
--same relative path as a base game file, the last in load order takes precedence
--(as with a shadowed or hooked script file)
ModTextureCache = {}

LOG("UberFix: Precaching mod texture paths...")
for uid, m in __active_mods do
	local modtextures = DiskFindFiles(m.location, '*.dds')
	if not table.empty(modtextures) then
		LOG("    Mod Name = "..m.name.."\n    Location = "..m.location)
	end
	for k, file in modtextures do
		local filepath = file:gsub(m.location, '')
		LOG("\t"..filepath)
		ModTextureCache[filepath] = file
	end
end