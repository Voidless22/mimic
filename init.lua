local mq = require('mq')
local actors = require('actors')
local ImGui = require('ImGui')
local mimicSpellbar = require('mimicSpellbar')
local mimicGroup = require('mimicGroupWindow')
local mimicXTarget = require('mimicXTargetWindow')
local mimicTarget = require('mimicTargetWindow')
local mimicSettingsWindow = require('mimicSettingsWindow')
local mimicPet = require('mimicPetWindow')
local mimicControlDash = require('mimicControlDash')
local mimicBuffWindow = require('mimicBuffWindow')
local mimicLoadoutWindow = require('mimicLoadoutWindow')
local mimicCharacters = {}


local running = true
local args = { ... }
local isMimicClient

local ShowMimicSpellBar = {}
local ShowMimicGroupWindow = {}
local ShowXTargetMimicWindow = {}
local ShowTargetMimicWindow = {}
local ShowMimicPetWindow = {}
local ShowMimicControlDash = {}
local ShowMimicBuffWindow = {}
local ShowMimicLoadoutWindow = {}
ShowMimicSettings = false
OpenMimicSettings = false

local mimicDriver = true


Settings = {
    OpenMimicSpellBar = {},
    OpenMimicGroupWindow = {},
    OpenXTargetMimicWindow = {},
    OpenTargetMimicWindow = {},
    OpenMimicPetWindow = {},
    OpenMimicControlDash = {},
    OpenMimicBuffWindow = {},
    OpenMimicLoadoutWindow = {}
}

local window_flags = 0
local no_titlebar = true
local no_scrollbar = true
local no_resize = true
if no_titlebar then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoTitleBar) end
if no_scrollbar then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoScrollbar) end
if no_resize then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoResize) end



local function prepSettings()
    local nameFound = false
    for name, data in pairs(mimicCharacters) do
        for settingName, value in pairs(Settings) do
            for toonName, settingValue in pairs(Settings[settingName]) do
                if toonName == mimicCharacters[name] then nameFound = true end
            end
            if not nameFound then
                Settings[settingName][name] = true
            else
                nameFound = false
            end
        end
    end
end

MimicCasting = {}

DriverActor = actors.register('Driver', function(message)
    if message.content.id == 'greetDriver' then
        mimicCharacters[message.content.charName] = {
            ['Spellbar'] = {},
            ['groupIds'] = {},
            ['xtargetList'] = {},
            ['mimicTargetId'] = 0,
            ['isCasting'] = nil,
            ['currentBuffs'] = {},
            ['meleeTarget'] = '',
         
        }
        printf('character added %s', message.content.charName)
        local settingsFile, err = loadfile(mq.configDir .. '/' .. 'mimicSettings.lua')
        if err then
            local temp
            for settingName, value in pairs(Settings) do
                if Settings[settingName][message.content.charName] == nil then
                    Settings[settingName][message.content.charName] = true
                    mq.pickle('mimicSettings.lua', Settings)
                end
            end
        elseif settingsFile then
            local fileData = settingsFile()
            for settingName, value in pairs(Settings) do
                if fileData[settingName][message.content.charName] == nil then
                    Settings[settingName][message.content.charName] = true
                    mq.pickle('mimicSettings.lua', Settings)
                else
                    Settings[settingName][message.content.charName] = fileData[settingName][message.content.charName]
                end
            end
        end
        Settings['OpenMimicLoadoutWindow'][message.content.charName] = message.content.openLoadoutOnLaunch
        mimicCharacters[message.content.charName]['isCasting'] = message.content.isCasting
    elseif message.content.id == 'updateSpellbar' then
        mimicCharacters[message.content.charName]['Spellbar'] = message.content.spellbar
    elseif message.content.id == 'updateGroup' then
        mimicCharacters[message.content.charName]['groupIds'] = message.content.groupIds
    elseif message.content.id == 'updateXTarget' then
        mimicCharacters[message.content.charName]['xtargetList'] = message.content.xtarget
    elseif message.content.id == 'updateTarget' then
        mimicCharacters[message.content.charName]['mimicTargetId'] = message.content.target
        mimicCharacters[message.content.charName]['targetBuffs'] = message.content.targetBuffs
    elseif message.content.id == 'petUpdate' then
        mimicCharacters[message.content.charName].mimicPetTarget = message.content.petTarget
        mimicCharacters[message.content.charName].mimicPetId = message.content.petId
        mimicCharacters[message.content.charName].mimicPetCombat = message.content.inCombat
        mimicCharacters[message.content.charName].petMode = message.content.petMode
    elseif message.content.id == 'castingTimeUpdate' then
        mimicCharacters[message.content.charName]['isCasting'] = message.content.isCasting
    elseif message.content.id == 'updateBuffs' then
        mimicCharacters[message.content.charName]['currentBuffs'] = message.content.mimicBuffs
    elseif message.content.id == 'updateMeleeTarget' then
        mimicCharacters[message.content.charName]['meleeTarget'] = message.content.meleeTarget
    elseif message.content.id == 'updateSpellTable' then

        mimicCharacters[message.content.charName].spellTable = message.content.spellTable
        for _, category in ipairs( mimicCharacters[message.content.charName].spellTable['categories']) do
            for _, subcategory in ipairs( mimicCharacters[message.content.charName].spellTable[category]['subcategories']) do
                for _, spell in ipairs( mimicCharacters[message.content.charName].spellTable[category][subcategory]) do
                    printf(' %s: Spell: %s Level: %i in Category: %s under Subcategory: %s', mq.TLO.Me.Name(), spell[2],
                        spell[1], category, subcategory)
                end
            end
        end

    end
end)

local typeHandlers = {
    Spellbar = mimicSpellbar.DrawSpellbar,
    Group = mimicGroup.DrawMimicGroupWindow,
    Xtar = mimicXTarget.DrawMimicXTargetWindow,
    Target = mimicTarget.DrawMimicTargetWindow,
    Pet = mimicPet.DrawPetWindow,
    ["Control Dash"] = mimicControlDash.DrawControlDash,
    Buffs = mimicBuffWindow.DrawMimicBuffWindow,
    Loadout = mimicLoadoutWindow.DrawMimicLoadoutWindow
}

local function OpenAllInstances(open, show, name, type, windowflags)
    for charName, isOpen in pairs(open) do
        if open[charName] then
            open[charName], show[charName] = ImGui.Begin(name .. charName, show[charName], windowflags)
            if show[charName] then
                local handler = typeHandlers[type]
                if handler then
                    handler(charName, mimicCharacters[charName])
                end
            end
            ImGui.End()
        end
    end
end

 
local function MimicBarLoop()
    OpenAllInstances(Settings.OpenMimicSpellBar, ShowMimicSpellBar, "Mimic Bar", "Spellbar", window_flags)
    OpenAllInstances(Settings.OpenMimicGroupWindow, ShowMimicGroupWindow, "Mimic Group", "Group", window_flags)
    OpenAllInstances(Settings.OpenXTargetMimicWindow, ShowXTargetMimicWindow, "Mimic XTarget", 'Xtar', window_flags)
    OpenAllInstances(Settings.OpenTargetMimicWindow, ShowTargetMimicWindow, "Mimic Target", 'Target', window_flags)
    OpenAllInstances(Settings.OpenMimicPetWindow, ShowMimicPetWindow, "Mimic Pet", "Pet", window_flags)
    OpenAllInstances(Settings.OpenMimicControlDash, ShowMimicControlDash, "Control Dash", "Control Dash", window_flags)
    OpenAllInstances(Settings.OpenMimicBuffWindow, ShowMimicBuffWindow, "Mimic Buffs", "Buffs",
        bit32.bor(ImGuiWindowFlags.NoTitleBar))
    OpenAllInstances(Settings.OpenMimicLoadoutWindow, ShowMimicLoadoutWindow, "Loadout", "Loadout", window_flags)

    if OpenMimicSettings then
        OpenMimicSettings, ShowMimicSettings = ImGui.Begin('Settings', OpenMimicSettings)
        if ShowMimicSettings then
            mimicSettingsWindow.DrawSettingsWindow()
        end
        ImGui.End()
    end
end



mq.imgui.init('Mimic Bar', MimicBarLoop)




local function main()
    while running do
        if mimicDriver then
            
        end
        mq.delay(10)
    end
end


main()
