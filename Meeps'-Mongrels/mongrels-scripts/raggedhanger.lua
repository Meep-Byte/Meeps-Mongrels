
local RAGGEDHANGER_SPEED = 2
local RAGGEDHANGER_RANGE = 160
local RAGGEDHANGER_BULLETSPEED = 8


function Meepsmongrels:raggedHangerInit(hanger)
    local EffectCol = Color(1,1,1,1, 0,0,0)
    EffectCol:SetColorize(0.84, 0.4, 0.68, 1)
    hanger.SplatColor = EffectCol
    hanger.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    hanger:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    hanger:GetSprite():Play("Appear01", true)
    hanger:GetData().attackCoolDown = 60
end
Meepsmongrels:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Meepsmongrels.raggedHangerInit, Meepsmongrels.enums.monsters.RAGGED_HANGER)

function Meepsmongrels:raggedHangerBehavior(hanger)
    local hangerSprite = hanger:GetSprite()
    local hangerTarget = hanger:GetPlayerTarget()
    if hanger.State == NpcState.STATE_INIT then
        if hangerSprite:IsFinished("Appear01") then
            hanger.State = NpcState.STATE_MOVE
            hangerSprite:Play("Head01", true)
        end
    end
    if hanger.State == NpcState.STATE_MOVE then
        hanger:GetData().attackCoolDown = math.max(hanger:GetData().attackCoolDown - 1, 0)
        if not hangerSprite:IsPlaying("Head01") then
            hangerSprite:Play("Head01", true)
        end
        if hanger.StateFrame % 10 == 0 and hangerTarget then
            hanger.Velocity = Meepsmongrels:Lerp(hanger.Velocity, Meepsmongrels:GenVector(hanger, hangerTarget, RAGGEDHANGER_SPEED), 0.2)
        end
        if hangerTarget and hanger:GetData().attackCoolDown == 0 and hanger.Position:Distance(hangerTarget.Position) <= RAGGEDHANGER_RANGE and Meepsmongrels.enums.utils.game:GetRoom():CheckLine(hanger.Position, hangerTarget.Position, 3, 900, false, false)  then
            hangerSprite:Play("AttackHead01", true)
            hanger.State = NpcState.STATE_ATTACK
        end
    end
    if hanger.State == NpcState.STATE_ATTACK then
        hanger.Velocity = Meepsmongrels:Lerp(hanger.Velocity, Vector.Zero, 0.2)
        if hangerSprite:IsEventTriggered("Shoot") and hangerTarget then
            local params = ProjectileParams()
            params.Spread = 1.7
            params.FallingSpeedModifier = -2.5
            params.FallingSpeedModifier = 0.05
            params.Acceleration = 1
            params.BulletFlags = ProjectileFlags.SMART | ProjectileFlags.ACCELERATE
            hanger:FireProjectiles(hanger.Position, Meepsmongrels:GenVector(hanger, hangerTarget, RAGGEDHANGER_BULLETSPEED), 1, params)
            hanger:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 1, false, 1)
            local bloodshot = Isaac.Spawn(EntityType.ENTITY_EFFECT, 2, 5, hanger.Position, Vector.Zero, nil):ToEffect()
            bloodshot:SetTimeout(20)
            bloodshot.DepthOffset = 100
            bloodshot.SpriteOffset = Vector(0, -16)
            bloodshot.SpriteScale = Vector(0.8, 0.8)
            local EffectCol = Color(1,1,1,1, 0.26, 0.05, 0.4)
            EffectCol:SetColorize(0.8, 0.15, 1, 1)
            bloodshot.Color = EffectCol
            if Meepsmongrels:GenVector(hanger, hangerTarget, RAGGEDHANGER_BULLETSPEED).X <= 0 then
                hangerSprite.FlipX = true
            else
               hangerSprite.FlipX = false
            end
        end
        if hangerSprite:IsFinished("AttackHead01") then
            hanger:GetData().attackCoolDown = 61
            hanger.State = NpcState.STATE_MOVE
        end
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_NPC_UPDATE, Meepsmongrels.raggedHangerBehavior, Meepsmongrels.enums.monsters.RAGGED_HANGER)
function Meepsmongrels:raggedHangerDeath(hanger)
 local bloodshot = Isaac.Spawn(EntityType.ENTITY_EFFECT, 2, 0, hanger.Position, Vector.Zero, nil):ToEffect()
 local EffectCol = Color(1,1,1,1, 0,0,0)
 EffectCol:SetColorize(0.84, 0.4, 0.68, 1)
 bloodshot.Color = EffectCol
end
Meepsmongrels:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Meepsmongrels.raggedHangerDeath, Meepsmongrels.enums.monsters.RAGGED_HANGER)
