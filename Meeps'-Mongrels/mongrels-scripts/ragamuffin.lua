local RAGAMUFFIN_SPEED = 5
local  RAGAMUFFIN_DIRS = {
    [1] = Vector (-1, -1):Resized(RAGAMUFFIN_SPEED),
    [2] = Vector (1, -1):Resized(RAGAMUFFIN_SPEED),
    [3] = Vector (1, 1):Resized(RAGAMUFFIN_SPEED),
    [4] = Vector (-1, 1):Resized(RAGAMUFFIN_SPEED),
}

function Meepsmongrels:ragamuffinInit(ragamuffin) -- adds sex to the dinding of shitsaac
    local EffectCol = Color(1,1,1,1, 0,0,0)
    EffectCol:SetColorize(0.84, 0.4, 0.68, 1)
    ragamuffin.SplatColor = EffectCol
    ragamuffin:GetData().dir = 1
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
            end
        else
            if ragamuffinSprite:IsFinished("SpewEnd") then
                ragamuffin.State = NpcState.STATE_MOVE
                ragamuffin.StateFrame = 0
            end
            if not ragamuffinSprite:IsPlaying("SpewEnd") then
                ragamuffinSprite:Play("SpewEnd", true)
            end
        end
    end
    if ragamuffin.State ~= NpcState.STATE_INIT then
            ragamuffin.Velocity = Meepsmongrels:Lerp(ragamuffin.Velocity, RAGAMUFFIN_DIRS[ragamuffin:GetData().dir], 0.3)
            if ragamuffin:CollidesWithGrid() then
                for i = 0, 3 do
                    ragamuffin:GetData().dir = (ragamuffin:GetData().dir % 4) + 1
                 if Meepsmongrels.enums.utils.game:GetRoom():GetGridCollisionAtPos(ragamuffin.Position + RAGAMUFFIN_DIRS[ragamuffin:GetData().dir]) < 4 then
                    break
                end
            end
        end
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_NPC_UPDATE, Meepsmongrels.ragamuffinBehavior, Meepsmongrels.enums.monsters.RAGAMUFFIN)

function Meepsmongrels:onColl(ragamuffin, coll)
    if not coll:ToTear() and not coll:ToProjectile() and not coll.Type == Meepsmongrels.enums.monsters.LOKHUST then
        ragamuffin:GetData().dir = (ragamuffin:GetData().dir % 4) + 1
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, Meepsmongrels.onColl, Meepsmongrels.enums.monsters.RAGAMUFFIN)