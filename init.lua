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
ShowMimicSettings = false
OpenMimicSettings = false




Settings = {
    OpenMimicSpellBar = {},
    OpenMimicGroupWindow = {},
    OpenXTargetMimicWindow = {},
    OpenTargetMimicWindow = {},
    OpenMimicPetWindow = {},
    OpenMimicControlDash = {},
    OpenMimicBuffWindow = {}
}

MimicName = ""
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
        mimicCharacters[message.content.charName] = {}
        printf('character added %s', message.content.charName)
        local settingsFile, err = loadfile(mq.configDir .. '/' .. 'mimicSettings.lua')
        if err then
            prepSettings()
            mq.pickle('mimicSettings.lua', Settings)
        elseif settingsFile then
            local fileData = settingsFile()

            for settingName, value in pairs(fileData) do
                for toonName, settingValue in pairs(fileData[settingName]) do
                    if Settings[settingName][message.content.charName] ~= fileData[settingName][message.content.charName] then
                        Settings[settingName][message.content.charName] = settingValue
                        printf("Updated Setting: %s for Character: %s to value %s", settingName, toonName,
                            settingValue)
                    end
                end
            end
        end
        if message.content.isCasting == nil then
            mimicCharacters[message.content.charName]['isCasting'] = nil
        else
            mimicCharacters[message.content.charName]['isCasting'] = message.content.isCasting
        end
    elseif message.content.id == 'updateSpellbar' then
        mimicCharacters[message.content.charName]['Spellbar'] = message.content.spellbar
    elseif message.content.id == 'updateGroup' then
        mimicCharacters[message.content.charName]['groupIds'] = message.content.groupIds
    elseif message.content.id == 'updateXTarget' then
        mimicCharacters[message.content.charName]['xtargetList'] = message.content.xtarget
    elseif message.content.id == 'updateTarget' then
        mimicCharacters[message.content.charName]['mimicTargetId'] = message.content.target
    elseif message.content.id == 'petUpdate' then
        mimicCharacters[message.content.charName].mimicPetTarget = message.content.petTarget
        mimicCharacters[message.content.charName].mimicPetId = message.content.petId
        mimicCharacters[message.content.charName].mimicPetCombat = message.content.inCombat
        mimicCharacters[message.content.charName].petMode = message.content.petMode
    elseif message.content.id == 'castingTimeUpdate' then
        if message.content.isCasting ~= nil then
            mimicCharacters[message.content.charName]['isCasting'] = message.content.isCasting
        else
            mimicCharacters[message.content.charName]['isCasting'] = nil
        end
    elseif message.content.id == 'updateBuffs' then
        mimicCharacters[message.content.charName]['currentBuffs'] = message.content.mimicBuffs
    elseif message.content.id == 'updateMeleeTarget' then
        mimicCharacters[message.content.charName]['meleeTarget'] = message.content.meleeTarget
    end
end)

local function OpenAllInstances(open, show, name, type, windowflags)
    for charName, value in pairs(open) do
        if open[charName] then
            open[charName], show[charName] = ImGui.Begin(name .. charName, open[charName], windowflags)
            if show[charName] and type == 'Spellbar' then
                mimicSpellbar.DrawSpellbar(charName, mimicCharacters[charName])
            end
            if show[charName] and type == 'Group' then
                mimicGroup.DrawMimicGroupWindow(charName, mimicCharacters[charName])
            end
            if show[charName] and type == 'Xtar' then
                mimicXTarget.DrawMimicXTargetWindow(charName, mimicCharacters[charName])
            end
            if show[charName] and type == 'Target' then
                mimicTarget.DrawMimicTargetWindow(charName, mimicCharacters[charName])
            end
            if show[charName] and type == 'Pet' then
                mimicPet.DrawPetWindow(charName, mimicCharacters[charName])
            end
            if show[charName] and type == 'Control Dash' then
                mimicControlDash.DrawControlDash(charName, mimicCharacters[charName])
            end
            if show[charName] and type == 'Buffs' then
                mimicBuffWindow.DrawMimicBuffWindow(charName, mimicCharacters[charName])
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
        mq.delay(10)
    end
end


main()
