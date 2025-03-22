
local BirdieSpeeds = {
[0] = 3
}
function Meepsmongrels:BirdieBehavior(birdie)
    local birdieSprite = birdie:GetSprite()
    local birdieTarget = birdie:GetPlayerTarget()
    if birdie.State == NpcState.STATE_INIT then
        if birdieSprite:IsFinished("Appear") then
            birdie.State = NpcState.STATE_IDLE
        end
    end
    if birdie.State == NpcState.STATE_IDLE then
        if Meepsmongrels:isScareOrConfuse(birdie) then
            if Meepsmongrels:isScare(birdie) then
                birdie.Velocity = Meepsmongrels:Lerp(birdie.Velocity, Meepsmongrels:GenVector(birdieTarget, birdie, BirdieSpeeds[birdie.Variant] + 1), 0.2)
            end
            if Meepsmongrels:isConfuse(birdie) then
                birdie:GetData().confdir = birdie:GetData().confdir or Vector(BirdieSpeeds[birdie.Variant], 0):Rotated(math.random(0, 360))
                birdie.Velocity = Meepsmongrels:Lerp(birdie.Velocity, birdie:GetData().confdir, 0.2)
                if birdie.FrameCount % 20 == 0 then
                    birdie:GetData().confdir = nil
                end
            end
        else
            if not birdieSprite:IsPlaying("Idle") then
                birdieSprite:Play("Idle", true)
            end
            if birdieSprite:GetFrame() >= 9 then
                birdie:GetData().veloc = birdie:GetData().veloc or Meepsmongrels:GenVector(birdie, birdieTarget, BirdieSpeeds[birdie.Variant]):Rotated(math.random(-40, 40))
                birdie:PlaySound(SoundEffect.SOUND_BIRD_FLAP, 1, 14, false, 1) 
                birdie.Velocity = Meepsmongrels:Lerp(birdie.Velocity, birdie:GetData().veloc, 0.2)
            else
                birdie.Velocity = Meepsmongrels:Lerp(birdie.Velocity, Vector.Zero, 0.1)
                birdie:GetData().veloc = nil
            end
            
            if birdie.Velocity.X < 0 then
                birdieSprite.FlipX = false
            else
                birdieSprite.FlipX = true
            end
        end
    end
end
Meepsmongrels:AddCallback(ModCallbacks.MC_NPC_UPDATE, Meepsmongrels.BirdieBehavior, Meepsmongrels.enums.monsters.BIRDIE)