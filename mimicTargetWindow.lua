local mq = require('mq')
local ImGui = require('ImGui')

MimicTargetWindow = {}

MimicTargetWindow.mimicTargetId = 'Empty'
MimicTargetWindow.previousTarget = 'Empty'
local animSpellIcons = mq.FindTextureAnimation('A_SpellIcons')

function MimicTargetWindow.DrawMimicTargetWindow(charName, charTable)
    local targetHPRatio
    ImGui.SetWindowSize("Mimic Target" .. charName, 140, 256)
    ImGui.SetCursorPos(4, 0)
    ImGui.Text("%s's Target", charName)
    ImGui.SetCursorPos(4, 20)
    if charTable.mimicTargetId ~= 'Empty' and mq.TLO.Spawn(charTable.mimicTargetId)() ~= nil then
        targetHPRatio = mq.TLO.Spawn(charTable.mimicTargetId).PctHPs() / 100 or 0
        ImGui.Text(mq.TLO.Spawn(charTable.mimicTargetId).DisplayName())
        ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
        ImGui.ProgressBar(targetHPRatio, -1, 15)
        ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
        local rowCount = 0
        if charTable.targetBuffs ~= nil then
            for index, value in ipairs(charTable.targetBuffs) do
                if value ~= 0 then
                    animSpellIcons:SetTextureCell(mq.TLO.Spell(value).SpellIcon())
                    ImGui.DrawTextureAnimation(animSpellIcons, 32, 32)
                    if rowCount < 3 then
                        ImGui.SameLine(0, 0)
                        rowCount = rowCount + 1
                    else
                        ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 2)
                        rowCount = 0
                    end
                    if ImGui.IsItemHovered() then
                        if ImGui.BeginTooltip() then
                            ImGui.Text(mq.TLO.Spell(value).Name())
                            ImGui.EndTooltip()
                        end
                    end
                end
            end
        end
    end
end

return MimicTargetWindow
