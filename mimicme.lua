local mq = require('mq')
local ImGui = require('ImGui')
local actors = require('actors')
local mimicSpellbar = require('mimicSpellbar')
local mimicGroup = require('mimicGroupWindow')
local mimicXTarget = require('mimicXTargetWindow')
local mimicTarget = require('mimicTargetWindow')
local mimicPet = require('mimicPetWindow')
local mimicControlDash = require('mimicControlDash')
local infoUpdate = require('infoUpdate')
local running = true


local UIToggles = {
    ['openGroupWindow'] = true,
    ['showGroupWindow'] = true,
    ['openPetWindow'] = true,
    ['showPetWindow'] = true,
    ['openTargetWindow'] = true,
    ['showTargetWindow'] = true,
    ['openXTargetWindow'] = true,
    ['showXTargetWindow'] = true,
    ['openSpellbar'] = true,
    ['showSpellbar'] = true,
    ['openMimicControlDash'] = true,
    ['showMimicControlDash'] = true,
    ['showMimicSettings'] = false,
    ['openMimicSettings'] = false
}



local followMATarget = false
local chaseToggle = false
local groupIds = {}
local mimicSitting = "Sit"
local previousGroup = { 'Empty', 'Empty', 'Empty', 'Empty', 'Empty', 'Empty', }
local previousMimicBuffs = {}
local previousMimicBuffDurations = {}
local previousSpellbar = {}

local xtargetList = {}
local previousXTarget = {}

local groupIds = {}
local spellbarIds = {}
local xtargetIds = {}
local mimicTargetId = {}
local mimicBuffs = {}
local mimicBuffDurations = {}
local previousTargetBuffs = {}
local targetBuffs = {}

local mimicTargetId = 'Empty'
local previousTarget = 'Empty'

local previousPetId = 'Empty'
local previousPetTarget = 'Empty'
local previousPetCombat = false

local mimicPetId = 'Empty'
local mimicPetTarget = 'Empty'
local mimicPetCombat = false
local tauntToggle = false
local petGuardToggle = false

local meleeTarget = false

local previousSpellTable = { categories = {} }
local currentSpellTable = { categories = {} }

local mimicActor = actors.register('mimic', function(message)
    -- Chase Message
    if message.content.id == 'updateChase' then
        chaseToggle = message.content.chaseAssist
        -- MA Target Message
    elseif message.content.id == 'updateFollowMATarget' then
        followMATarget = message.content.followMATarget
        -- Spell Cast Message
    elseif message.content.id == 'castSpell' and message.content.charName == mq.TLO.Me.Name() then
        mq.cmdf('/cast %i', message.content.gem)
        -- new Target Message
    elseif message.content.id == 'newTarget' and message.content.charName == mq.TLO.Me.Name() then
        mq.cmdf('/target %s', message.content.targetId)
        -- Pet Mode Message
    elseif message.content.id == 'petModeUpdate' and message.content.charName == mq.TLO.Me.Name() then
        if message.content.mode == 'Follow' then mq.cmd('/pet guard') end
        if message.content.mode == 'Guard' then mq.cmd('/pet Follow') end
        -- Pet Taunt Message
    elseif message.content.id == 'petTauntUpdate' and message.content.charName == mq.TLO.Me.Name() then
        if message.content.taunt == true then mq.cmd('/pet taunt on') end
        if message.content.taunt == false then mq.cmd('/pet taunt off') end
        -- Pet Attack Message
    elseif message.content.id == 'petAttack' and message.content.charName == mq.TLO.Me.Name() then
        mq.cmd('/pet attack')
        -- Pet Back off Message
    elseif message.content.id == 'petBackOff' and message.content.charName == mq.TLO.Me.Name() then
        mq.cmd('/pet stop')
        mq.cmd('/pet back')
        -- Sit Toggle Message
    elseif message.content.id == 'switchSitting' and message.content.charName == mq.TLO.Me.Name() then
        if mq.TLO.Me.Sitting() then
            mq.cmd('/stand')
        elseif not mq.TLO.Me.Sitting() then
            mq.cmd('/sit')
        end
        -- Attack Button Message
    elseif message.content.id == 'updateMeleeTarget' and message.content.charName == mq.TLO.Me.Name() then
        meleeTarget = message.content.meleeTarget
        -- Clear Target message
    elseif message.content.id == 'clearTarget' and message.content.charName == mq.TLO.Me.Name() then
        print("clearing Target")
        mq.cmd('/target clear')
    elseif message.content.id == 'updateSpellbar' and message.content.charName == mq.TLO.Me.Name() then
        print(message.content.gem, message.content.spellId)
        mq.cmdf('/memspell %i "%s"', message.content.gem, message.content.spellId)
    end
end)



local function meleeRoutine()
    if mq.TLO.Target() ~= nil and mq.TLO.Target.ID() ~= mq.TLO.Me.ID() then
        mq.cmd('/attack on')
        if mq.TLO.Target.Distance() > mq.TLO.Target.MaxRangeTo() then
            mq.cmd('/nav target')
            while mq.TLO.Navigation.Active() do mq.delay(10) end
        end

        mq.cmd('/face')
        mq.delay(100)
    end
end
local function greetDriver()
    mimicActor:send({ mailbox = 'Driver', script = 'mimic' },
        {
            id = 'greetDriver',
            charName = mq.TLO.Me.Name(),
            isCasting = mq.TLO.Me.Casting(),
            openLoadoutOnLaunch = false
        })
end


local function mirrorTarget()
    if mq.TLO.Group.MainAssist.ID() ~= nil and not (mq.TLO.Group.MainAssist.OtherZone() or mq.TLO.Group.MainAssist.Offline() or mq.TLO.Group.MainAssist.Name() == mq.TLO.Me.Name()) then
        if mq.TLO.Target.ID() ~= mq.TLO.Me.GroupAssistTarget.ID() then
            mq.TLO.Me.GroupAssistTarget.DoTarget()
        end
    end
end

local function doChase()
    if mq.TLO.Group.MainAssist.ID() ~= nil and not (mq.TLO.Group.MainAssist.OtherZone() or mq.TLO.Group.MainAssist.Offline() or mq.TLO.Group.MainAssist() == mq.TLO.Me.Name())
    then
        if not (mq.TLO.Group.MainAssist.OtherZone() or mq.TLO.Group.MainAssist.Offline() or mq.TLO.Group.MainAssist() == mq.TLO.Me.Name()) and
            mq.TLO.Group.MainAssist.Distance() > 20 and not mq.TLO.Me.Casting() and not meleeTarget then
            mq.cmdf("/squelch /nav id %i", mq.TLO.Group.MainAssist.ID())
            while mq.TLO.Navigation.Active() do
                mq.delay(50)
            end
        end
    end
end
local SpellSorter = function(a, b)
    if a[1] < b[1] then
        return false
    elseif b[1] < a[1] then
        return true
    else
        return false
    end
end

local function buildSpellTable()
    local sendUpdate = false
    for i = 1, 720 do
        if mq.TLO.Me.Book(i).ID() ~= nil then
            local spellID = mq.TLO.Me.Book(i).ID()
            local spellCategory = mq.TLO.Spell(spellID).Category()
            local spellSubcategory = mq.TLO.Spell(spellID).Subcategory()
            if not previousSpellTable[spellCategory] then
                previousSpellTable[spellCategory] = { subcategories = {} }
                table.insert(previousSpellTable.categories, spellCategory)
            end
            if not previousSpellTable[spellCategory][spellSubcategory] then
                previousSpellTable[spellCategory][spellSubcategory] = {}
                table.insert(previousSpellTable[spellCategory].subcategories, spellSubcategory)
            end
            table.insert(previousSpellTable[spellCategory][spellSubcategory],
                { mq.TLO.Spell(spellID).Level(), mq.TLO.Spell(spellID).Name() })
            sendUpdate = true
        end
    end
    if sendUpdate then
        table.sort(previousSpellTable.categories)
        for category, subcategories in pairs(previousSpellTable) do
            if category ~= 'categories' then
                table.sort(previousSpellTable[category].subcategories)
                for subcategory, subcatspells in pairs(subcategories) do
                    if subcategory ~= 'subcategories' then
                        table.sort(subcatspells, SpellSorter)
                    end
                end
            end
        end

        for _, category in ipairs(previousSpellTable['categories']) do
            for _, subcategory in ipairs(previousSpellTable[category]['subcategories']) do
                for _, spell in ipairs(previousSpellTable[category][subcategory]) do
                    printf(' %s: Spell: %s Level: %i in Category: %s under Subcategory: %s', mq.TLO.Me.Name(), spell[2],
                        spell[1], category, subcategory)
                end
            end
        end
        mimicActor:send({ mailbox = 'Driver', script = 'mimic' },
            { id = 'updateSpellTable', charName = mq.TLO.Me.Name(), spellTable = previousSpellTable })
    end
end

local function initMimic()
    greetDriver()
    if InfoUpdate.updateSpellbar(previousSpellbar, spellbarIds)[1] then
        spellbarIds = InfoUpdate.updateSpellbar(previousSpellbar, spellbarIds)[2]
        mimicActor:send({ mailbox = 'Driver', script = 'mimic' },
            { id = 'updateSpellbar', charName = mq.TLO.Me.Name(), spellbar = spellbarIds })
    end
    if InfoUpdate.updateBuffs(previousMimicBuffs, mimicBuffs)[1] then
        print('sending buffs')
        mimicBuffs = InfoUpdate.updateBuffs(previousMimicBuffs, mimicBuffs)[2]
        mimicActor:send({ mailbox = "Driver", script = 'mimic' },
            {
                id = 'updateBuffs',
                charName = mq.TLO.Me.Name(),
                mimicBuffs = mimicBuffs
            })
    end
    if InfoUpdate.updateGroupIds(previousGroup, groupIds)[1] then
        groupIds = InfoUpdate.updateGroupIds(previousGroup, groupIds)[2]
        mimicActor:send({ mailbox = 'Driver', script = 'mimic' },
            { id = 'updateGroup', charName = mq.TLO.Me.Name(), groupIds = groupIds })
    end
    if InfoUpdate.updateXTarget(previousXTarget, xtargetList)[1] then
        xtargetList = InfoUpdate.updateXTarget(previousXTarget, xtargetList)[2]
        mimicActor:send({ mailbox = 'Driver', script = 'mimic' },
            { id = 'updateXTarget', charName = mq.TLO.Me.Name(), xtarget = xtargetList })
    end
    if InfoUpdate.UpdateTarget(previousTarget, mimicTargetId, previousTargetBuffs, targetBuffs)[1] then
        mimicTargetId = InfoUpdate.UpdateTarget(previousTarget, mimicTargetId, previousTargetBuffs, targetBuffs)[2]
        targetBuffs = InfoUpdate.UpdateTarget(previousTarget, mimicTargetId, previousTargetBuffs, targetBuffs)[3]

        mimicActor:send({ mailbox = 'Driver', script = 'mimic' },
            { id = 'updateTarget', charName = mq.TLO.Me.Name(), target = mimicTargetId, targetBuffs = targetBuffs })
    end
    buildSpellTable()
    if chaseToggle == true then doChase() end
    if followMATarget == true then mirrorTarget() end
end

local function isMimicCasting()
    if mq.TLO.Me.Casting() then
        while mq.TLO.Me.Casting() do
            mimicActor:send({ mailbox = 'Driver', script = 'mimic' },
                { id = 'castingTimeUpdate', charName = mq.TLO.Me.Name(), isCasting = mq.TLO.Me.Casting() })
            mq.delay(10)
        end
    end
    mimicActor:send({ mailbox = 'Driver', script = 'mimic' },
        { id = 'castingTimeUpdate', charName = mq.TLO.Me.Name(), isCasting = mq.TLO.Me.Casting() })
end


local function meleeHandler()
    if meleeTarget then
        if mq.TLO.Target.ID() == 0 or mq.TLO.Target.Dead() then
            meleeTarget = false
            mimicActor:send({ mailbox = 'Driver', script = 'mimic' },
                { id = 'updateMeleeTarget', charName = mq.TLO.Me.Name(), meleeTarget = meleeTarget })
            mq.cmd('/attack off')
        else
            meleeRoutine()
        end
    end
    if mq.TLO.Me.Combat() and not meleeTarget then
        mq.cmd('/attack off')
    end
end

local function main()
    while running == true do
        if chaseToggle == true then doChase() end
        if followMATarget then mirrorTarget() end
        --  buildSpellTable()
        isMimicCasting()
        meleeHandler()
        if InfoUpdate.updateSpellbar(previousSpellbar, spellbarIds)[1] then
            spellbarIds = InfoUpdate.updateSpellbar(previousSpellbar, spellbarIds)[2]
            mimicActor:send({ mailbox = 'Driver', script = 'mimic' },
                { id = 'updateSpellbar', charName = mq.TLO.Me.Name(), spellbar = spellbarIds })
        end
        if InfoUpdate.updateBuffs(previousMimicBuffs, mimicBuffs)[1] then
            print('sending buffs')
            mimicBuffs = InfoUpdate.updateBuffs(previousMimicBuffs, mimicBuffs)[2]
            mimicActor:send({ mailbox = "Driver", script = 'mimic' },
                {
                    id = 'updateBuffs',
                    charName = mq.TLO.Me.Name(),
                    mimicBuffs = mimicBuffs
                })
        end
        if InfoUpdate.updateGroupIds(previousGroup, groupIds)[1] then
            groupIds = InfoUpdate.updateGroupIds(previousGroup, groupIds)[2]
            mimicActor:send({ mailbox = 'Driver', script = 'mimic' },
                { id = 'updateGroup', charName = mq.TLO.Me.Name(), groupIds = groupIds })
        end
        if InfoUpdate.updateXTarget(previousXTarget, xtargetList)[1] then
            xtargetList = InfoUpdate.updateXTarget(previousXTarget, xtargetList)[2]
            mimicActor:send({ mailbox = 'Driver', script = 'mimic' },
                { id = 'updateXTarget', charName = mq.TLO.Me.Name(), xtarget = xtargetList })
        end
        if InfoUpdate.UpdateTarget(previousTarget, mimicTargetId, previousTargetBuffs, targetBuffs)[1] then
            mimicTargetId = InfoUpdate.UpdateTarget(previousTarget, mimicTargetId, previousTargetBuffs, targetBuffs)[2]
            targetBuffs = InfoUpdate.UpdateTarget(previousTarget, mimicTargetId, previousTargetBuffs, targetBuffs)[3]

            mimicActor:send({ mailbox = 'Driver', script = 'mimic' },
                { id = 'updateTarget', charName = mq.TLO.Me.Name(), target = mimicTargetId, targetBuffs = targetBuffs })
        end
    end
    if InfoUpdate.updatePet(previousPetId, mimicPetId, previousPetCombat, mimicPetCombat, previousPetTarget, mimicPetTarget)[1] then
        mimicPetId = InfoUpdate.updatePet(previousPetId, mimicPetId, previousPetCombat, mimicPetCombat, previousPetTarget,
            mimicPetTarget)[2]
        mimicPetCombat = InfoUpdate.updatePet(previousPetId, mimicPetId, previousPetCombat, mimicPetCombat,
            previousPetTarget, mimicPetTarget)[3]
        mimicPetTarget = InfoUpdate.updatePet(previousPetId, mimicPetId, previousPetCombat, mimicPetCombat,
            previousPetTarget, mimicPetTarget)[4]
        mimicActor:send({ mailbox = 'Driver', script = 'mimic',
        }, {
            id = 'petUpdate',
            charName = mq.TLO.Me.Name(),
            inCombat = mimicPetCombat,
            petTarget = mimicPetTarget,
            petId = mimicPetId,
        })
    end
    mq.delay(10)
end



initMimic()
main()
