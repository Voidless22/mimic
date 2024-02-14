local mq = require('mq')
local ImGui = require('ImGui')

MimicControlDash = {}
local chaseToggle


function MimicControlDash.DrawControlDash(charName, charTable)
    if mq.TLO.Spawn(charName).Sitting() then charTable.mimicSitting = 'Stand' else charTable.mimicSitting = 'Sit' end
    ImGui.SetWindowSize('Control Dash' .. charName, 128, 150)
    -- Settings Button
    ImGui.SetCursorPos(4, 4)
    ImGui.PushStyleColor(ImGuiCol.Text, 255, 255, 255, 255)
    local settingsButton = ImGui.Button("Settings", 60, 20)
    -- Sit Button
    ImGui.SetCursorPos(64, 4)
    local sitButton = ImGui.Button(charTable.mimicSitting, 60, 20)
    ImGui.SetCursorPos(4, 25)
    -- Attack button
    if charTable.meleeTarget then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 255, 0, 255)
    elseif not charTable.meleeTarget then
        ImGui.PushStyleColor(ImGuiCol.Text, 255, 0, 0, 255)
    end
    local attackButton = ImGui.Button("Melee Atack", 120, 20)
    -- Clear Target Button
    ImGui.SetCursorPos(4, 46)
    ImGui.PushStyleColor(ImGuiCol.Text, 255, 255, 255, 255)
    local clearTargetButton = ImGui.Button("Clear Target", 120, 20)
    -- Chase Button
    ImGui.SetCursorPos(4, 68)
    if charTable.chaseToggle then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 255, 0, 255)
    elseif not charTable.chaseToggle then
        ImGui.PushStyleColor(ImGuiCol.Text, 255, 0, 0, 255)
    end
    local chaseToggleButton = ImGui.Button("Chase Assist", 120, 20)
    -- Follow MA Target Button
    ImGui.SetCursorPos(4, 89)
    if charTable.followMATarget then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 255, 0, 255)
    elseif not charTable.followMATarget then
        ImGui.PushStyleColor(ImGuiCol.Text, 255, 0, 0, 255)
    end
    local followTargetButton = ImGui.Button("Mirror Target", 120, 20)
    -- Char Name Footer
    ImGui.PushStyleColor(ImGuiCol.Text, 255, 255, 255, 255)
    ImGui.SetCursorPos(4, 130)
    ImGui.Text("%s's Dash", charName)

    ImGui.PopStyleColor(6)
    if settingsButton then
        OpenMimicSettings = not OpenMimicSettings
    end
    if followTargetButton then
        if charTable.followMATarget == nil then
            charTable.followMATarget = false
        end
        charTable.followMATarget = not charTable.followMATarget
        DriverActor:send({ mailbox = 'mimic', character = charName, script = 'mimic/mimicme' },
            { id = 'updateFollowMATarget', charName = charName, followMATarget = charTable.followMATarget })
    end
    if clearTargetButton then
        DriverActor:send({ mailbox = 'mimic', character = charName, script = 'mimic/mimicme' }, { id = 'clearTarget', charName = charName })
    end
    if attackButton then
        if charTable.meleeTarget == nil then
            charTable.meleeTarget = false
        end
        charTable.meleeTarget = not charTable.meleeTarget
        DriverActor:send({ mailbox = 'mimic', character = charName, script = 'mimic/mimicme' },
            { id = 'updateMeleeTarget', charName = charName, meleeTarget = charTable.meleeTarget })
    end
    if chaseToggleButton then
        if charTable.chaseToggle == nil then
            charTable.chaseToggle = false
        end
        charTable.chaseToggle = not charTable.chaseToggle
        DriverActor:send({ mailbox = 'mimic', character = charName, script = 'mimic/mimicme' },
            { id = 'updateChase', chaseAssist = charTable.chaseToggle })
    end
    if sitButton then
        if mq.TLO.Spawn(charName)() ~= nil then
            if mq.TLO.Spawn(charName).Sitting() then
                charTable.mimicSitting = "Sit"
            elseif not mq.TLO.Spawn(charName).Sitting() then
                charTable.mimicSitting = "Stand"
            end
            DriverActor:send({ mailbox = 'mimic', script = 'mimic/mimicme', character = charName },
                { id = 'switchSitting', charName = charName })
        end
    end
end

return MimicControlDash
