local mq = require('mq')
local actors = require('actors')
local imgui = require('ImGui')
local mimicSpellbar = require('mimicSpellbar')
local mimicGroup = require('mimicGroupWindow')
local mimicXTarget = require('mimicXTargetWindow')
local mimicTarget = require('mimicTargetWindow')
local mimicConfigWindow = require('mimicConfigWindow')
local mimicPet = require('mimicPetWindow')
local mimicControlDash = require('mimicControlDash')
local mimicCharacters = {}


local running = true
local args = { ... }
local isMimicClient
local OpenMimicSpellBar, ShowMimicSpellBar = {}, {}
local OpenMimicGroupWindow, ShowMimicGroupWindow = {}, {}
local OpenXTargetMimicWindow, ShowXTargetMimicWindow = {}, {}
local OpenTargetMimicWindow, ShowTargetMimicWindow = {}, {}
local OpenMimicPetWindow, ShowMimicPetWindow = {}, {}
local OpenMimicControlDash, ShowMimicControlDash = {}, {}
local OpenMimicSettings, ShowMimicSettings = {}, {}

MimicName = ""
local window_flags = 0
local no_titlebar = true
local no_scrollbar = true
local no_resize = true
if no_titlebar then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoTitleBar) end
if no_scrollbar then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoScrollbar) end
if no_resize then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoResize) end





DriverActor = actors.register('Driver', function(message)
    if message.content.id == 'greetDriver' then
        mimicCharacters[message.content.charName] = {}
        printf('character added %s', message.content.charName)
        OpenMimicSpellBar[message.content.charName], ShowMimicSpellBar[message.content.charName] =
            message.content.openSpellbar, message.content.showSpellbar
        OpenMimicGroupWindow[message.content.charName], ShowMimicGroupWindow[message.content.charName] =
            message.content.openGroupWindow, message.content.showGroupWindow
        OpenMimicPetWindow[message.content.charName], ShowMimicPetWindow[message.content.charName] =
            message.content.openPetWindow, message.content.showPetWindow
        OpenTargetMimicWindow[message.content.charName], ShowTargetMimicWindow[message.content.charName] =
            message.content.openTargetWindow, message.content.showTargetWindow
        OpenXTargetMimicWindow[message.content.charName], ShowXTargetMimicWindow[message.content.charName] =
            message.content.openXTargetWindow, message.content.showXTargetWindow
        OpenMimicControlDash[message.content.charName], ShowMimicControlDash[message.content.charName] =
            message.content.openMimicControlDash, message.content.showMimicControlDash

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
    for index, value in pairs(open) do
        if open[index] then
            open[index], show[index] = ImGui.Begin(name .. index,
                open[index], window_flags)
            if show[index] and type == 'Spellbar' then
                mimicSpellbar.DrawSpellbar(index, mimicCharacters[index]['Spellbar'])
            end
            if show[index] and type == 'Group' then
                mimicGroup.DrawMimicGroupWindow(index, mimicCharacters[index])
            end
            if show[index] and type == 'Xtar' then
                mimicXTarget.DrawMimicXTargetWindow(index, mimicCharacters[index])
            end
            if show[index] and type == 'Target' then
                mimicTarget.DrawMimicTargetWindow(index, mimicCharacters[index])
            end
            if show[index] and type == 'Pet' then
                mimicPet.DrawPetWindow(index, mimicCharacters[index])
            end
            if show[index] and type == 'Control Dash' then
                mimicControlDash.DrawControlDash(index, mimicCharacters[index])
            end
            if show[index] and type == 'Settings' then
                MimicConfigWindow.DrawConfigWindow(index,mimicCharacters[index])
            end
            ImGui.End()
        end
    end
end


local function MimicBarLoop()
    OpenAllInstances(OpenMimicSpellBar, ShowMimicSpellBar, "Mimic Bar", "Spellbar")
    OpenAllInstances(OpenMimicGroupWindow, ShowMimicGroupWindow, "Mimic Group", "Group")
    OpenAllInstances(OpenXTargetMimicWindow, ShowXTargetMimicWindow, "Mimic XTarget", 'Xtar')
    OpenAllInstances(OpenTargetMimicWindow, ShowTargetMimicWindow, "Mimic Target", 'Target')
    OpenAllInstances(OpenMimicPetWindow, ShowMimicPetWindow, "Mimic Pet", "Pet")
    OpenAllInstances(OpenMimicControlDash, ShowMimicControlDash, "Control Dash", "Control Dash")
    OpenAllInstances(OpenMimicSettings, ShowMimicSettings, "Mimic Config", "Settings")
end


mq.imgui.init('Mimic Bar', MimicBarLoop)


local function main()

    while running do
        mq.delay(100)
    end
end


main()
