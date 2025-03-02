local CLICKETYCLING_SPEED = 1.5
local CLICKETYCLING_BULLETSPEED = 10

function Meepsmongrels:clicketyClingInit(clicketycling)
    if clicketycling.Variant == Meepsmongrels.enums.monsters.CLICKETY_CLING then
        clicketycling:GetData().attackCoolDown = 30
        clicketycling:GetData().animVariant = math.random(1,4)
        clicketycling.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        clicketycling:ClearEntityFlags(EntityFlag.FLAG_APPEAR) -- prevents the game from playing its default appear animation so I can play my own.
        clicketycling:GetSprite():Play("Appear0"..clicketycling:GetData().animVariant, true) -- It has four unique appearances, determined randomly.
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Meepsmongrels.clicketyClingInit, Meepsmongrels.enums.monsters.T_BONE)

function Meepsmongrels:clicketyClingUpdate(clicketycling)
    if clicketycling.Variant == Meepsmongrels.enums.monsters.CLICKETY_CLING then
        local clicketyClingSprite = clicketycling:GetSprite()
        local clicketyClingTarget = clicketycling:GetPlayerTarget()
        if clicketycling.State == NpcState.STATE_INIT then
            if clicketyClingSprite:IsFinished("Appear0"..clicketycling:GetData().animVariant) then
                clicketycling.State = NpcState.STATE_MOVE
                clicketyClingSprite:Play("Head0"..clicketycling:GetData().animVariant, true)
            end
        end
        if clicketycling.State == NpcState.STATE_MOVE and clicketyClingTarget then
            clicketycling.Velocity = Meepsmongrels:Lerp(clicketycling.Velocity, (clicketyClingTarget.Position - clicketycling.Position):Normalized() * CLICKETYCLING_SPEED, 0.5)
            clicketycling:GetData().attackCoolDown = math.max(clicketycling:GetData().attackCoolDown - 1, 0)

            if clicketycling.Velocity.X > 0 then-- allows the enemy to turn around visually depending on the player's relative position
                clicketyClingSprite.FlipX = true
            else
                clicketyClingSprite.FlipX = false
            end

            if clicketycling:GetData().attackCoolDown == 0 and Meepsmongrels.enums.utils.game:GetRoom():CheckLine(clicketycling.Position, clicketyClingTarget.Position, 0, 0, false, false) and clicketycling.Position:Distance(clicketyClingTarget.Position) <= 360 then
                clicketyClingSprite:Play("AttackHead0"..clicketycling:GetData().animVariant, true)
                clicketycling.State = NpcState.STATE_ATTACK
            end
        end
        if clicketycling.State == NpcState.STATE_ATTACK and clicketyClingTarget then
            clicketycling.Velocity = Meepsmongrels:Lerp(clicketycling.Velocity, Vector.Zero, 0.5)
            if clicketyClingSprite:IsEventTriggered("Shoot") then
                if not clicketycling:GetData().predict then
                    clicketycling:GetData().predict = ((clicketyClingTarget.Position + (clicketyClingTarget.Velocity*10)) - clicketycling.Position):Normalized() * CLICKETYCLING_BULLETSPEED
                end

                if clicketycling:GetData().predict.X > 0 then
                    clicketyClingSprite.FlipX = true
                else
                    clicketyClingSprite.FlipX = false
                end
                local params = ProjectileParams()
                params.Variant = 1
                params.FallingSpeedModifier = -1
                clicketycling:FireProjectiles(clicketycling.Position, clicketycling:GetData().predict, 0, params)
                clicketycling:PlaySound(249, 1, 1, false, 1)
                local dust = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, clicketycling.Position, Vector.Zero, nil):ToEffect()
                dust.DepthOffset = 20
                dust.SpriteOffset = Vector(0,- 24)
                dust.SpriteScale = Vector(0.2, 0.2)
                dust:SetTimeout(30)
            end
            if clicketyClingSprite:IsFinished("AttackHead0"..clicketycling:GetData().animVariant) then
                clicketyClingSprite:Play("Head0"..clicketycling:GetData().animVariant, true)
                clicketycling:GetData().predict = nil
                clicketycling:GetData().attackCoolDown = 60
                clicketycling.State = NpcState.STATE_MOVE
            end
        end
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_NPC_UPDATE, Meepsmongrels.clicketyClingUpdate, Meepsmongrels.enums.monsters.T_BONE)