local RAGGEDGAPER2_SPEED = 3
function Meepsmongrels:raggedGaperInit(raggedGaper)
    local EffectCol = Color(1,1,1,1, 0,0,0)
    EffectCol:SetColorize(0.84, 0.4, 0.68, 1)
    raggedGaper.SplatColor = EffectCol
    raggedGaper:GetData().damageCounter = 0
end
Meepsmongrels:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Meepsmongrels.raggedGaperInit, Meepsmongrels.enums.monsters.RAGGED_GAPER)

function Meepsmongrels:raggedGaperBehavior(raggedgaper)
    raggedgaper:GetData().damageCounter = 0
    local gaperSprite = raggedgaper:GetSprite()
    local gaperTarget = raggedgaper:GetPlayerTarget()
    if raggedgaper.State == NpcState.STATE_INIT then
        if raggedgaper:GetSprite():IsFinished("Appear") then
            raggedgaper.State = NpcState.STATE_MOVE
        end
    end
    if raggedgaper.State == NpcState.STATE_MOVE and gaperTarget then
        if raggedgaper.Variant == 0 then
            raggedgaper:AnimWalkFrame("WalkHori","WalkVert", 0.1)
            Meepsmongrels:MoveToTarget(raggedgaper, gaperTarget, 2.5)
            if not gaperSprite:IsOverlayPlaying("Head") then
            gaperSprite:PlayOverlay("Head", true)
            end
        else
            raggedgaper:AnimWalkFrame("RunHori", "RunDown", 0.1)
            if Meepsmongrels:isScare(raggedgaper) then
                raggedgaper.Velocity = Meepsmongrels:Lerp(raggedgaper.Velocity, Meepsmongrels:GenVector(gaperTarget, raggedgaper, 4), 0.2)
            else
                if not Meepsmongrels.enums.utils.game:GetRoom():CheckLine(raggedgaper.Position, gaperTarget.Position, 0, 200, true, false) then
                    raggedgaper.Pathfinder:FindGridPath(gaperTarget.Position, RAGGEDGAPER2_SPEED/6, 0, false)
                else
                    raggedgaper.Velocity = (raggedgaper.Velocity*1.001)+(Meepsmongrels:GenVector(raggedgaper,gaperTarget, math.max(0.6, math.min(50/raggedgaper.Position:Distance(gaperTarget.Position),1.6))))
                    raggedgaper.Velocity = raggedgaper.Velocity:Resized(math.min(raggedgaper.Velocity:Length(),6))

                end
            end
        end
        Meepsmongrels.enums.utils.sfx:Play(SoundEffect.SOUND_RAGMAN_3, 2, 60, false, 1, 0)

    end
    if raggedgaper.State == NpcState.STATE_ATTACK then
        if raggedgaper.Variant == 0 then
            if gaperSprite:IsEventTriggered("Throw") then
                raggedgaper:PlaySound(SoundEffect.SOUND_MEATHEADSHOOT, 1, 0, false, 1)
            end
            raggedgaper.Velocity = Vector.Zero
            if gaperSprite:IsFinished("HeadThrow") then
                raggedgaper:Remove()
                local horf = Isaac.Spawn(Meepsmongrels.enums.monsters.RAGGED_HORF, 0, 0, raggedgaper.Position, Vector.Zero, nil)
                horf:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                horf:GetData().headThrow = true
                horf.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                horf:GetSprite():Play("Land", true)
                horf:GetSprite():SetFrame(0)
                horf.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                local gusher = Isaac.Spawn(Meepsmongrels.enums.monsters.PALLID_GUSHER, 0, 0, raggedgaper.Position, Vector.Zero, nil)
                gusher:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                local targPos = Meepsmongrels.enums.utils.game:GetRoom():FindFreePickupSpawnPosition(Meepsmongrels.enums.utils.game:GetRoom():GetRandomPosition(horf.Size), 0, false, false)
                 horf:GetData().targposit = targPos
                 horf:GetData().targVeloc = Meepsmongrels:GenVectorA(horf, targPos , 1):Resized(horf.Position:Distance(targPos)/(30))
                return
            end
            gaperSprite:RemoveOverlay()
            if not gaperSprite:IsPlaying("HeadThrow") then
                gaperSprite:Play("HeadThrow", true)
                raggedgaper:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, 1, 0, false, 1)
            end
        end
        if raggedgaper.Variant == 1 then
            raggedgaper.Velocity = Meepsmongrels:Lerp(raggedgaper.Velocity, Vector.Zero, 0.4)
            if gaperSprite:IsFinished("Die") then
                raggedgaper:Kill()
                return
            end
            if gaperSprite:IsEventTriggered("Sound") then
                raggedgaper:PlaySound(SoundEffect.SOUND_MONSTER_YELL_A, 1, 0, false, 1)  
            end
            if gaperSprite:IsEventTriggered("Shoot") then
                local params = ProjectileParams()
                params.BulletFlags = ProjectileFlags.SMART
                params.FallingSpeedModifier = -3
                local bloodshot = Isaac.Spawn(EntityType.ENTITY_EFFECT, 2, 5, raggedgaper.Position, Vector.Zero, nil):ToEffect()
                bloodshot:SetTimeout(20)
                bloodshot.DepthOffset = 100
                bloodshot.SpriteScale = Vector(0.8, 0.8)
                local EffectCol = Color(1,1,1,1, 0.26, 0.05, 0.4)
                EffectCol:SetColorize(0.8, 0.15, 1, 1)
                bloodshot.Color = EffectCol
                raggedgaper:FireProjectiles(raggedgaper.Position, Vector(12, 0), 6, params)

            end
            if not gaperSprite:IsPlaying("Die") then
                gaperSprite:Play("Die", true)
            end
        end
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_NPC_UPDATE, Meepsmongrels.raggedGaperBehavior, Meepsmongrels.enums.monsters.RAGGED_GAPER)

function Meepsmongrels:raggedGaperDeath(gaper, amount)
    local raggedGaper = gaper:ToNPC()
    raggedGaper:GetData().damageCounter = raggedGaper:GetData().damageCounter + amount
    if (raggedGaper.HitPoints - raggedGaper:GetData().damageCounter <= 0 or raggedGaper.State == NpcState.STATE_ATTACK) and not raggedGaper:HasEntityFlags(EntityFlag.FLAG_FREEZE | EntityFlag.FLAG_MIDAS_FREEZE) then
        raggedGaper.State = NpcState.STATE_ATTACK
        return false
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,  Meepsmongrels.raggedGaperDeath, Meepsmongrels.enums.monsters.RAGGED_GAPER)