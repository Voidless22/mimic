local mq = require('mq')
local actors = require('actors')
local imgui = require('ImGui')
local mimicSpellbar = require('mimicSpellbar')
local mimicGroup = require('mimicGroupWindow')
local mimicXTarget = require('mimicXTargetWindow')
local mimicTarget = require('mimicTargetWindow')
local mimicSettingsWindow = require('mimicSettingsWindow')
local mimicPet = require('mimicPetWindow')
local mimicControlDash = require('mimicControlDash')
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
local ShowMimicSettings = false


Settings = {
    OpenMimicSpellBar = {},
    OpenMimicGroupWindow = {},
    OpenXTargetMimicWindow = {},
    OpenTargetMimicWindow = {},
    OpenMimicPetWindow = {},
    OpenMimicControlDash = {},
    OpenMimicSettings = false
}
MimicName = ""
local window_flags = 0
local no_titlebar = true
local no_scrollbar = true
local no_resize = true
if no_titlebar then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoTitleBar) end
if no_scrollbar then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoScrollbar) end
if no_resize then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoResize) end


local function serializeSettings()
    local needsUpdate = false
    -- initialize your config table
    -- name of config file in config folder
    local path = 'mimicDriverConfig.lua'
    -- attempt to read the config file
    local configData, err = loadfile(mq.configDir .. '/' .. path)
    if err then
        mq.pickle(path, Settings)
    else
        local fileData = configData()
        for settingName, value in pairs(Settings) do
            if type(Settings[settingName]) == 'table' then
                for toonInfo, settingValue in pairs(Settings[settingName]) do
                    if tostring(fileData[settingName][toonInfo]) == tostring(settingValue) then
                        printf('%s Setting is found and set to %s on %s, moving on', settingName, settingValue, toonInfo)
                    else
                        needsUpdate = true
                    end
                end
            end
        end
    end
    if needsUpdate then
        print('saving settings.')
        mq.pickle(path, Settings)
    end
end




DriverActor = actors.register('Driver', function(message)
    if message.content.id == 'greetDriver' then
        mimicCharacters[message.content.charName] = {}
        printf('character added %s', message.content.charName)
        Settings.OpenMimicSpellBar[message.content.charName], ShowMimicSpellBar[message.content.charName] =
            message.content.openSpellbar, message.content.showSpellbar
        Settings.OpenMimicGroupWindow[message.content.charName], ShowMimicGroupWindow[message.content.charName] =
            message.content.openGroupWindow, message.content.showGroupWindow
        Settings.OpenMimicPetWindow[message.content.charName], ShowMimicPetWindow[message.content.charName] =
            message.content.openPetWindow, message.content.showPetWindow
        Settings.OpenTargetMimicWindow[message.content.charName], ShowTargetMimicWindow[message.content.charName] =
            message.content.openTargetWindow, message.content.showTargetWindow
        Settings.OpenXTargetMimicWindow[message.content.charName], ShowXTargetMimicWindow[message.content.charName] =
            message.content.openXTargetWindow, message.content.showXTargetWindow
        Settings.OpenMimicControlDash[message.content.charName], ShowMimicControlDash[message.content.charName] =
            message.content.openMimicControlDash, message.content.showMimicControlDash
        serializeSettings()
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
    end
end)

local function OpenAllInstances(open, show, name, type)
    for charName, value in pairs(open) do
        if open[charName] then
            open[charName], show[charName] = ImGui.Begin(name .. charName, open[charName], window_flags)
            if show[charName] and type == 'Spellbar' then
                mimicSpellbar.DrawSpellbar(charName, mimicCharacters[charName]['Spellbar'])
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

            ImGui.End()
        end
    end
end

local windowList = {
    open = {
        Settings.OpenMimicControlDash,
        Settings.OpenMimicGroupWindow,
        Settings.OpenMimicPetWindow,
        Settings.OpenMimicSpellBar,
        Settings.OpenTargetMimicWindow,
        Settings.OpenXTargetMimicWindow },
    show = {
        ShowMimicControlDash,
        ShowMimicGroupWindow,
        ShowMimicPetWindow,
        ShowMimicSpellBar,
        ShowTargetMimicWindow,
        ShowXTargetMimicWindow
    },
    name = {
        "Control Dash", "Mimic Group", "Mimic Pet", "Mimic Bar", "Mimic Target", "Mimic XTarget"
    },
    type = {
        "Control Dash", "Group", "Pet", "Spellbar", "Target", "XTarget"

    }
}

local function MimicBarLoop()
    OpenAllInstances(Settings.OpenMimicSpellBar, ShowMimicSpellBar, "Mimic Bar", "Spellbar")
    OpenAllInstances(Settings.OpenMimicGroupWindow, ShowMimicGroupWindow, "Mimic Group", "Group")
    OpenAllInstances(Settings.OpenXTargetMimicWindow, ShowXTargetMimicWindow, "Mimic XTarget", 'Xtar')
    OpenAllInstances(Settings.OpenTargetMimicWindow, ShowTargetMimicWindow, "Mimic Target", 'Target')
    OpenAllInstances(Settings.OpenMimicPetWindow, ShowMimicPetWindow, "Mimic Pet", "Pet")
    OpenAllInstances(Settings.OpenMimicControlDash, ShowMimicControlDash, "Control Dash", "Control Dash")
    if Settings.OpenMimicSettings then
        Settings.OpenMimicSettings, Settings.ShowMimicSettings = ImGui.Begin('Settings', Settings.OpenMimicSettings)
        if Settings.ShowMimicSettings then
            mimicSettingsWindow.DrawSettingsWindow()
        end
        ImGui.End()
    end
end



mq.imgui.init('Mimic Bar', MimicBarLoop)




local function main()
    while running do
        mq.delay(100)
    end
end


main()
