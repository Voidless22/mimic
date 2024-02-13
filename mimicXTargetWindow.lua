local mq = require('mq')
local imgui = require('ImGui')

MimicXTargetWindow = {}


function MimicXTargetWindow.DrawMimicXTargetWindow(charName, charTable)
    ImGui.SetWindowSize("Mimic XTarget" .. charName, 128, 256)
    local xtargetRatio = {}
    local xtargetButtons = {}
    local xtargetManaRatio = {}
    ImGui.Text("%s's XTarget", charName)
    if charTable['xtargetList'] ~= nil then
        for currentXtarget = 1, #charTable['xtargetList'] do
            if charTable['xtargetList'][currentXtarget] ~= 'Empty' and charTable['xtargetList'][currentXtarget] ~= 0 and charTable['xtargetList'][currentXtarget] ~= nil
                and mq.TLO.Spawn(charTable['xtargetList'][currentXtarget])() ~= nil then
                local cursorPos = ImGui.GetCursorPosVec()
                xtargetRatio[currentXtarget] = mq.TLO.Spawn(charTable['xtargetList'][currentXtarget]).PctHPs() / 100 or 0
                xtargetManaRatio[currentXtarget] = mq.TLO.Spawn(charTable['xtargetList'][currentXtarget]).PctMana() / 100 or 0
                ImGui.Text(mq.TLO.Spawn(charTable['xtargetList'][currentXtarget]).Name())
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
                ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 255, 0, 0, 255)
                ImGui.PushStyleColor(ImGuiCol.Text, 0, 0, 0, 0)
                ImGui.ProgressBar(xtargetRatio[currentXtarget], -1, 5)
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() - 3)
                ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 0, 0, 255, 255)
                ImGui.ProgressBar(xtargetManaRatio[currentXtarget], -1, 5)
                ImGui.PopStyleColor(3)
                ImGui.SetCursorPos(cursorPos)
                xtargetButtons[currentXtarget] = ImGui.InvisibleButton(mq.TLO.Spawn(charTable['xtargetList'][currentXtarget]).Name(),128, 29)
                if xtargetButtons[currentXtarget] then
                    DriverActor:send({mailbox='mimic', script='mimic/mimicme', character=charName}, {id ='newTarget', charName = charName, targetId =mq.TLO.Spawn(charTable['xtargetList'][currentXtarget]).DisplayName()})
                end
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 5)
            end
        end
    end
end

return MimicXTargetWindow
