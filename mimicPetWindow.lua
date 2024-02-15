local mq = require('mq')
local ImGui = require('ImGui')

MimicPetWindow = {}
MimicPetWindow.previousPetId = 'Empty'
MimicPetWindow.previousPetTarget = 'Empty'
MimicPetWindow.previousPetCombat = false

MimicPetWindow.mimicPetId = 'Empty'
MimicPetWindow.mimicPetTarget = 'Empty'
MimicPetWindow.mimicPetCombat = false
MimicPetWindow.tauntToggle = false
MimicPetWindow.petMode = "Follow"
MimicPetWindow.petGuardToggle = false



function MimicPetWindow.DrawPetWindow(charName, charTable)
   
    local petHPRatio
    local targetHPRatio
    ImGui.SetWindowSize("Mimic Pet"..charName, 150, 180)
    ImGui.SetCursorPos(4, 5)
    if charTable.mimicPetId ~= 'Empty' and mq.TLO.Spawn(charName).Pet() ~= "NO PET" and charTable.mimicPetId ~= nil and mq.TLO.Spawn(charName).Pet() ~= nil then
        petHPRatio = mq.TLO.Spawn(charName).Pet.PctHPs() / 100 or 0
        ImGui.Text(mq.TLO.Spawn(charName).Pet.CleanName())
        ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
        ImGui.ProgressBar(petHPRatio, -1, 15)
    end
    local targetCursorPos = ImGui.GetCursorPosVec()
    if charTable.mimicPetCombat == true and charTable.mimicPetTarget ~= 'Empty' and mq.TLO.Spawn(charTable.mimicPetTarget)() ~= nil and not mq.TLO.Spawn(charTable.mimicPetTarget).Dead() then
        ImGui.SetCursorPos(targetCursorPos)
        targetHPRatio = mq.TLO.Spawn(charTable.mimicPetTarget).PctHPs() / 100 or 0
        ImGui.SetCursorPos(4, ImGui.GetCursorPos() + 40)
        ImGui.Text(mq.TLO.Spawn(charTable.mimicPetTarget).DisplayName())
        ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
        ImGui.ProgressBar(targetHPRatio, -1, 15)
    end
    ImGui.SetCursorPos(6, 100)
    local attackButton = ImGui.Button("Attack", 64, 32)
    ImGui.SetCursorPos(76, 100)
    local backOffButton = ImGui.Button("Back Off", 64, 32)
    ImGui.SetCursorPos(6, 143)
    if charTable.tauntToggle then
        ImGui.PushStyleColor(ImGuiCol.Text, 0, 255, 0, 255)
    elseif not charTable.tauntToggle then
        ImGui.PushStyleColor(ImGuiCol.Text, 255, 0, 0, 255)
    end
    local tauntButton = ImGui.Button("Taunt", 64, 32)
    ImGui.PopStyleColor(1)
    ImGui.SetCursorPos(76, 143)
    if charTable.petMode == nil then
        charTable.petMode = 'Follow'
    end
    local petModeButton = ImGui.Button(charTable.petMode, 64, 32)

    -- local petModeCheckbox, petModeCheckboxClicked = ImGui.Checkbox(petMode,petGuardToggle)
    if petModeButton then
        if charTable.petMode == "Follow" then
            charTable.petMode = "Guard"
        elseif charTable.petMode == "Guard" then
            charTable.petMode = "Follow"
        end
        DriverActor:send({mailbox='mimic', script='mimic/mimicme',character=charName}, {id = 'petModeUpdate', charName = charName, mode=charTable.petMode})


    end
    if tauntButton then
        charTable.tauntToggle = not charTable.tauntToggle
        DriverActor:send({mailbox='mimic', script='mimic/mimicme', character=charName}, {id = 'petTauntUpdate', charName = charName, taunt=charTable.tauntToggle})
    end

    if attackButton then
        DriverActor:send({mailbox='mimic', script='mimic/mimicme', character=charName}, {id='petAttack', charName = charName})
    end
    if backOffButton then
        DriverActor:send({mailbox='mimic', script='mimic/mimicme', character=charName},{id='petBackOff',charName = charName})
    end
end

return MimicPetWindow
