local LOKHOST_CHRGSPEED = 14
function Meepsmongrels:lokhostInit(lokhost)
    if lokhost.Variant == Meepsmongrels.enums.monsters.variants.LOKHOST then
        lokhost.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        lokhost:GetData().IsImmune = true
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Meepsmongrels.lokhostInit, Meepsmongrels.enums.monsters.LOKHUST)
function Meepsmongrels:lokhostUpdate(lokhost) -- this dude has a lotta code
    if lokhost.Variant == Meepsmongrels.enums.monsters.variants.LOKHOST then
        local lokhostSprite = lokhost:GetSprite()
        local lokhostTarget = lokhost:GetPlayerTarget()
        if lokhost.State == NpcState.STATE_INIT then
            if lokhostSprite:IsFinished("Appear") then
               lokhost.State = NpcState.STATE_IDLE
            end
        end
        if lokhost.State == NpcState.STATE_IDLE then
            lokhost.StateFrame = math.min(lokhost.StateFrame + 1, 60)
            if not lokhostSprite:IsPlaying("Idle") and not lokhost:GetData().dir then
                lokhostSprite:Play("Idle", true)
            end
            lokhost.Velocity = Meepsmongrels:Lerp(lokhost.Velocity, Meepsmongrels:GenVector(lokhost, lokhostTarget, 4), 0.2)
            if lokhost.StateFrame == 60 then
                lokhost:GetData().dir = lokhost:GetData().dir or Meepsmongrels:IsTargetAxisAligned(lokhost, lokhostTarget, 5)
                if lokhost:GetData().dir and lokhost.Position:Distance(lokhostTarget.Position) <= 440 then
                    if lokhost:GetData().dir == 0 then
                        if lokhostSprite:IsFinished("ChargeHori") then
                            lokhostSprite:Play("ChargeHoriLoop", true)
                            lokhost.State = NpcState.STATE_ATTACK
                            lokhost:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                            return
                        end
                        if lokhostSprite:WasEventTriggered("Charge") then
                            lokhost.Velocity = Meepsmongrels:Lerp(lokhost.Velocity, Vector(1, 0):Rotated(lokhost:GetData().dir * -90):Resized(LOKHOST_CHRGSPEED), 0.2)
                        else
                            lokhost.Velocity = Meepsmongrels:Lerp(lokhost.Velocity, Vector.Zero, 0.5)
                        end
                        if not lokhostSprite:IsPlaying("ChargeHori") then
                            lokhostSprite:Play("ChargeHori", true)
                            lokhostSprite.FlipX = false
                        end 
                    end
                    if lokhost:GetData().dir == 1 then
                        if lokhostSprite:IsFinished("ChargeUp") then
                            lokhostSprite:Play("ChargeUpLoop", true)
                            lokhost.State = NpcState.STATE_ATTACK
                            lokhost:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                            return
                        end
                        if lokhostSprite:WasEventTriggered("Charge") then
                            lokhost.Velocity = Meepsmongrels:Lerp(lokhost.Velocity, Vector(1, 0):Rotated(lokhost:GetData().dir * -90):Resized(LOKHOST_CHRGSPEED), 0.2)
                        else
                            lokhost.Velocity = Meepsmongrels:Lerp(lokhost.Velocity, Vector.Zero, 0.5)
                        end
                        if not lokhostSprite:IsPlaying("ChargeUp") then
                            lokhostSprite:Play("ChargeUp", true)
                        end  
                    end
                    if lokhost:GetData().dir == 2 then
                        if lokhostSprite:IsFinished("ChargeHori") then
                            lokhostSprite:Play("ChargeHoriLoop", true)
                            lokhost:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                            lokhost.State = NpcState.STATE_ATTACK
                            return
                        end
                        if lokhostSprite:WasEventTriggered("Charge") then
                            lokhost.Velocity = Meepsmongrels:Lerp(lokhost.Velocity, Vector(1, 0):Rotated(lokhost:GetData().dir * -90):Resized(LOKHOST_CHRGSPEED), 0.2)
                        else
                            lokhost.Velocity = Meepsmongrels:Lerp(lokhost.Velocity, Vector.Zero, 0.5)
                        end
                        if not lokhostSprite:IsPlaying("ChargeHori") then
                            lokhostSprite:Play("ChargeHori", true)
                            lokhostSprite.FlipX = true
                        end 
                    end
                    if lokhost:GetData().dir == 3 then
                        if lokhostSprite:IsFinished("ChargeDown") then
                            lokhostSprite:Play("ChargeDownLoop", true)
                            lokhost:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                            lokhost.State = NpcState.STATE_ATTACK
                            return
                        end
                        if lokhostSprite:WasEventTriggered("Charge") then
                            lokhost.Velocity = Meepsmongrels:Lerp(lokhost.Velocity, Vector(1, 0):Rotated(lokhost:GetData().dir * -90):Resized(LOKHOST_CHRGSPEED), 0.2)
                        else
                            lokhost.Velocity = Meepsmongrels:Lerp(lokhost.Velocity, Vector.Zero, 0.5)
                        end
                        if not lokhostSprite:IsPlaying("ChargeDown") then
                            lokhostSprite:Play("ChargeDown", true)
                        end
                    end
                end
            end
        end
        if lokhost.State == NpcState.STATE_ATTACK then
            lokhost.Velocity = Meepsmongrels:Lerp(lokhost.Velocity, Vector(1, 0):Rotated(lokhost:GetData().dir * -90):Resized(LOKHOST_CHRGSPEED), 0.2)
            print(lokhost.Velocity)
            if Meepsmongrels.enums.utils.game:GetRoom():GetGridCollisionAtPos(lokhost.Position) <= 1 then
                lokhost.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
            end
            if lokhost:CollidesWithGrid() then
                lokhost.State = NpcState.STATE_ATTACK2
                lokhost.Velocity = Vector.Zero
            end
        end
        if lokhost.State == NpcState.STATE_ATTACK2 then
            lokhost.StateFrame = 0
            if lokhost:GetData().dir == 0 then
                if lokhostSprite:IsFinished("WallSlamHori") then
                    lokhost.State = NpcState.STATE_SPECIAL
                    lokhostSprite:Play("WallSlamHoriLoop", true)
                    return
                end
                if lokhostSprite:IsEventTriggered("Open") then
                    lokhost:GetData().IsImmune = false
                    lokhost:PlaySound(SoundEffect.SOUND_BONE_SNAP, 1, 0, false, 1)
                end
                if not lokhostSprite:IsPlaying("WallSlamHori") then
                    lokhostSprite:Play("WallSlamHori", true)
                end
            end
            if lokhost:GetData().dir == 1 then
                if lokhostSprite:IsFinished("WallSlamUp") then
                    lokhost.State = NpcState.STATE_SPECIAL
                    lokhostSprite:Play("WallSlamDownLoop", true)
                    return
                end
                if lokhostSprite:IsEventTriggered("Open") then
                    lokhost:GetData().IsImmune = false
                    lokhostSprite.FlipY = true
                    lokhost:PlaySound(SoundEffect.SOUND_BONE_SNAP, 1, 0, false, 1)
                end
                if not lokhostSprite:IsPlaying("WallSlamUp") then
                    lokhostSprite:Play("WallSlamUp", true)
                end
            end
            if lokhost:GetData().dir == 2 then
                if lokhostSprite:IsFinished("WallSlamHori") then
                    lokhost.State = NpcState.STATE_SPECIAL
                    lokhostSprite:Play("WallSlamHoriLoop", true)
                    return
                end
                if lokhostSprite:IsEventTriggered("Open") then
                    lokhost:GetData().IsImmune = false
                    lokhost:PlaySound(SoundEffect.SOUND_BONE_SNAP, 1, 0, false, 1)
                end
                if not lokhostSprite:IsPlaying("WallSlamHori") then
                    lokhostSprite:Play("WallSlamHori", true)
                    lokhost.FlipX = true
                end
            end
            if lokhost:GetData().dir == 3 then
                if lokhostSprite:IsFinished("WallSlamDown") then
                    lokhost.State = NpcState.STATE_SPECIAL
                    lokhostSprite:Play("WallSlamDownLoop", true)
                    return
                end
                if lokhostSprite:IsEventTriggered("Open") then
                    lokhost:GetData().IsImmune = false
                    lokhost:PlaySound(SoundEffect.SOUND_BONE_SNAP, 1, 0, false, 1)
                end
                if not lokhostSprite:IsPlaying("WallSlamDown") then
                    lokhostSprite:Play("WallSlamDown", true)
                end
            end
            if lokhostSprite:IsEventTriggered("Shoot") then
                local params = ProjectileParams()
                params.FallingSpeedModifier = -3.2
                lokhost:FireProjectiles(lokhost.Position + Vector(15, 0):Rotated((lokhost:GetData().dir * -90) - 180),  Vector(9, 0):Rotated((lokhost:GetData().dir * -90 - 180)) , 0, params)
                local roll = math.random(1, 3)
                if roll == 1 then
                    lokhost:PlaySound(SoundEffect.SOUND_LITTLE_SPIT, 1, 0, false, 1)
                else
                    lokhost:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
                end
                for i = 0, 4 do 
                    local par = ProjectileParams()
                    params.FallingSpeedModifier = -5.2
                    params.FallingAccelModifier = 1.3
                    lokhost:FireProjectiles(lokhost.Position + Vector(15, 0):Rotated((lokhost:GetData().dir * -90) - 180),  Vector(math.random(2, 5), 0):Rotated((lokhost:GetData().dir * -90) - 180 + math.random(-40, 40)), 0, par)
                end
            end
        end
        if lokhost.State == NpcState.STATE_SPECIAL then
            lokhost.StateFrame = math.min(lokhost.StateFrame + 1, 177)
            if lokhost.StateFrame < 177 then
                if lokhostSprite:IsEventTriggered("Shoot") then
                    local params = ProjectileParams()
                    params.FallingSpeedModifier = -3.2
                    lokhost:FireProjectiles(lokhost.Position + Vector(15, 0):Rotated((lokhost:GetData().dir * -90) - 180),  Vector(9, 0):Rotated((lokhost:GetData().dir * -90 - 180)) , 0, params)
                    local roll = math.random(1, 3)
                    if roll == 1 then
                        lokhost:PlaySound(SoundEffect.SOUND_LITTLE_SPIT, 1, 0, false, 1)
                    else
                        lokhost:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
                    end
                    for i = 0, 4 do 
                        local par = ProjectileParams()
                        params.FallingSpeedModifier = -5.2
                        params.FallingAccelModifier = 1.3
                        lokhost:FireProjectiles(lokhost.Position + Vector(15, 0):Rotated((lokhost:GetData().dir * -90) - 180),  Vector(math.random(2, 5), 0):Rotated((lokhost:GetData().dir * -90) - 180 + math.random(-40, 40)), 0, par)
                    end
                end
            else
                if lokhost:GetData().dir == 0 then
                    if lokhostSprite:IsFinished("RecoverHori") then
                        lokhost.State = NpcState.STATE_IDLE
                        lokhost:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                        lokhost.StateFrame = 0
                        lokhost:GetData().dir = nil
                        lokhost.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
                        return
                    end
                    if lokhostSprite:IsEventTriggered("Close") then
                        lokhost:GetData().IsImmune = true
                    end
                    if not lokhostSprite:IsPlaying("RecoverHori") then
                        lokhostSprite:Play("RecoverHori", true)
                    end
                end
                if lokhost:GetData().dir == 1 then
                    if lokhostSprite:IsFinished("RecoverDown") then
                        lokhost.State = NpcState.STATE_IDLE
                        lokhost:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                        lokhost.StateFrame = 0
                        lokhost:GetData().dir = nil
                        lokhost.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
                        return
                    end
                    if lokhostSprite:IsEventTriggered("Close") then
                        lokhost:GetData().IsImmune = true
                        lokhostSprite.FlipY = false
                    end
                    if not lokhostSprite:IsPlaying("RecoverDown") then
                        lokhostSprite:Play("RecoverDown", true)
                    end
                end
                if lokhost:GetData().dir == 2 then
                    if lokhostSprite:IsFinished("RecoverHori") then
                        lokhost.State = NpcState.STATE_IDLE
                        lokhost:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                        lokhost.StateFrame = 0
                        lokhost:GetData().dir = nil
                        lokhost.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
                        return
                    end
                    if lokhostSprite:IsEventTriggered("Close") then
                        lokhost:GetData().IsImmune = true
                        lokhostSprite.FlipX = false
                    end
                    if not lokhostSprite:IsPlaying("RecoverHori") then
                        lokhostSprite:Play("RecoverHori", true)
                    end
                end
                if lokhost:GetData().dir == 3 then
                    if lokhostSprite:IsFinished("RecoverDown") then
                        lokhost.State = NpcState.STATE_IDLE
                        lokhost:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                        lokhost.StateFrame = 0
                        lokhost:GetData().dir = nil
                        lokhost.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
                        return
                    end
                    if lokhostSprite:IsEventTriggered("Close") then
                        lokhost:GetData().IsImmune = true
                    end
                    if not lokhostSprite:IsPlaying("RecoverDown") then
                        lokhostSprite:Play("RecoverDown", true)
                    end
                end
            end
        end
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_NPC_UPDATE, Meepsmongrels.lokhostUpdate, Meepsmongrels.enums.monsters.LOKHUST)

