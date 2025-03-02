--local GUSHER_SPEED = 4
function Meepsmongrels:pallidGusherInit(gusher)
    local EffectCol = Color(1,1,1,1, 0,0,0)
    EffectCol:SetColorize(0.84, 0.4, 0.68, 1)
    gusher.SplatColor = EffectCol
    gusher:GetSprite():PlayOverlay("Blood", true)
    gusher:GetData().targPos = Meepsmongrels.enums.utils.game:GetRoom():GetRandomPosition(gusher.Size)
end
Meepsmongrels:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Meepsmongrels.pallidGusherInit, Meepsmongrels.enums.monsters.PALLID_GUSHER)
function Meepsmongrels:pallidGusherBehavior(gusher)
   -- local gusherTarget = gusher:GetPlayerTarget()
    gusher:AnimWalkFrame("WalkHori", "WalkVert", 0.1)
    if gusher.State == NpcState.STATE_INIT then
        if gusher.FrameCount >= 30 then
            gusher.State = NpcState.STATE_MOVE
        end
    end
    if gusher.State == NpcState.STATE_MOVE then
        gusher.Velocity = Meepsmongrels:Lerp(gusher.Velocity, Meepsmongrels:GenVectorA(gusher, gusher:GetData().targPos, 2), 0.4)
        if gusher:CollidesWithGrid() or gusher.Position:Distance(gusher:GetData().targPos) <= 40  or gusher:IsFrame(60, 0) then
            gusher:GetData().targPos = Meepsmongrels.enums.utils.game:GetRoom():GetRandomPosition(gusher.Size)
        end
        if gusher.FrameCount % 10 == 0 then
            local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, 7, 0, gusher.Position, Vector.Zero, nil):ToEffect()
            local EffectCol = Color(1,1,1,1, 0,0,0)
            EffectCol:SetColorize(0.84, 0.4, 0.68, 1)
            splat.Color = EffectCol
            splat.SpriteScale = Vector(0.3, 0.3)
            splat.SpriteOffset = Vector(math.random(-4, 4), 0)
        end
    end
    if gusher.FrameCount % 60 == 0 then
        gusher:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 1, false, 1)
        for i = 90, 270, 180 do
            local params = ProjectileParams()
            params.BulletFlags = ProjectileFlags.CURVE_RIGHT | ProjectileFlags.NO_WALL_COLLIDE
            local EffectCol = Color(1,1,1,1, 0,0,0)
            EffectCol:SetColorize(0.84, 0.4, 0.68, 1)
            params.Color = EffectCol
            params.CurvingStrength = 0.017
            params.FallingSpeedModifier = -0.0457
            gusher:FireProjectiles(gusher.Position, Vector.FromAngle(i):Resized(7), 0, params)
        end
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_NPC_UPDATE, Meepsmongrels.pallidGusherBehavior, Meepsmongrels.enums.monsters.PALLID_GUSHER)
