
function Meepsmongrels:lokhustInit(lokhust)
    if lokhust.Variant == 0 then
    lokhust.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    lokhust:GetData().damageCounter = 0
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Meepsmongrels.lokhustInit, Meepsmongrels.enums.monsters.LOKHUST)
function Meepsmongrels:lokhustBehavior(lokhust)
    if lokhust.Variant == 0 then
    if lokhust.State ~= NpcState.STATE_SPECIAL then
        lokhust:PlaySound(Meepsmongrels.enums.sounds.BUG_SWARM, 1, 20, false, 1)
    end
    lokhust:GetData().damageCounter = 0
    local lokhustSprite = lokhust:GetSprite()
    local lokhustTarget = lokhust:GetPlayerTarget()
    local room = Meepsmongrels.enums.utils.game:GetRoom()
    if lokhust.State == NpcState.STATE_INIT then
        if lokhustSprite:IsFinished("Appear") then
            lokhust.State = NpcState.STATE_MOVE
        end
    end
    if lokhust.State == NpcState.STATE_MOVE then
        if not lokhustSprite:IsPlaying("Idle") then
            lokhustSprite:Play("Idle", true)
        end
        lokhust.Velocity = (lokhust.Velocity*1.001)+(Meepsmongrels:GenVector(lokhust, lokhustTarget, math.max(0.6, math.min(50/lokhust.Position:Distance(lokhustTarget.Position),1))))
        lokhust.Velocity = lokhust.Velocity:Resized(math.min(lokhust.Velocity:Length(),5))
        if lokhust.Velocity.X < 0 then
            lokhustSprite.FlipX = true
        else
            lokhustSprite.FlipX = false
        end
        if lokhust.FrameCount >= 60 and lokhust:IsFrame(10, 0) and math.random(1, 5) == 1 then
             if room:GetGridCollisionAtPos(lokhust.Position) == GridCollisionClass.COLLISION_NONE and lokhust.Position:Distance(lokhustTarget.Position) <= 360 and Meepsmongrels:getNumAttackingLokhusts() < 2 and room:CheckLine(lokhust.Position, lokhustTarget.Position, 3, 900, true, false) then
                lokhust.State = NpcState.STATE_ATTACK
                lokhustSprite:Play("Attack", true)
                if Meepsmongrels:GenVector(lokhust, lokhustTarget, 1).X < 0  then
                    lokhustSprite.FlipX = true
                else
                    lokhustSprite.FlipX = false
                end
             end
        end
    end
    if lokhust.State == NpcState.STATE_ATTACK then
        lokhust.Velocity = Meepsmongrels:Lerp(lokhust.Velocity, Vector.Zero, 0.5)
        if lokhustSprite:IsFinished("Attack") then
            lokhust:GetData().Dirveloc = Meepsmongrels:GenVector(lokhust, lokhustTarget, 12)
            lokhust.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
            lokhust.State = NpcState.STATE_SUICIDE
            lokhustSprite.FlipX = false
            lokhust:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK|EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        end
    end
    if lokhust.State == NpcState.STATE_SUICIDE then
        if not lokhustSprite:IsPlaying("Charge") then
            lokhustSprite:Play("Charge", true)
        end
        lokhust.Velocity = lokhust:GetData().Dirveloc
        lokhustSprite.Rotation = lokhust:GetData().Dirveloc:GetAngleDegrees()
        lokhustSprite.Offset = Vector(0, -27)
        if lokhust:CollidesWithGrid() then
            lokhust:TakeDamage(99, DamageFlag.DAMAGE_FIRE, EntityRef(lokhust), 0)
        end
    end
    if lokhust.State == NpcState.STATE_SPECIAL then
        lokhust.Velocity = Vector.Zero
        lokhust.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        lokhustSprite.Offset = Vector(0, -27)
        if lokhustSprite:IsFinished("Death") then
            lokhust:Remove()
            return
        end
        if not lokhustSprite:IsPlaying("Death") then
            lokhustSprite:Play("Death", true)
            lokhust:PlaySound(SoundEffect.SOUND_DEATH_BURST_SMALL, 1, 0, false, 1)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, 7, 0, lokhust.Position, Vector.Zero, nil):ToEffect()
        end
    end
end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_NPC_UPDATE, Meepsmongrels.lokhustBehavior, Meepsmongrels.enums.monsters.LOKHUST)

function Meepsmongrels:lokhustDeath(lokhust, amount)
    if lokhust.Variant == 0 then
local lokhust2 = lokhust:ToNPC()
lokhust2:GetData().damageCounter = lokhust2:GetData().damageCounter + amount
if (lokhust2.HitPoints - lokhust2:GetData().damageCounter <= 0 or lokhust2.State == NpcState.STATE_SPECIAL) and not lokhust2:HasEntityFlags(EntityFlag.FLAG_FREEZE | EntityFlag.FLAG_MIDAS_FREEZE) then
    lokhust2.State = NpcState.STATE_SPECIAL
    return false
end
end
if lokhust.Variant == Meepsmongrels.enums.monsters.variants.LOKHOST then
    if lokhust:GetData().IsImmune then
        return false
    end
end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Meepsmongrels.lokhustDeath, Meepsmongrels.enums.monsters.LOKHUST)