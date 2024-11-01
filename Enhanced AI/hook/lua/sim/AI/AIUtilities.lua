#  [MOD] Ability to pass in distance check on finding weakest hero to target.  Attack Actions calls the function here.

# -- local ValidateAbility = import('/lua/common/ValidateAbility.lua')
# -- local ValidateInventory = import('/lua/common/ValidateInventory.lua')
# -- local ValidateShop = import('/lua/common/ValidateShop.lua')
# -- local CanPickItem = import('/lua/common/ValidateShop.lua').CanPickItem
# -- local Buff = import('/lua/sim/Buff.lua')

# -- local Utils = import('/lua/sim/ScenarioUtilities.lua')

function GetNearbyWeakHero( unit, radius )
    radius = radius or 20

    local heroCat = categories.HERO
    local heroBlips = unit:GetAIBrain():GetBlipsAroundPoint( heroCat, unit:GetPosition(), radius, 'Enemy' )
    if table.empty(heroBlips) then
        return nil
    end
    return GetWeakestUnit( heroBlips )
end

function convertIDtoName( unitid)
local myString = 'NIL'
	if unitid == 'hdemon' then
		myString = 'DA'
	elseif unitid == 'hema01' then
		myString = 'TB'
	elseif unitid == 'hepa01' then
		myString = 'UB'
	elseif unitid == 'hgsa01' then
		myString = 'REG'
	elseif unitid == 'hoak' then
		myString = 'OAK'
	elseif unitid == 'hoculus' then
		myString = 'OC'
	elseif unitid == 'hqueen' then
		myString = 'QoT'
	elseif unitid == 'hrook' then
		myString = 'ROOK'
	elseif unitid == 'hsedna' then
		myString = 'SED'
	elseif unitid == 'hvampire' then
		myString = 'LE'	
	end
	
return myString
	
end

function GetWeakestUnit( units, ignoreBuffs )
    local sorted = SortEntitiesByHealth(units)

    if ignoreBuffs then
        for k,unit in sorted do
            local ok = true
            for i,buffName in ignoreBuffs do
                if Buff.HasBuff(unit,buffName) then
                    ok = false
                    break
                end
            end

            if ok then
                return unit
            end
        end
    else
        return sorted[1]
    end
end

function FindBackRowPosition(unit, aiBrain)
    local backCategory = categories.DEFENSE + ( categories.HEALER + categories.ARCHER + categories.ARTILLERY ) * categories.GRUNT
    local backrow = aiBrain:GetUnitsAroundPoint( backCategory, unit.Position, 20, 'Ally' )
    if table.empty(backrow) then
        backCategory = categories.ALLUNITS
        backrow = aiBrain:GetUnitsAroundPoint( backCategory, unit.Position, 20, 'Ally' )
        if table.empty(backrow) then
            return false
        end
    end

    local enemyCategory = categories.MOBILE * categories.LAND

    # There are enemies within 20 o-grids, but no enemies are really close to the hero; we don't really need to move
    local enemyUnits = aiBrain:GetBlipsAroundPoint( enemyCategory, unit.Position, 5, 'Enemy' )
    if table.empty(enemyUnits) then
        return unit.Position
    end

    local lowestCount = 0
    local lowestInRange = false
    local bestPosition = false
    for k,v in backrow do
        local enemyUnits = aiBrain:GetBlipsAroundPoint( enemyCategory, v.Position, 15, 'Enemy' )
        # We want to fight where enemies are in range; if we already have a unit with enemies in range ignore those that don't
        # have enemies in range
        if lowestInRange and table.empty( enemyUnits ) then
            continue
        end

        local tempRange = table.getn(enemyUnits)
        enemyUnits = FilterEntitiesFurtherThan(unit.Position,enemyUnits,5)
        local tempCount = table.getn(enemyUnits)

        if tempCount == 0 and tempRange > 0 then
            bestPosition = table.copy( v.Position )
            break
        elseif (not lowestCount or tempCount < lowestCount ) and (not lowestInRange or tempRange > 0) then
            lowestCount = tempCount
            bestPosition = table.copy( v.Position )
            if tempRange > 0 then
                lowestInRange = true
            end
        end
    end

    return bestPosition
end

function FindSafePosition(unit, aiBrain, filterDistance)
    local unitsCategory = categories.DEFENSE + categories.HEALER + categories.HERO
    filterDistance = filterDistance or 10
    local filterSq = filterDistance * filterDistance

    local units = aiBrain:GetUnitsAroundPoint( unitsCategory, unit.Position, 40, 'Ally' )
    if not table.empty(units) then
        units = FilterEntitiesCloserThan(unit.Position,units,10)

        for k,v in units do
            if v:IsDead() then
                continue
            end

            if VDist3XZSq( unit.Position, v.Position ) < filterSq then
                continue
            end

            if aiBrain:GetThreatAtPosition( v.Position, 0, 'Structures', 'Enemy' ) <= 0 and
                    aiBrain:GetThreatAtPosition( v.Position, 0, 'Hero', 'Enemy' ) <= 0 then
                return table.copy( v.Position )
            end
        end
    end

    local query = CreateThreatQuery(aiBrain:GetArmyIndex())
    query:GetThreatsAroundPoint(unit.Position, 3)
    query:FilterDistanceLessThan(18)
    query:FilterThreatGreatherThan(0)
    # query:SortClosestToFurthest()
    query:SortThreatLowToHigh()

    local threats = query:GetResults()
    if table.empty(threats) then
        return false
    end

    for k,v in threats do
        local height = GetTerrainHeight( v[1], v[2] )
        if height > 99 then
            return { v[1], 100, v[2] }
        end
    end

    return false
end

function EnemyTowerRange(unit, aiBrain)
    local numTowers =  aiBrain:GetNumUnitsAroundPoint( categories.FORT, unit.Position, 20, 'Enemy' )
    local numTowers = numTowers + aiBrain:GetNumUnitsAroundPoint( categories.ugbdefense01 + categories.ugbdefense02, unit.Position, 15, 'Enemy' )

    return numTowers
end

function FilterRunningAwayUnits(unit, targets, cutoffMult)
    local finalTargets
	# [MOD] Ability to Pass in cutoffmult and use it
	if (not cutoffMult) then
	cutoffMult = 0
	end
	
    # Remove any units that are further away than the unit's weapon range
    # This leaves us with a table of units closer than the weapon range; this is the minimum set
    local inRangeTargets = FilterEntitiesFurtherThan(unit.Position,targets,unit.PrimaryWeaponRadius)
    if not table.empty(inRangeTargets) then
        return GetWeakestUnit( inRangeTargets )
        # finalTargets = inRangeTargets
    else
        finalTarget = {}
    end

    # Get a table of units that is outside of weapon range
    local outRangeTargets = FilterEntitiesCloserThan(unit.Position,targets,unit.PrimaryWeaponRadius + cutoffMult)
    if not table.empty(outRangeTargets) then

        # Of the units that are currently out of range; filter any that are moving away
        # This gives us a table of units that are not moving away from us
        local notRunningTargets = FilterEntitiesMovingAway(unit,outRangeTargets)
        if not table.empty(notRunningTargets) then
            finalTargets = table.append( finalTargets, notRunningTargets )
        end
    end

    if table.empty(finalTargets) then
        return nil
    end

    return GetWeakestUnit( finalTargets )
end

function GetUnitsBetweenTargets(aiBrain, targetOne, targetTwo, unitCategory)
    local posOne = targetOne.Position
    local posTwo = targetTwo.Position

    local radius = VDist3XZ( posOne, posTwo ) / 2

    local midX = ( posOne[1] + posTwo[1] ) / 2
    local midZ = ( posOne[3] + posTwo[3] ) / 2

    local point = { midX, 100, midZ }

    return aiBrain:GetBlipsAroundPoint( unitCategory, point, radius, 'Enemy' )
end

function GetHighestValuePotion( unitPos, rectSize, valueType )
    local potion = false
    local addVal = false
    local multVal = false

    local potions = GetArmyBrain('FRIENDLY_CIVILIAN'):GetListOfUnits(categories.POTION, false)
    if(not table.empty(potions)) then
        local sorted = SortEntitiesByDistanceXZ(unitPos, potions)

        for k,v in sorted do
            if v:IsDead() then
                continue
            end

            if VDist3XZSq(unitPos, v.Position) > 400 then
                break
            end

            if not v.Blueprint.PowerUp then
                continue
            end

            if not v.Blueprint.Buffs then
                continue
            end

            for _,buff in v.Blueprint.Buffs do
                if not Buffs[buff].Affects[valueType] then
                    continue
                end

                if potion and addVal and Buffs[buff].Affects[valueType].Add < addVal then
                    continue
                end

                if potion and multVal and Buffs[buff].Affects[valueType].Mult < multVal then
                    continue
                end

                potion = v
                addVal = Buffs[buff].Affects[valueType].Add
                multVal = Buffs[buff].Affects[valueType].Mult
            end
        end
    end

    local retVal = multVal
    if not retVal then
        retVal = addVal
    end

    return potion, retVal
end

function UnitCheckBuffs( unit, buffs )
    for k,v in buffs do
        if Buff.HasBuff(unit, v) then
            return true
        end
    end

    return false
end

function PointCompare( p1, p2 )
    if p1[1] == p2[1] and p1[3] == p2[3] then
        return true
    end
    return false
end

# This function returns the grid loctions for an influence map along a chain
function GetInfluenceGridAlongChain( brain, points )
    local gridPoints = {}

    local lastPoint
    for k,v in points do
        if k == 1 then
            lastPoint = v
            continue
        end

        local threats = brain:GetThreatsAlongLine( lastPoint, v )

        for _,data in threats do
            local point = { data[1], 0, data[2] }
            if not table.find( gridPoints, point, PointCompare ) then
                table.insert( gridPoints, point )
            end
        end

        lastPoint = v
    end

    return gridPoints
end

function GetMarkersAroundPoint( point, markerType, radius )
    local markers = Utils.GetMarkers()
    local filteredMarkers = {}
    for k,v in markers do
        if v.type != markerType then
            continue
        end

        if VDist3XZSq( point, v.position ) > radius * radius then
            continue
        end

        v.MarkerName = k
        table.insert( filteredMarkers, v )
    end

    return filteredMarkers
end

function DrawPath(path, armyName, initialPosition)
    local upVec = Vector(0,1,0)

    local lastPosition = initialPosition
    local armyColor = import('/lua/GameColors.lua').GameColors.PlayerColors[Scenario.Armies[armyName].color]
    for k,v in path do
        DrawCircle( v, upVec, 5, armyColor, 20 )
        DrawCircle( v, upVec, 5.5, armyColor, 20 )

        if lastPosition then
            DrawLinePop( lastPosition, v, armyColor )
        end

        lastPosition = v
    end
end

function GetPathDistanceBetweenPoints( aiBrain, point1, point2 )
    local unitPathNode = aiBrain:FindClosestPathNode( 'DefaultLand', point1 )
    local targetPathNode = aiBrain:FindClosestPathNode( 'DefaultLand', point2 )
    # Hey we have path nodes; gimme a route
    local distance = 0.0
    local path = false
    if unitPathNode and targetPathNode and not unitPathNode != targetPathNode then
        # Get Safe path to location
        local route = aiBrain:SearchPathShortPath( 'DefaultLand', unitPathNode, targetPathNode )

        if table.getn(route) > 1 then
            path = { Utils.MarkerToPosition( unitPathNode ) }
            local number = table.getn(route)
            for k,v in route do
                # We are at the first point, ignore it for movement
                if k == 1 then
                    continue
                end
                if k != number then
                    table.insert( path, Utils.MarkerToPosition( v ) )
                else
                    point2[2] = GetSurfaceHeight( point2[1], point2[3] )
                    table.insert( path, point2 )
                end
            end
        end
    end

    if not path or table.getn( path ) < 3 then
        return VDist3XZ( point1, point2 )
    end

    local i = 1
    local j = 2
    while j <= table.getn(path) do
        distance = distance + VDist3XZ( path[i], path[j] )

        i = i + 1
        j = j + 1
    end

    return distance
end


function FindSafestPathingPoint( aiBrain, startPoint, endMarkers, multiplier )
    multiplier = multiplier or 10.0
    aiBrain:SetPathThreatMultiplier(multiplier)

    local startNode = aiBrain:FindClosestPathNode( 'DefaultLand', startPoint )

    local lowest, safestMarker

    if not startNode then
        return false
    end

    if not endMarkers then
        return false
    end

    for k,v in endMarkers do
        local tempPath, tempCost = aiBrain:SearchPathLowThreat( 'DefaultLand', startNode, v.MarkerName )
        if lowest and tempCost > lowest then
            continue
        end

        lowest = tempCost
        safestMarker = v
    end

    return safestMarker
end


function GetSafePathBetweenPoints(aiBrain, point1, point2, multiplier)
    multiplier = multiplier or 10.0
    aiBrain:SetPathThreatMultiplier(multiplier)

    local unitPathNode =  aiBrain:FindClosestPathNode( 'DefaultLand', point1 )
    local targetPathNode = aiBrain:FindClosestPathNode( 'DefaultLand', point2 )
    # Hey we have path nodes; gimme a route
    local path = false
    if unitPathNode and targetPathNode and not unitPathNode != targetPathNode then
        # Get Safe path to location
        local route, cost = aiBrain:SearchPathLowThreat( 'DefaultLand', unitPathNode, targetPathNode )

        if table.getn(route) > 1 then
            path = {}
            local number = table.getn(route)
            for k,v in route do
                # We are at the first point, ignore it for movement
                if k == 1 then
                    continue
                end
                if k != number then
                    table.insert( path, Utils.MarkerToPosition( v ) )
                else
                    point2[2] = GetSurfaceHeight( point2[1], point2[3] )
                    table.insert( path, point2 )
                end
            end
        end
    end

    return path
end

#-----------------------------------------------------
#   Function: GetPathGraphs
#   Args:
#   Description:
#       This function uses Graph Node markers in the map to generate a coarse pathfinding graph
#   Returns: A table of graphs. Table format is:
#           ScenarioInfo.PathGraphs -> Graph Layer -> Graph Name -> Marker Name -> Marker Data
#-----------------------------------------------------

function GetPathGraphs()
    if ScenarioInfo.PathGraphs then return ScenarioInfo.PathGraphs
    else ScenarioInfo.PathGraphs = {} end

    local markerGroups = {
        Land = GetAllMarkersType('Land Path Node') or {},
        ConquestFlagRally = GetAllMarkersType('Conquest Flag Rally Point') or {},
        StrongholdRally = GetAllMarkersType('Stronghold Attack Rally Point') or {},
        FortAttackRally = GetAllMarkersType('Fort Attack Rally Point') or {},
    }

    for gk, markerGroup in markerGroups do
        for mk, marker in markerGroup do
            -- Create stuff if it doesn't exist
            ScenarioInfo.PathGraphs[gk] = ScenarioInfo.PathGraphs[gk] or {}
            if not marker.graph or not marker.adjacentTo then
                continue
            end
            ScenarioInfo.PathGraphs[gk][marker.graph] = ScenarioInfo.PathGraphs[gk][marker.graph] or {}

            -- Add the marker to the graph.
            ScenarioInfo.PathGraphs[gk][marker.graph][marker.name] = {name = marker.name, layer = gk, graphName = marker.graph,
                            position = marker.position, adjacent = STR_GetTokens(marker.adjacentTo, ' '), color = marker.color}
        end
    end

    return ScenarioInfo.PathGraphs or {}
end

function GetAllMarkersType(markerType)
    local markers = Utils.GetMarkers()
    local markerList = {}
    #Make a list of all the markers in the scenario that are of the markerType
    if markers then
        for k, v in markers do
            if v.type == markerType then
                v.name = k
                table.insert(markerList, v )
            end
        end
    end
    return markerList
end

function InitializePathGraphs(brain)

    local markerGroups = {
        Land = GetAllMarkersType('Land Path Node') or {},
        ConquestFlagRally = GetAllMarkersType('Conquest Flag Rally Point') or {},
        StrongholdRally = GetAllMarkersType('Stronghold Attack Rally Point') or {},
        FortAttackRally = GetAllMarkersType('Fort Attack Rally Point') or {},
    }

    for gk, markerGroup in markerGroups do
        for mk, marker in markerGroup do

            if not marker.graph or not marker.adjacentTo then
                continue
            end

            brain:SetUpPathNode( marker.graph, marker.name, marker.position )

            local adjacentLinks = STR_GetTokens(marker.adjacentTo, ' ')
            for i, link in adjacentLinks do
                brain:LinkPathNode( marker.graph, marker.name, link )
            end
        end
    end

end

#-----------------------------------------------------
#   Function: DrawPathGraph
#   Args:
#   Description:
#       render graph on screen to verify correctness
#    Returns: nothing
#-----------------------------------------------------
function DrawPathGraph()

    -- Render the connection between the path nodes for the specific graph
    for graphLayer, graphTable in GetPathGraphs() do
        for name, graph in graphTable do
            for mn, markerInfo in graph do
                local pos = markerInfo.position
                local upVec = Vector(0,1,0)

                -- Draw the marker path node
                DrawCircle( pos, upVec, 5, 'FFFF0088', 20 )
                DrawCircle( pos, upVec, 5.5, 'FFFF0088', 20 )

                -- Draw the connecting lines to its adjacent nodes
                for i, node in markerInfo.adjacent do

                    local otherMarker = Utils.GetMarker(node)
                    if otherMarker then
                        DrawLinePop( markerInfo.position, otherMarker.position, 'FFFF0088' )
                    end
                end
            end
        end
    end

end

# AI Chat
function AIChat(unit, announcement, noRepeat)
	if(noRepeat) then
		if(unit.LastAnnouncement and unit.LastAnnouncement == announcement) then
			return false
		end
		unit.LastAnnouncement = announcement
	end

	if GetFocusArmy() > 0 and (IsAlly(unit:GetArmy(), GetFocusArmy())) then
		if(not Sync.AIChat) then
			Sync.AIChat = {}
		end
		local nameString = '['..convertIDtoName(unit:GetUnitId())..'] ' .. LOC(unit:GetAIBrain().Nickname)
		table.insert(Sync.AIChat,
			{

				Message = {to = 'allies', text = announcement,},
				Name =  nameString,
			}
		)
	end
end