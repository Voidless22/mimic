local mq = require('mq')
local ImGui = require('ImGui')


MimicGroupWindow = {}
MimicGroupWindow.followMATarget = false
MimicGroupWindow.chaseToggle = false
MimicGroupWindow.mimicSitting = "Sit"
MimicGroupWindow.previousGroup = { 'Empty', 'Empty', 'Empty', 'Empty', 'Empty', 'Empty', }

function MimicGroupWindow.DrawMimicGroupWindow(charName, charTable)
    local GrpHPRatio = {}
    local GrpManaRatio = {}

    ImGui.SetWindowSize("Mimic Group"..charName, 128, 325)
    local groupButtons = {}
    ImGui.SetCursorPos(15,1)
    ImGui.Text("%s's Group", charName)
    if charTable['groupIds'] ~= nil then
        ImGui.SetCursorPos(4, 20)
        for currentMember = 0, #charTable['groupIds'] do
            if charTable['groupIds'][currentMember] ~= nil and charTable['groupIds'][currentMember] ~= 'Empty' and mq.TLO.Spawn(charTable['groupIds'][currentMember])() ~= nil then
                local cursorPos = ImGui.GetCursorPosVec()
                GrpHPRatio[currentMember] = mq.TLO.Spawn(charTable['groupIds'][currentMember]).PctHPs() / 100 or 0
                GrpManaRatio[currentMember] = mq.TLO.Spawn(charTable['groupIds'][currentMember]).PctMana() / 100 or 0
                ImGui.Text(mq.TLO.Spawn(charTable['groupIds'][currentMember]).Name())
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
                ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 255,0,0,255)
                ImGui.PushStyleColor(ImGuiCol.Text, 0,0,0,0)
                ImGui.ProgressBar(GrpHPRatio[currentMember], -1, 5)
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY()-3)
                ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 0,0,255,255)
                ImGui.ProgressBar(GrpManaRatio[currentMember], -1,5)
                ImGui.PopStyleColor(3)
                ImGui.SetCursorPos(cursorPos)
                groupButtons[currentMember] = ImGui.InvisibleButton(
                    mq.TLO.Spawn(charTable['groupIds'][currentMember]).Name(), 128,
                    35)
                if groupButtons[currentMember] then
                   DriverActor:send({mailbox ='mimic', script = 'mimic/mimicme', character = charName}, {id='newTarget',charName = charName, targetId = mq.TLO.Spawn(charTable['groupIds'][currentMember]).Name()})
                end
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY())
            end
        end
    end
 
end

return MimicGroupWindow
