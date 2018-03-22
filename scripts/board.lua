
--[[
	Returns the first point on the board that matches the specified predicate.
	If no matching point is found, this function returns nil.

	predicate
		A function taking a Point as argument, and returning a boolean value.
]]--
function GetSpace(predicate)
	assert(type(predicate) == "function")

	local size = Board:GetSize()
	for x = 0, size.x - 1 do
		for y = 0, size.y - 1 do
			local p = Point(x, y)
			if predicate(p) then
				return p
			end
		end
	end

	return nil
end

--[[
	Returns the first point on the board that is not blocked.
]]--
function GetUnoccupiedSpace()
	return GetSpace(function(point)
		return not Board:IsBlocked(point, PATH_GROUND)
	end)
end

function GetUnoccupiedRestorableSpace()
	return GetSpace(function(point)
		return not Board:IsBlocked(point, PATH_GROUND) and IsRestorableTerrain(point)
	end)
end

--[[
	Returns true if the point is terrain that can be restored to its previous
	state without any issues.
]]--
function IsRestorableTerrain(point)
	local terrain = Board:GetTerrain(point)

	-- Mountains and ice can be broken
	-- Buildings can be damaged or damaged
	return terrain ~= TERRAIN_MOUNTAIN  and terrain ~= TERRAIN_ICE
		and terrain ~= TERRAIN_BUILDING
end

function GetRestorableTerrainData(point)
	local data = {}
	data.type = Board:GetTerrain(point)
	data.smoke = Board:IsSmoke(point)
	data.acid = Board:IsAcid(point)

	return data
end

function RestoreTerrain(point, terrainData)
	Board:ClearSpace(point)
	Board:SetTerrain(point, terrainData.type)
	-- No idea what the second boolean argument does here
	Board:SetSmoke(point,terrainData.smoke, false)
	Board:SetAcid(point,terrainData.acid)
end

function IsPawnOnBoard(pawn)
	return list_contains(extract_table(Board:GetPawns(TEAM_ANY)), pawn:GetId())
end