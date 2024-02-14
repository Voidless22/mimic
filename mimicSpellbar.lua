local mq = require('mq')
local imgui = require('ImGui')

MimicSpellbar = {}

MimicSpellbar.spellbarIds = {}
MimicSpellbar.previousSpellbar = {}

function MimicSpellbar.DrawSpellbar(charName, charTable)
    local gemButtons = {}

    local spellIds = charTable['Spellbar']
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
                local screenCursorPos = ImGui.GetCursorScreenPosVec()

                if charTable['isCasting'] ~= nil and charTable['isCasting'] == mq.TLO.Spell(spellIds[currentGem]).Name() then
                    local drawlist = ImGui.GetWindowDrawList()
                    local x = screenCursorPos.x + 34
                    local y = screenCursorPos.y + 34
                    local color = ImGui.GetColorU32(ImVec4(255, 0, 0, 255))
                    drawlist:AddRectFilled(screenCursorPos, ImVec2(x, y), color, 5)

                elseif charTable['isCasting'] ~= mq.TLO.Spell(spellIds[currentGem]).Name() then
                    animSpellIcons:SetTextureCell(mq.TLO.Spell(spellIds[currentGem]).SpellIcon())
                    ImGui.DrawTextureAnimation(animSpellIcons, 32, 32)
                end

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
