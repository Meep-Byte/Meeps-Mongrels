local CLUTCHLET_DIST = 4
local CLUTCHLET_SPEED = 5
function Meepsmongrels:clutchletInit(clutchlet)
    if clutchlet.Variant == Meepsmongrels.enums.monsters.CLUTCHLET then
        clutchlet:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        clutchlet:GetSprite():Play("Appear", true)
        clutchlet.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        clutchlet:GetData().canFlee = clutchlet:GetData().canFlee or true
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Meepsmongrels.clutchletInit, Meepsmongrels.enums.monsters.T_BONE)

function Meepsmongrels:clutchletUpdate(clutchlet)
    if clutchlet.Variant == Meepsmongrels.enums.monsters.CLUTCHLET then
        if clutchlet.Velocity.X <= 0 then
            clutchlet:GetSprite().FlipX = true
        else
            clutchlet:GetSprite().FlipX = false
        end
        if clutchlet.State == NpcState.STATE_INIT then
            if clutchlet:GetSprite():IsFinished("Appear") then
                clutchlet:GetSprite():Play("Idle")
                clutchlet.State = NpcState.STATE_MOVE
            end
        end

        if clutchlet.State == NpcState.STATE_MOVE then
            local clutchletTarget = clutchlet:GetPlayerTarget()
            if clutchletTarget then
                local room = Meepsmongrels.enums.utils.game:GetRoom()
                if clutchlet:GetData().canFlee and clutchlet.Position:Distance(clutchletTarget.Position) <= 160 and room:CheckLine(clutchlet.Position, clutchletTarget.Position, 3, 0,false, false) then
                local dirAngle = (clutchlet.Position - clutchletTarget.Position):GetAngleDegrees() + math.random(-120,120) -- selects a random angle relative to the player to flee in 
                -- deviates up to 120 degrees in either direction.
                    local clutchletPos = room:GetGridPosition(room:GetGridIndex(clutchlet.Position))
                    clutchlet:GetData().targPos = room:FindFreePickupSpawnPosition(clutchletPos + Vector(40 * CLUTCHLET_DIST, 0):Rotated(dirAngle))
                    -- sets the target position for the enemy to flee to

                end
                if clutchlet:GetData().targPos then
                    if clutchlet.FrameCount % 2 == 0 then
                        if clutchlet.Position:Distance(clutchlet:GetData().targPos) <= 40 then
                            if clutchlet.Position:Distance(clutchletTarget.Position) > 160 and room:CheckLine(clutchlet.Position, clutchletTarget.Position, 3, 0,false, false) then
                               clutchlet.Velocity = Meepsmongrels:Lerp(clutchlet.Velocity, Vector.Zero, 0.2)
                               clutchlet:GetData().canFlee = false
                            else
                                clutchlet:GetData().canFlee = true
                            end
                         else
                            clutchlet.Velocity = Meepsmongrels:Lerp(clutchlet.Velocity, (clutchlet:GetData().targPos - clutchlet.Position):Normalized()*CLUTCHLET_SPEED, 0.2)
                            clutchlet:GetData().canFlee = false
                        end
                    end
                end
            end
            if clutchlet.FrameCount > 150 then
                clutchlet:PlaySound(417, 1, 1, false, 1)
                clutchlet.State = NpcState.STATE_ATTACK
            end
        end
        if clutchlet.State == NpcState.STATE_ATTACK then
            if clutchlet.Parent and clutchlet.FrameCount % 2 == 0 then
                clutchlet.Velocity = Meepsmongrels:Lerp(clutchlet.Velocity, (clutchlet.Parent.Position - clutchlet.Position):Normalized()*CLUTCHLET_SPEED, 0.2)
                if clutchlet.Position:Distance(clutchlet.Parent.Position) <= 30 then
                    clutchlet.Parent.HitPoints = clutchlet.Parent.MaxHitPoints
                    clutchlet.Parent:GetSprite():Play("Revive", true)
                    clutchlet:Remove()
                end
            end
        end
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_NPC_UPDATE, Meepsmongrels.clutchletUpdate, Meepsmongrels.enums.monsters.T_BONE)

function Meepsmongrels:clutchletDeath(clutchlet)
    if clutchlet.Parent and clutchlet.Variant == Meepsmongrels.enums.monsters.CLUTCHLET then
        Meepsmongrels.enums.utils.sfx:Play(27, 1, 1, false, 1,0)
        for i = 0, 3 do
            local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, clutchlet.Parent.Position, Vector(math.random(-3,3), math.random(-3,3)), nil):ToEffect()
            smoke:SetTimeout(40)
        end
        clutchlet.Parent:Kill()

    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Meepsmongrels.clutchletDeath, Meepsmongrels.enums.monsters.T_BONE)