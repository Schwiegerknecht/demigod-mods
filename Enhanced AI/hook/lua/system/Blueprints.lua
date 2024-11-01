#
# Blueprint loading
#
#   During preloading of the map, we run loadBlueprints() from this file. It scans
#   the game directories and runs all .bp files it finds.
#
#   The .bp files call UnitBlueprint(), PropBlueprint(), etc. to define a blueprint.
#   All those functions do is fill in a couple of default fields and store off the
#   table in 'original_blueprints'.
#
#   Once that scan is complete, ModBlueprints() is called. It can arbitrarily mess
#   with the data in original_blueprints.
#
#   Finally, the engine registers all blueprints in original_blueprints to define the
#   "real" blueprints used by the game. A separate copy of these blueprints is made
#   available to the sim-side and user-side scripts.
#
# How mods can affect blueprints
#
#   First, a mod can simply add a new blueprint file that defines a new blueprint.
#
#   Second, a mod can contain a blueprint with the same ID as an existing blueprint.
#   In this case it will completely override the original blueprint. Note that in
#   order to replace an original non-unit blueprint, the mod must set the "BlueprintId"
#   field to name the blueprint to be replaced. Otherwise the BlueprintId is defaulted
#   off the source file name. (Units don't have this problem because the BlueprintId is
#   shortened and doesn't include the original path).
#
#   Third, a mod can can contain a blueprint with the same ID as an existing blueprint,
#   and with the special field "Merge = true". This causes the mod to be merged with,
#   rather than replace, the original blueprint.
#
#   Finally, a mod can hook the ModBlueprints() function which manipulates the
#   blueprints table in arbitrary ways.
#      1. create a file /mod/s.../hook/system/Blueprints.lua
#      2. override ModBlueprints(all_bps) in that file to manipulate the blueprints
#
# Reloading of changed blueprints
#
#   When the disk watcher notices that a .bp file has changed, it calls
#   ReloadBlueprint() on it. ReloadBlueprint() repeats the above steps, but with
#   original_blueprints containing just the one blueprint.
#
#   Changing an existing blueprint is not 100% reliable; some changes will be picked
#   up by existing units, some not until a new unit of that type is created, and some
#   not at all. Also, if you remove a field from a blueprint and then reload, it will
#   default to its old value, not to 0 or its normal default.
#


local TOLCat = 'ROOKTOWER'

local MBP = ModBlueprints
 local rookTowers = {
    'hrooktoweroflight',
     'hrooktoweroflight02',
     'hrooktoweroflight03',
     'hrooktoweroflight04',
 }
 function ModBlueprints(all_bps)
     MBP(all_bps)
     for k, towerName in rookTowers do
	local bp = all_bps.Unit[towerName]
          if bp and bp.Categories then
             if not table.find(bp.Categories, TOLCat) then
                  table.insert(bp.Categories, TOLCat)
             end
          else
             WARN("ModBlueprints: Can't find unit: hrooktoweroflight"..i)
         end
     end
end
 
--[[
local sub = string.sub
local gsub = string.gsub
local lower = string.lower
local getinfo = debug.getinfo
local here = getinfo(1).source

local original_blueprints

local function InitOriginalBlueprints()
    original_blueprints = {
        Mesh = {},
        Unit = {},
        Prop = {},
        Projectile = {},
        TrailEmitter = {},
        Emitter = {},
        Beam = {},
    }
end

local skipSource = nil

function SetSourceInfoStart(n,skip)
    sourceInfoStart = n
    skipSource = skip
end

function GetSource()
    # Find the first calling function not in this source file
    local n = sourceInfoStart
    local there
    while true do
        there = getinfo(n).source
        if there!=here and (not skipSource or skipSource != there) then
            break
        end
        n = n+1
    end
    if sub(there,1,1)=="@" then
        there = sub(there,2)
    end
    return DiskToLocal(there)
end

local function StoreBlueprint(group, bp)
    local id = bp.BlueprintId
    local t = original_blueprints[group]

    if t[id] and bp.Merge then
        bp.Merge = nil
        bp.Source = nil
        t[id] = table.merged(t[id], bp)
    else
        t[id] = bp
    end
end

#
# Figure out what to name this blueprint based on the name of the file it came from.
# Returns the entire filename. Either this or SetLongId() should really be got rid of.
#
function SetBackwardsCompatId(bp)
    bp.Source = bp.Source or GetSource()
    bp.BlueprintId = lower(bp.Source)
end

#
# Figure out what to name this blueprint based on the name of the file it came from.
# Returns the full resource name except with ".bp" stripped off
#
function SetLongId(bp)
    bp.Source = bp.Source or GetSource()
    if not bp.BlueprintId then
        local id = lower(bp.Source)
        id = gsub(id, "%.bp$", "")                          # strip trailing .bp
        #id = gsub(id, "/([^/]+)/%1_([a-z]+)$", "/%1_%2")    # strip redundant directory name
        bp.BlueprintId = id
    end
end

#
# Figure out what to name this blueprint based on the name of the file it came from.
# Returns just the base filename, without any blueprint type info or extension. Used
# for units only.
#
function SetShortId(bp)
    bp.Source = bp.Source or GetSource()
    bp.BlueprintId = bp.BlueprintId or
        gsub(lower(bp.Source), "^.*/([^/]+)_[a-z]+%.bp$", "%1")
end

#
# Figure out what the name would be if just given a file name
#
function InferName(bp, extension)
    local name = gsub(bp.Source, "_[a-z]+%.bp$", extension)
    return name
end

#
# If the bp contains a 'Mesh' section, move that over to a separate Mesh blueprint, and
# point bp.MeshBlueprint at it.
#
# Also fill in a default value for bp.MeshBlueprint if one was not given at all.
#
function ExtractMeshBlueprint(bp)
    local disp = bp.Display or {}
    bp.Display = disp

    if disp.MeshBlueprint=='' then
        LOG('Warning: ',bp.Source,': MeshBlueprint should not be an empty string')
        disp.MeshBlueprint = nil
    end

    if type(disp.MeshBlueprint)=='string' then
        if disp.MeshBlueprint!=lower(disp.MeshBlueprint) then
            #Should we allow mixed-case blueprint names?
            #LOG('Warning: ',bp.Source,' (MeshBlueprint): ','Blueprint IDs must be all lowercase')
            disp.MeshBlueprint = lower(disp.MeshBlueprint)
        end

        # strip trailing .bp
        disp.MeshBlueprint = gsub(disp.MeshBlueprint, "%.bp$", "")

        if disp.Mesh then
            LOG('Warning: ',bp.Source,' has mesh defined both inline and by reference')
        end
    end

    if disp.MeshBlueprint==nil then
        # For a blueprint file "/units/uel0001/uel0001_unit.bp", the default
        # mesh blueprint is "/units/uel0001/uel0001_mesh"
        local meshname,subcount = gsub(bp.Source, "_[a-z]+%.bp$", "_mesh")
        if subcount==1 then
            disp.MeshBlueprint = meshname
        end

        if type(disp.Mesh)=='table' then
            local meshbp = disp.Mesh
            meshbp.Source = meshbp.Source or bp.Source
            meshbp.BlueprintId = disp.MeshBlueprint
            # roates:  Commented out so the info would stay in the unit BP and I could use it to precache by unit.
            # disp.Mesh = nil
            if meshbp.LODs then
                for i,lod in meshbp.LODs do
                    if not lod.AlbedoName then
                        lod.AlbedoName = InferName(bp, "_albedo.dds")
                    end
                    if not lod.SpecularName then
                        lod.SpecularName = InferName(bp, "_specteam.dds")
                    end
                    if not lod.NormalsName then
                        lod.NormalsName = InferName(bp, "_normalsts.dds")
                    end
                end
            end

            MeshBlueprint(meshbp)
        end
    end
end

function ExtractEvilMeshBlueprint(bp)
    if bp.Display.MeshBlueprintEvil then
        return
    end

    local meshid = bp.Display.MeshBlueprint
    if not meshid then return end

    local meshbp = original_blueprints.Mesh[meshid]
    if not meshbp then return end

    local evilbp = table.deepcopy(meshbp)
    if evilbp.LODs then
        for i,lod in evilbp.LODs do
            if not lod.AlbedoNameEvil then
                lod.AlbedoName = InferName(bp, "_evil_albedo.dds")
            else
                lod.AlbedoName = lod.AlbedoNameEvil
            end
            if not lod.SpecularNameEvil then
                lod.SpecularName = InferName(bp, "_evil_specteam.dds")
            else
                lod.SpecularName = lod.SpecularNameEvil
            end
        end
    end
    evilbp.BlueprintId = meshid .. '_evil'
    bp.Display.MeshBlueprintEvil = evilbp.BlueprintId
    MeshBlueprint(evilbp)
end

function ExtractFrozenBlueprint(bp)
    local frozenbp = table.deepcopy(bp)
    if frozenbp.LODs then
        for i,lod in frozenbp.LODs do
            lod.ShaderName = 'Frozen'
        end
    end
    frozenbp.UniformScale = 1.2 or (bp.UniformScale * 1.2);
    frozenbp.BlueprintId = bp.BlueprintId .. '_frozen'
    return frozenbp
end

function ExtractStunBlueprint(bp)
    local stunbp = table.deepcopy(bp)
    if stunbp.LODs then
        for i,lod in stunbp.LODs do
            lod.ShaderName = 'Stunned'
        end
    end
    stunbp.BlueprintId = bp.BlueprintId .. '_stunned'
    return stunbp
end

function ExtractInvulnerableBlueprint(bp)
    local invulnerableBp = table.deepcopy(bp)
    if invulnerableBp.LODs then
        for i,lod in invulnerableBp.LODs do
            lod.ShaderName = 'Invulnerable'
        end
    end
    invulnerableBp.BlueprintId = bp.BlueprintId .. '_invulnerable'
    return invulnerableBp
end

function MeshBlueprint(bp)
    # fill in default values
    SetLongId(bp)
    StoreBlueprint('Mesh', bp)
end

function UnitBlueprint(bp)
    SetShortId(bp)
    StoreBlueprint('Unit', bp)
end

function PropBlueprint(bp)
    SetBackwardsCompatId(bp)
    StoreBlueprint('Prop', bp)
end

function ProjectileBlueprint(bp)
    SetBackwardsCompatId(bp)
    StoreBlueprint('Projectile', bp)
end

function TrailEmitterBlueprint(bp)
    SetBackwardsCompatId(bp)
    StoreBlueprint('TrailEmitter', bp)
end

function EmitterBlueprint(bp)
    SetBackwardsCompatId(bp)
    StoreBlueprint('Emitter', bp)
end

function BeamBlueprint(bp)
    SetBackwardsCompatId(bp)
    StoreBlueprint('Beam', bp)
end

function ExtractAllMeshBlueprints()

    for id,bp in original_blueprints.Unit do
        ExtractMeshBlueprint(bp)
        ExtractEvilMeshBlueprint(bp)
    end

    local autoMeshBPs = {}

    # auto-generate frozen and stunned mesh bp's
    for id,bp in original_blueprints.Mesh do
        table.insert( autoMeshBPs, ExtractFrozenBlueprint(bp) )
        table.insert( autoMeshBPs, ExtractStunBlueprint(bp) )
        table.insert( autoMeshBPs, ExtractInvulnerableBlueprint(bp) )
    end

    for id,bp in autoMeshBPs do
        MeshBlueprint(bp)
    end

    for id,bp in original_blueprints.Prop do
        ExtractMeshBlueprint(bp)
    end

    for id,bp in original_blueprints.Projectile do
        ExtractMeshBlueprint(bp)
    end
end

function RegisterAllBlueprints(blueprints)

    local function RegisterGroup(g, fun)
        for id,bp in sortedpairs(g) do
            fun(g[id])
        end
    end

    RegisterGroup(blueprints.Mesh, RegisterMeshBlueprint)
    RegisterGroup(blueprints.Unit, RegisterUnitBlueprint)
    RegisterGroup(blueprints.Prop, RegisterPropBlueprint)
    RegisterGroup(blueprints.Projectile, RegisterProjectileBlueprint)
    RegisterGroup(blueprints.TrailEmitter, RegisterTrailEmitterBlueprint)
    RegisterGroup(blueprints.Emitter, RegisterEmitterBlueprint)
    RegisterGroup(blueprints.Beam, RegisterBeamBlueprint)
end

# Hook for mods to manipulate the entire blueprint table
function ModBlueprints(all_blueprints)
end

# Load all blueprints
function LoadBlueprints()
    LOG('Loading blueprints...')
    SetSourceInfoStart(2,nil)
    InitOriginalBlueprints()

    for k,file in DiskFindFiles('/', '*.bp') do
		local dir = string.sub(file,1,5)
		if dir != '/mods' then
			safecall("loading blueprint "..file, doscript, file)
		end			
    end

    for i,m in __active_mods do
        for k,file in DiskFindFiles(m.location, '*.bp') do
            LOG("applying blueprint mod "..file)
            safecall("loading mod blueprint "..file, doscript, file)
        end
    end

    ExtractAllMeshBlueprints()

    ModBlueprints(original_blueprints)

    LOG('Registering blueprints...')
    RegisterAllBlueprints(original_blueprints)
    original_blueprints = nil
end

# Reload a single blueprint
function ReloadBlueprint(file)
    InitOriginalBlueprints()

    safecall("reloading blueprint "..file, doscript, file)

    ExtractAllMeshBlueprints()
    ModBlueprints(original_blueprints)
    RegisterAllBlueprints(original_blueprints)
    original_blueprints = nil
end

function PreloadResources()
    LOG('Preloading resources.')
    local PreloadUnitResources = import('/lua/common/Preload.lua').PreloadUnitResources
    for index,id in EntityCategoryGetUnitList(ParseEntityCategory('PRELOADRESOURCES')) do
        PreloadUnitResources(id)
    end
    LOG('Preloading done.')
end
]]--