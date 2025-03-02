local TBONE_SPEED = 5
local TBONE_BULLET_SPEED = 12
-- Makes the appear animation play properly
function Meepsmongrels:tboneInit(tbone)
    if tbone.Variant == 0 then
    tbone:AddEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Meepsmongrels.tboneInit, Meepsmongrels.enums.monsters.T_BONE)
-- T-Bone's movement and shooting (Hope this works finally)
function Meepsmongrels:tboneUpdate(tbone)
if tbone.Variant == 0 then
tbone:GetData().damageCounter = 0
local tBoneSprite = tbone:GetSprite()
local tBoneTarget = tbone:GetPlayerTarget()
if tbone.State == NpcState.STATE_INIT then
    if tBoneSprite:IsEventTriggered("Yell") then
        tbone:PlaySound(307, 1, 1, false, 1)
    end
    if tBoneSprite:IsFinished("Appear") then
        tbone.State = NpcState.STATE_MOVE
        tbone.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        tbone:GetData().damageCounter = tbone:GetData().damageCounter or 0
    end
end
if tbone.State == NpcState.STATE_MOVE then -- Lerped Movement looks more natural in my opinion
    if tBoneTarget then
        if not tBoneSprite:IsPlaying("Idle") then
            tBoneSprite:Play("Idle", true)
        end
        local Velocity2 = (tBoneTarget.Position - tbone.Position):Normalized() * TBONE_SPEED
        tbone.Velocity = Meepsmongrels:Lerp(tbone.Velocity, Velocity2, 0.4)
        if tbone.Position:Distance(tBoneTarget.Position) <= 160 and tbone:IsFrame(30, 0) and math.random(1, 2) == 1 then
            tbone.State = NpcState.STATE_ATTACK
            tBoneSprite:Play("Attack", true) -- Force the attack anim call here so that it isn't called repeatedly, as it changes states after this line and this method is only called once
        end
    end
end
if tbone.State == NpcState.STATE_ATTACK then
    if tBoneTarget then
        if tBoneSprite:IsEventTriggered("SingleShot") then -- First Projectile Volley
            local params = ProjectileParams()
            params.Variant = 1
            params.HeightModifier = -16
            params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
            tbone:FireProjectiles(tbone.Position, (tBoneTarget.Position - tbone.Position):Normalized() * TBONE_BULLET_SPEED, 0, params)
            tbone:PlaySound(306, 1, 1, false, 1)
        end
        if tBoneSprite:IsEventTriggered("DoubleShot") then -- Second Projectile Volley
            local params = ProjectileParams()
            params.Variant = 1
            params.HeightModifier = -16
            params.Spread = 1
            params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE -- makes them "Spectral" without the new color
            tbone:FireProjectiles(tbone.Position, (tBoneTarget.Position - tbone.Position):Normalized() * TBONE_BULLET_SPEED, 1, params)
            tbone:PlaySound(306, 1, 1, false, 0.7)
        end
    end
    if tBoneSprite:IsFinished("Attack") then
        tbone.State = NpcState.STATE_MOVE
    end
end
if tbone.State == NpcState.STATE_SPECIAL then
    if tbone.Child then
        tBoneSprite:Play("Dead", true)
    else if tBoneSprite:IsEventTriggered("Return") then
            tbone.State = NpcState.STATE_INIT
            for i = 0, 3 do
                local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, tbone.Position, Vector(math.random(-3,3), math.random(-3,3)), nil):ToEffect()
                smoke:SetTimeout(40)
            end
            tBoneSprite:Play("Appear", true)
            tbone:GetData().isKilled = nil
        end
    end
end
end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_NPC_UPDATE, Meepsmongrels.tboneUpdate, Meepsmongrels.enums.monsters.T_BONE)

function Meepsmongrels:boneFlame(bone)-- fancy cool epic bone fire effect (Thank you ff devs)
    if bone.SpawnerType == Meepsmongrels.enums.monsters.T_BONE and bone.SpawnerVariant == 0 then
        if bone.FrameCount % 2 == 0 then
            local col = Color(0.77, 0.8, 0.8, 0.7, 0.4, 0.7, 1)
            local haemoCenter = Isaac.Spawn(1000, 111, 0, bone.Position, bone.Velocity, bone):ToEffect()
            haemoCenter.SpriteOffset = Vector(0, bone.Height + 10)
            haemoCenter.DepthOffset = -100
            haemoCenter.SpriteScale = Vector(0.5, 0.5)
            haemoCenter.Color = col

            local haemo = Isaac.Spawn(1000, 111, 0, bone.Position, Vector.Zero, bone):ToEffect()
            haemo.SpriteOffset = Vector(math.random(-4,4), bone.Height + 10 + math.random(-4,4))
            haemo.DepthOffset = -100
            local ss = math.random(0,5) / 10
            haemo.SpriteScale = Vector(ss,ss)
            haemo.Color = col
            haemo:Update()
        end
    end
end 
Meepsmongrels:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, Meepsmongrels.boneFlame, ProjectileVariant.PROJECTILE_BONE)

function Meepsmongrels:tboneDeath(tbone, amount) -- Kerkel my beloved (Theeere goeees myy heeerooo)
    local tbone2 = tbone:ToNPC()
    if tbone2 and tbone2.Variant == 0 then
        tbone2:GetData().damageCounter = tbone2:GetData().damageCounter + amount -- Track the total damage dealt this frame
        if (tbone2.HitPoints - tbone2:GetData().damageCounter <= 0 or tbone2.State == NpcState.STATE_SPECIAL) and not tbone:HasEntityFlags(EntityFlag.FLAG_FREEZE | EntityFlag.FLAG_MIDAS_FREEZE) then
            tbone2.State = NpcState.STATE_SPECIAL -- "Bone pile" state
            if tbone2:GetData().isKilled == nil then
                tbone2:GetData().isKilled = true
                local clutchlet = Isaac.Spawn(Meepsmongrels.enums.monsters.T_BONE, Meepsmongrels.enums.monsters.CLUTCHLET, 0, tbone2.Position, Vector(math.random(-1,1), math.random(-1,1)):Resized(3),tbone2)
                clutchlet.Parent = tbone
                tbone.Child = clutchlet
                for i = 0, 3 do 
                    local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, tbone2.Position, Vector(math.random(-3,3), math.random(-3,3)), nil):ToEffect()
                    smoke:SetTimeout(40)
                end
                Meepsmongrels.enums.utils.sfx:Play(27, 1, 1, false, 1,0)
            end
            return false
        end
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Meepsmongrels.tboneDeath, Meepsmongrels.enums.monsters.T_BONE)
