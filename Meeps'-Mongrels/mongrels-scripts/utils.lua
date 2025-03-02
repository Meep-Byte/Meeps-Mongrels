function Meepsmongrels:Lerp(vec1, vec2, percent)
    return vec1 * (1 - percent) + vec2 * percent
end

function Meepsmongrels:GenVector(ent1, ent2, magnitude)  -- helper function to generate a vector pointing from ent1 to ent2 with a specified magnitude.
return (ent2.Position - ent1.Position):Resized(magnitude)
end
function Meepsmongrels:GenVectorA(ent1, pos, magnitude)  -- helper function to generate a vector pointing from ent1 to a targpos with a specified magnitude
return (pos - ent1.Position):Resized(magnitude)
end
function Meepsmongrels:GenVectorB(pos1, pos2, magnitude)  -- helper function to generate a vector pointing from a pos to a targpos with a specified magnitude
return (pos2 - pos1):Resized(magnitude)
end

function Meepsmongrels:MoveToTarget(ent1, ent2, speed) -- can it get more self-explanatory?
if Meepsmongrels:isScare(ent1) then
    local targetVector = Meepsmongrels:GenVector(ent1, ent2, speed):Resized(-speed - 2)
    ent1.Velocity = targetVector
elseif Meepsmongrels.enums.utils.game:GetRoom():CheckLine(ent1.Position, ent2.Position, 0, 200, true, false) or ent1.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_GROUND and ent1.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_NO_PITS then
    ent1.Velocity = Meepsmongrels:GenVector(ent1, ent2, speed)
else
     ent1.Pathfinder:FindGridPath(ent2.Position, speed / 6, 0, false)
end
if Meepsmongrels.enums.utils.game:GetRoom():GetGridPathFromPos(ent1.Position) <= 900 then
    Meepsmongrels.enums.utils.game:GetRoom():SetGridPath(Meepsmongrels.enums.utils.game:GetRoom():GetGridIndex(ent1.Position), 900)
end
end


-- Ooh I stole some 3 line functions from FF!!! Oooooh!!! I'm in trouble now!!!
function Meepsmongrels:isScare(npc)
	return npc:HasEntityFlags(EntityFlag.FLAG_FEAR | EntityFlag.FLAG_SHRINK)
end
function Meepsmongrels:isConfuse(npc)
	return npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION)
end

function Meepsmongrels:isScareOrConfuse(npc)
	return npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION | EntityFlag.FLAG_FEAR | EntityFlag.FLAG_SHRINK)
end

function Meepsmongrels:GetTargJumpPos(pos, targpos, amount, limit) -- A function that serves to emulate how trites get a position to jump to (Thanks, Crabby).
    local room = Meepsmongrels.enums.utils.game:GetRoom()
    local pos1 = room:GetGridPosition(room:GetGridIndex(pos))
    local pos2 = room:GetGridPosition(room:GetGridIndex(targpos))
    for i = 1, amount do
       local step = pos + (Vector(40* i, 0):Rotated(Meepsmongrels:GenVectorB(pos1, pos2, 1):GetAngleDegrees()))
       local dist = pos:Distance(pos2)
       local closedDist = pos:Distance(step)
       if closedDist >= dist then
        if room:GetGridCollisionAtPos(step) == GridCollisionClass.COLLISION_NONE then
            return room:GetGridPosition(room:GetGridIndex(step))
        end
       end
       if i == amount then
        if limit then
            return room:FindFreePickupSpawnPosition(room:GetGridPosition(room:GetGridIndex(step)))
        else
            return room:FindFreePickupSpawnPosition(room:GetGridPosition(room:GetGridIndex(pos2)))
        end
       end
    end
end