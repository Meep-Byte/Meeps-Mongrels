local RAGAMUFFIN_SPEED = 2.2

function Meepsmongrels:ragamuffinInit(ragamuffin) -- adds sex to the dinding of shitsaac
    local EffectCol = Color(1,1,1,1, 0,0,0)
    EffectCol:SetColorize(0.84, 0.4, 0.68, 1)
    ragamuffin.SplatColor = EffectCol
    ragamuffin.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    ragamuffin:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
end
Meepsmongrels:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Meepsmongrels.ragamuffinInit, Meepsmongrels.enums.monsters.RAGAMUFFIN)

function Meepsmongrels:ragamuffinBehavior(ragamuffin)
    local ragamuffinSprite = ragamuffin:GetSprite()
    if ragamuffin.State == NpcState.STATE_INIT then
        if ragamuffinSprite:IsFinished("Appear") then
            ragamuffin.State = NpcState.STATE_MOVE
        end
    end
    if ragamuffin.State == NpcState.STATE_MOVE then
        if not ragamuffinSprite:IsPlaying("Idle") and ragamuffin.StateFrame < 120 then
            ragamuffinSprite:Play("Idle", true)
        end
        ragamuffin.StateFrame = math.min(ragamuffin.StateFrame + 1, 120)
        if ragamuffin.StateFrame == 120 then
            if ragamuffinSprite:IsEventTriggered("Shoot") then
                ragamuffin:PlaySound(SoundEffect.SOUND_SPIDER_COUGH, 1, 30, false, 1)
            end
            if ragamuffinSprite:IsEventTriggered("Explosion") then
                ragamuffin:PlaySound(SoundEffect.SOUND_FAT_GRUNT, 1, 30, false, 1) 
            end
            if ragamuffinSprite:IsFinished("Cough") then
                ragamuffin.State = NpcState.STATE_ATTACK
                ragamuffin.StateFrame = 0
                return
            end
            if not ragamuffinSprite:IsPlaying("Cough") then
                ragamuffinSprite:Play("Cough", true)
                print("brub")
            end
        end
    end
    if ragamuffin.State == NpcState.STATE_ATTACK then
        ragamuffin.StateFrame = math.min(ragamuffin.StateFrame + 1, 120)
        if ragamuffin.StateFrame <= 72 then
            if not ragamuffinSprite:IsPlaying("Spew") then
                ragamuffinSprite:Play("Spew", true)
            end
            if ragamuffin.StateFrame % 15 == 0 then
                local lokhust = Isaac.Spawn(Meepsmongrels.enums.monsters.LOKHUST, 0, 0, Vector(ragamuffin.Position.X + math.random(-5, 5), ragamuffin.Position.Y + 20), Vector.Zero, ragamuffin)
                lokhust.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                lokhust:GetData().damageCounter = 0
                lokhust:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                lokhust:GetSprite():Play("Appear", true)
                lokhust:GetSprite():SetFrame(8)
                local dust = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, ragamuffin.Position, Vector.Zero, nil):ToEffect()
                dust.DepthOffset = 20
                dust.SpriteOffset = Vector(0,- 14)
                dust.SpriteScale = Vector(0.4, 0.4)
                dust:SetTimeout(30)
            end
        else
            if ragamuffinSprite:IsFinished("SpewEnd") then
                ragamuffin.State = NpcState.STATE_MOVE
                ragamuffin.StateFrame = 0
                return
            end
            if not ragamuffinSprite:IsPlaying("SpewEnd") then
                ragamuffinSprite:Play("SpewEnd", true)
            end
        end
    end
    if ragamuffin.State ~= NpcState.STATE_INIT then
        ragamuffin.Velocity =  Meepsmongrels:Lerp(ragamuffin.Velocity, ragamuffin.Velocity * 0.3 + Meepsmongrels:GetDiagonalMovementVect(ragamuffin, RAGAMUFFIN_SPEED), 0.2)
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_NPC_UPDATE, Meepsmongrels.ragamuffinBehavior, Meepsmongrels.enums.monsters.RAGAMUFFIN)
