local mq = require('mq')
local ImGui = require('ImGui')

MimicControlDash = {}
local chaseToggle


function MimicControlDash.DrawControlDash(charName, charTable)
    if mq.TLO.Spawn(charName).Sitting() then charTable.mimicSitting = 'Stand' else charTable.mimicSitting = 'Sit' end
    ImGui.SetWindowSize('Control Dash' .. charName, 128, 100)
    ImGui.SetCursorPos(4, 4)
    local settingsButton = ImGui.Button("Settings", 60, 20)
    ImGui.SetCursorPos(64, 4)
    local sitButton = ImGui.Button(charTable.mimicSitting, 60, 20)
    ImGui.SetCursorPos(4, 25)
    local chaseCheckbox, chaseToggleClicked = ImGui.Checkbox("Chase Assist", charTable.chaseToggle)
    ImGui.SetCursorPos(4, ImGui.GetCursorPosY())
    local followTargetToggle, followTargetClicked = ImGui.Checkbox("Mirror Target", charTable.followMATarget)
    ImGui.SetCursorPos(4, 80)
    ImGui.Text("%s's Dash", charName)

    if settingsButton then
        Settings.OpenMimicSettings = not Settings.OpenMimicSettings
        end

    if followTargetClicked then
        if charTable.followMATarget == nil then
            charTable.followMATarget = false
        end
        charTable.followMATarget = not charTable.followMATarget
        DriverActor:send({ mailbox = 'mimic', character = charName, script = 'mimic/mimicme' },
            { id = 'updateFollowMATarget', followMATarget = charTable.followMATarget })
    end
    if chaseToggleClicked then
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
