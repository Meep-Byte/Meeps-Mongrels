
function Meepsmongrels:raggedHorfInit(horf)
    local EffectCol = Color(1,1,1,1, 0,0,0)
    EffectCol:SetColorize(0.84, 0.4, 0.68, 1)
    horf.SplatColor = EffectCol
end
Meepsmongrels:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Meepsmongrels.raggedHorfInit, Meepsmongrels.enums.monsters.RAGGED_HORF)

function Meepsmongrels:raggedHorfBehavior(horf)
    local horfTarget = horf:GetPlayerTarget()
    local horfSprite = horf:GetSprite()
    if horf.State == NpcState.STATE_INIT then
        if horf:GetData().headThrow then
            if horf.Position:Distance(horf:GetData().targposit) >= horf.Size then
            horf.Velocity = Meepsmongrels:Lerp(horf.Velocity, horf:GetData().targVeloc, 0.4)
            else
                horf.Velocity = Meepsmongrels:Lerp(horf.Velocity, Vector.Zero, 0.8)
                if horfSprite:IsFinished("Land") then
                    horf.State = NpcState.STATE_MOVE
                    horf:GetData().targVeloc = Meepsmongrels:GenVector(horf, horfTarget, 9)
                    if Meepsmongrels:GenVector(horf, horfTarget, 1).X <= 0 then
                        horfSprite.FlipX = true
                    end
                    horf.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                     horf.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                     print(horf.Position:Distance(horf:GetData().targposit))
                end
                if horfSprite:GetFrame() == 34 then
                    horf:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
                end
            end
        else
            if horf:GetSprite():IsFinished("Appear") and horfTarget then
                horf.State = NpcState.STATE_MOVE
                horf:GetData().targVeloc = Meepsmongrels:GenVector(horf, horfTarget, 9)
                if Meepsmongrels:GenVector(horf, horfTarget, 1).X <= 0 then
                    horfSprite.FlipX = true
                end
            end
        end
    end
    if horf.State == NpcState.STATE_MOVE and horf:GetData().targVeloc then
        horf.StateFrame = horf.StateFrame + 1
        if not horfSprite:IsPlaying("Move") then
            horfSprite:Play("Move", true)
        end
        horf.Velocity = Meepsmongrels:Lerp(horf.Velocity, horf:GetData().targVeloc, 0.2)
        if horf.StateFrame >= 45 or horf:CollidesWithGrid() then
            if Meepsmongrels.enums.utils.game:GetRoom():CheckLine(horf.Position, horfTarget.Position, 3, 0, true, false) then
                horf.State = NpcState.STATE_ATTACK
                horf.StateFrame = 0
                horfSprite:Play("Attack", true)
                if Meepsmongrels:GenVector(horf, horfTarget, 1).X <= 0 then
                    horfSprite.FlipX = true
                else
                    horfSprite.FlipX = false
                end
            else
                horf.State = NpcState.STATE_IDLE
            end
        end
    end
    if horf.State == NpcState.STATE_ATTACK and horfTarget then
        horf.Velocity = Meepsmongrels:Lerp(horf.Velocity, Vector.Zero, 0.2)
        if horfSprite:IsEventTriggered("Shoot") then
            horf:FireProjectiles(horf.Position, Meepsmongrels:GenVector(horf, horfTarget, 12), 0, ProjectileParams())
            horf:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, 1, 0, false, 1)
            local bloodshot = Isaac.Spawn(EntityType.ENTITY_EFFECT, 2, 5, horf.Position, Vector.Zero, nil):ToEffect()
            bloodshot:SetTimeout(20)
            bloodshot.DepthOffset = 100
            bloodshot.SpriteOffset = Vector(0, -3)
            bloodshot.SpriteScale = Vector(0.8, 0.8)
            local col = Color(1, 1, 1, 0.4, 0.6, 0.1, 0.1)
            bloodshot.Color = col
        end
        if horfSprite:IsFinished("Attack") then
            horf.State = NpcState.STATE_IDLE
        end
    end
    if horf.State == NpcState.STATE_IDLE and horfTarget then
        horf.Velocity = Vector.Zero
        horf.StateFrame = horf.StateFrame + 1
        if not horfSprite:IsPlaying("Idle") then
            horfSprite:Play("Idle", true)
        end
        if horf.StateFrame >= 15 then
            if not Meepsmongrels.enums.utils.game:GetRoom():CheckLine(horf.Position, horfTarget.Position, 0, 0, true, false) or math.random(1, 3) == 1 then
                horf:GetData().targPos = Meepsmongrels:GetTargJumpPos(horf.Position, horfTarget.Position, 4, true)
                horf:GetData().targVeloc = Meepsmongrels:GenVectorA(horf, horf:GetData().targPos, 1):Resized(horf.Position:Distance(horf:GetData().targPos)/10)
                horf.State = NpcState.STATE_JUMP
                horfSprite:Play("Hop", true)
                if Meepsmongrels:GenVector(horf, horfTarget, 1).X <= 0 then
                    horfSprite.FlipX = true
                else
                    horfSprite.FlipX = false
                end
            else
                horf:GetData().targVeloc = Meepsmongrels:GenVector(horf, horfTarget, 9)
                horf.State = NpcState.STATE_MOVE
                if Meepsmongrels:GenVector(horf, horfTarget, 1).X <= 0 then
                    horfSprite.FlipX = true
                else
                    horfSprite.FlipX = false
                end
            end
        end
    end
    if horf.State == NpcState.STATE_JUMP then
        if horfSprite:WasEventTriggered("Jump") and  not horfSprite:WasEventTriggered("Land") then
            horf.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            if horf.Position:Distance(horf:GetData().targPos) >= 20 then
            horf.Velocity = Meepsmongrels:Lerp(horf.Velocity, horf:GetData().targVeloc, 0.6)
            else
            horf.Velocity = Meepsmongrels:Lerp(horf.Velocity, Vector.Zero, 0.8)
            end
        end
        if horfSprite:WasEventTriggered("Land") then
            horf.Velocity = Vector.Zero
            horf.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        end
        if horfSprite:IsFinished("Hop")then
            if Meepsmongrels.enums.utils.game:GetRoom():CheckLine(horf.Position, horfTarget.Position, 3, 0, true, false) then
                 horfSprite:Play("Attack", true)
                horf.State = NpcState.STATE_ATTACK
                if Meepsmongrels:GenVector(horf, horfTarget, 1).X <= 0 then
                    horfSprite.FlipX = true
                else
                    horfSprite.FlipX = false
                end
            else
                horf.StateFrame = 0
                horf.State = NpcState.STATE_IDLE
            end
        end
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_NPC_UPDATE, Meepsmongrels.raggedHorfBehavior, Meepsmongrels.enums.monsters.RAGGED_HORF)