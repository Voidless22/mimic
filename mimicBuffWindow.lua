local mq = require('mq')
local imgui = require('ImGui')

MimicBuffWindow = {}

local animSpellIcons = mq.FindTextureAnimation('A_SpellIcons')

function MimicBuffWindow.DrawMimicBuffWindow(charName, charTable)
    ImGui.SetWindowSize("Buffs" .. charName, 150, 150, ImGuiCond.Appearing)
    ImGui.Text('Buffs: %s', charName)
    local buffNames = charTable['currentBuffs']
    if buffNames ~= nil then
        for index, value in ipairs(buffNames) do
            if buffNames[index] ~= nil then
                animSpellIcons:SetTextureCell(mq.TLO.Spell(charTable['currentBuffs'][index]).SpellIcon())
                ImGui.DrawTextureAnimation(animSpellIcons, 32, 32)
            end
        end
    end
end

return MimicBuffWindow
