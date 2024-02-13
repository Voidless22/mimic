local mq = require('mq')
local ImGui = require('ImGui')

MimicTargetWindow = {}

MimicTargetWindow.mimicTargetId = 'Empty'
MimicTargetWindow.previousTarget = 'Empty'

 function MimicTargetWindow.DrawMimicTargetWindow(charName, charTable)
    local targetHPRatio
    ImGui.SetWindowSize("Mimic Target"..charName,128, 64)
    ImGui.SetCursorPos(4,45)
    ImGui.Text("%s's Target", charName)
    ImGui.SetCursorPos(4, 4)
    if charTable.mimicTargetId ~= 'Empty' and mq.TLO.Spawn(charTable.mimicTargetId)() ~= nil then
        targetHPRatio = mq.TLO.Spawn(charTable.mimicTargetId).PctHPs() / 100 or 0
        ImGui.Text(mq.TLO.Spawn(charTable.mimicTargetId).DisplayName())
        ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
        ImGui.ProgressBar(targetHPRatio, -1, 15)
    end
end

return MimicTargetWindow