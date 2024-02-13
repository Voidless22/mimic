local mq = require('mq')
local imgui = require('ImGui')

MimicSpellbar = {}

MimicSpellbar.spellbarIds = {}
MimicSpellbar.previousSpellbar = {}

function MimicSpellbar.DrawSpellbar(charName, spellIds)
    local gemButtons = {}


    ImGui.SetWindowSize("Mimic Bar-" .. charName, 40, 320)
    ImGui.SetCursorPos(4, 4)
    local animSpellIcons = mq.FindTextureAnimation('A_SpellIcons')
    if spellIds ~= nil then
        for currentGem = 1, #spellIds do
            if spellIds[currentGem] == 'Empty' or spellIds[currentGem] == nil then
                local curx = ImGui.GetCursorPosX()
                local cury = ImGui.GetCursorPosY()
                ImGui.SetCursorPos(curx, cury + 36)
            elseif spellIds[currentGem] ~= 'Empty' and spellIds[currentGem] ~= nil then
                local cursorPos = ImGui.GetCursorPosVec()
                animSpellIcons:SetTextureCell(mq.TLO.Spell(spellIds[currentGem]).SpellIcon())
                ImGui.DrawTextureAnimation(animSpellIcons, 32, 32)
                ImGui.SetCursorPos(cursorPos)
                gemButtons[currentGem] = ImGui.InvisibleButton(mq.TLO.Spell(spellIds[currentGem]).Name(), 32, 32)
                ImGui.SetCursorPos(4, ImGui.GetCursorPosY() + 4)
                if ImGui.IsItemHovered() then
                    if ImGui.BeginTooltip() then
                        ImGui.Text(mq.TLO.Spell(spellIds[currentGem]).Name())
                        ImGui.EndTooltip()
                    end
                end

                if gemButtons[currentGem] then
                    DriverActor:send({ mailbox = 'mimic', script = 'mimic/mimicme', character = charName },
                        { id = 'castSpell', charName = charName, gem = currentGem })
                end
            end
        end
    end
end

return MimicSpellbar
