
local BIGGUN_PHASES = { -- used to determine health thresholds for various variants of biggun
    [0] = 17.5,
    [1] = 22.5,
    [1.5] = 11.25,
}

local BIGGUN_SPEEDS = {
    [0] = 2,
    [0.5] = 3.2,
}

function Meepsmongrels:biggunBehavior(biggun)
    local biggunSprite = biggun:GetSprite()
    local biggunTarget = biggun:GetPlayerTarget()
    if biggun.State == NpcState.STATE_INIT then
        if biggunSprite:IsFinished("Appear") then
            biggun.State = NpcState.STATE_MOVE
        end
    end
    if biggun.State == NpcState.STATE_MOVE and biggunTarget then
        biggun:AnimWalkFrame("WalkHori", "WalkVert", 0.1)
        Meepsmongrels:MoveToTarget(biggun, biggunTarget, BIGGUN_SPEEDS[biggun.Variant])
        if biggunSprite:GetFrame() == 0 then
            biggunSprite:PlayOverlay("Head", true)
        end
        if biggunSprite:IsEventTriggered("Stomp") then
            local dust = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, biggun.Position, Vector.Zero, nil):ToEffect()
            dust.DepthOffset = -100
            dust:SetTimeout(20)
            dust.SpriteScale = Vector(0.2, 0.2)
        end
        if biggun.HitPoints <= BIGGUN_PHASES[biggun.Variant] then
            biggun:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, 1, 6, false, 1)
            biggun.State = NpcState.STATE_SPECIAL
        end
    end
    if biggun.State == NpcState.STATE_SPECIAL then
        if biggunSprite:IsFinished("Body") then
            biggun.State = NpcState.STATE_ATTACK
        end
        if not biggunSprite:IsPlaying("Body") then
            biggunSprite:Play("Body", true)
            biggunSprite:PlayOverlay("HeadChange", true)
        end
        biggun.Velocity = Meepsmongrels:Lerp(biggun.Velocity, Vector.Zero, 0.2)
    end
    if biggun.State == NpcState.STATE_ATTACK and biggunTarget then
        biggun:AnimWalkFrame("WalkHori", "WalkVert", 0.1)
        Meepsmongrels:MoveToTarget(biggun, biggunTarget, BIGGUN_SPEEDS[biggun.Variant + 0.5])
        if biggunSprite:GetFrame() == 0 then
            biggunSprite:PlayOverlay("HeadAngry", true)
        end
        if biggunSprite:IsEventTriggered("Stomp") then
            local dust = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, biggun.Position, Vector.Zero, nil):ToEffect()
            dust.DepthOffset = -100
            dust:SetTimeout(20)
            dust.SpriteScale = Vector(0.2, 0.2)
        end
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_NPC_UPDATE, Meepsmongrels.biggunBehavior, Meepsmongrels.enums.monsters.BIGGUN)

function Meepsmongrels:onBiggunDeath(Npc)
    for i = 0, 4 do
        local blood = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, Npc.Position, Vector.Zero, nil):ToEffect()
        blood.SpriteOffset = Vector(math.random(-20, 20), math.random(-20, 0))
        blood:Update()
    end
    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, Npc.Position, Vector.Zero, nil):ToEffect()
    creep.Scale = 2
    creep:SetTimeout(60)
    creep:Update()
end
Meepsmongrels:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Meepsmongrels.onBiggunDeath, Meepsmongrels.enums.monsters.BIGGUN)