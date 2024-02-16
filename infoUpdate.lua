local mq = require('mq')


InfoUpdate = {}

function InfoUpdate.updateBuffs(previousMimicBuffs, mimicBuffs)
    local sendUpdate = false
    for index = 1, mq.TLO.Me.MaxBuffSlots() do
        if mq.TLO.Me.Buff(index).ID() ~= nil and previousMimicBuffs[index] ~= mq.TLO.Me.Buff(index).ID() then
            previousMimicBuffs[index] = mq.TLO.Me.Buff(index).Spell()
        end
    end
    for i = 1, #previousMimicBuffs do
        if mimicBuffs[i] ~= previousMimicBuffs[i] then
            sendUpdate = true
            mimicBuffs[i] = previousMimicBuffs[i]
            print(mimicBuffs[i])
        end
    end
    return {sendUpdate, mimicBuffs}
end

function InfoUpdate.updateSpellbar(previousSpellbar, spellbarIds)
    local sendUpdate = false
    for i = 1, mq.TLO.Me.NumGems() do
        if mq.TLO.Me.Gem(i).ID() == nil then
            previousSpellbar[i] = 'Empty'
        end
        if mq.TLO.Me.Gem(i).ID() ~= nil then
            previousSpellbar[i] = mq.TLO.Me.Gem(i).ID()
        end
    end
    for i = 1, #previousSpellbar do
        if spellbarIds[i] ~= previousSpellbar[i] or spellbarIds[i] == nil then
            spellbarIds[i] = previousSpellbar[i]
            print(spellbarIds[i])
            sendUpdate = true
        end
    end
    return {sendUpdate, spellbarIds}
end

function InfoUpdate.updateGroupIds(previousGroup, groupIds)
    local selfIncluded = false
    local sendUpdate = false
    for i = 0, 5 do
        if mq.TLO.Group.Member(i).ID() == nil then
            previousGroup[i] = 'Empty'
        end
        if mq.TLO.Group.Member(i).ID() ~= nil then
            previousGroup[i] = mq.TLO.Group.Member(i).ID()
        end
    end
    for i = 1, #previousGroup do
        if groupIds[i] ~= previousGroup[i] then
            sendUpdate = true
            groupIds[i] = previousGroup[i]
        end
        if previousGroup[i] == mq.TLO.Me.ID() then selfIncluded = true end
    end
    if not selfIncluded then
        groupIds[0] = mq.TLO.Me.ID()
    end
    return {sendUpdate, groupIds}
end

function InfoUpdate.updateXTarget(previousXTarget, xtargetList)
    local sendUpdate = false
    for i = 1, mq.TLO.Me.XTargetSlots() do
        if mq.TLO.Me.XTarget(i).ID() == nil or mq.TLO.Me.XTarget(i).ID() == 0 then
            previousXTarget[i] = 'Empty'
        end
        if mq.TLO.Me.XTarget(i).ID() ~= nil and mq.TLO.Me.XTarget(i).ID() ~= 0 then
            previousXTarget[i] = mq.TLO.Me.XTarget(i).ID()
        end
    end
    for i = 1, # previousXTarget do
        if xtargetList[i] ~= previousXTarget[i] then
            sendUpdate = true
            xtargetList[i] = previousXTarget[i]
        end
    end
    return {sendUpdate, xtargetList}
end

function InfoUpdate.UpdateTarget(previousTarget, mimicTargetId, previousTargetBuffs, targetBuffs)
    local sendUpdate = false
    if mq.TLO.Target.ID() == nil or mq.TLO.Target.ID() == 0 then
        previousTarget = 'Empty'
    end
    if mq.TLO.Target.ID() ~= nil and mq.TLO.Target.ID() ~= 0 then
        previousTarget = mq.TLO.Target.ID()
        for i = 1, mq.TLO.Target.BuffCount() do
            if previousTargetBuffs[i] ~= mq.TLO.Target.Buff(i).ID() then
                previousTargetBuffs[i] = mq.TLO.Target.Buff(i).ID()
            elseif mq.TLO.Target.Buff(i).ID() == nil then
                previousTargetBuffs[i] = 0
            end
        end
    end
    if mimicTargetId ~= previousTarget then
        sendUpdate = true
        mimicTargetId = previousTarget
    end
    for i = 1, #previousTargetBuffs do
        if targetBuffs[i] ~= previousTargetBuffs[i] then
            sendUpdate = true
            targetBuffs[i] = previousTargetBuffs[i]
        end
    end
    return {sendUpdate, mimicTargetId, targetBuffs}
end

function InfoUpdate.updatePet(previousPetId, mimicPetId, previousPetCombat, mimicPetCombat, previousPetTarget,
                              mimicPetTarget)
    local sendUpdate = false
    if mq.TLO.Me.Pet() == "NO PET" then
        previousPetId = 'Empty'
        if mimicPetId ~= previousPetId then
            sendUpdate = true
            mimicPetId = 'Empty'
        end
    end
    -- Pet Summoned
    if mq.TLO.Me.Pet() ~= 'NO PET' then
        previousPetId = mq.TLO.Spawn(mq.TLO.Me.Pet()).ID()
        if mimicPetId ~= previousPetId then
            sendUpdate = true
            mimicPetId = previousPetId
        end
        -- in combat
        if mq.TLO.Me.Pet.Combat() ~= mimicPetCombat then
            previousPetCombat = mq.TLO.Me.Pet.Combat()
            if mimicPetCombat ~= previousPetCombat then
                sendUpdate = true
                mimicPetCombat = previousPetCombat
            end
        end
        -- Target
        if mq.TLO.Me.Pet.Target.ID() == 0 or mq.TLO.Me.Pet.Target.Dead() then
            previousPetTarget = 'Empty'
        else
            previousPetTarget = mq.TLO.Me.Pet.Target.ID()
            if mimicPetTarget ~= previousPetTarget then
                sendUpdate = true
                mimicPetTarget = previousPetTarget
            end
        end
    end

    return {sendUpdate, mimicPetId, mimicPetCombat, mimicPetTarget}
end

return InfoUpdate
