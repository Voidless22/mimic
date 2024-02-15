local mq = require('mq')
local ImGui = require('ImGui')
local modifyingGem = {gem = 1, id = nil}
local gemButtons = {}
local gemLoc = {}
local screenGemLoc = {}
local red = ImGui.GetColorU32(ImVec4(255, 0, 0, 255))
local green = ImGui.GetColorU32(ImVec4(0, 255, 0, 255))
local animSpellIcons = mq.FindTextureAnimation('A_SpellIcons')

MimicLoadoutWindow = {}

local spells = {}
MimicLoadoutWindow.loadoutSections = { 'Spells', 'AAs', 'Items' }

local selectedCategory

local function drawSquare(screenCursorPos, color)
    local drawlist = ImGui.GetWindowDrawList()
    local x = screenCursorPos.x + 31
    local y = screenCursorPos.y + 31
    drawlist:AddRect(screenCursorPos, ImVec2(x, y), color, 0, ImDrawFlags.None, 2)
end



local currentCategory
local currentSubcategory
local currentSpell
function MimicLoadoutWindow.DrawSpellCategorySelect(charName, charTable)
    if ImGui.BeginListBox("##Category", ImVec2(150, 300)) then
        for i, item in pairs(charTable.spellTable.categories) do
            local _, clicked = ImGui.Selectable(item, currentCategory == item)
            ImGui.Separator()
            if clicked then
                currentSubcategory = nil
                currentSpell = nil
                currentCategory = item
             
            end
        end
    end
    ImGui.EndListBox()
end

function MimicLoadoutWindow.DrawSpellSubcategorySelect(charName, charTable)
    if ImGui.BeginListBox("##Subcategory", ImVec2(150, 300)) then
        if currentCategory ~= nil then
            for i, item in pairs(charTable.spellTable[currentCategory].subcategories) do
                local _, clicked = ImGui.Selectable(item, currentSubcategory == item)
                ImGui.Separator()
                if clicked then
                    currentSpell = nil
                    currentSubcategory = item
                end
            end
        end
    end
    ImGui.EndListBox()
end
function MimicLoadoutWindow.DrawSpellSelect(charName, charTable)
    if ImGui.BeginListBox("##Spells", ImVec2(200, 300)) then
        if currentSubcategory ~= nil and currentCategory ~= nil  then
            for i, item in pairs(charTable.spellTable[currentCategory][currentSubcategory]) do
                local _, clicked = ImGui.Selectable('Lvl:'..item[1].. ' '..item[2], currentSpell == item[2])
                ImGui.Separator()
                if clicked then
                    currentSpell = item[2]
                    if mq.TLO.Spell(modifyingGem.id).Name() ~= currentSpell then
                        modifyingGem.id = mq.TLO.Spell(currentSpell).Name()
                        DriverActor:send({mailbox='mimic', script = 'mimic/mimicme'}, {id='updateSpellbar', charName = charName, gem = modifyingGem.gem, spellId = currentSpell })
                    end
                end
            end
        end
    end
    ImGui.EndListBox()
end


function MimicLoadoutWindow.DrawCurrentSpellbar(charName, charTable)
    local spellIds = charTable['Spellbar']
    if spellIds ~= nil then
        for currentGem = 1, #spellIds do
            if spellIds[currentGem] == 'Empty' then
                local cursorPos = ImGui.GetCursorPosVec()
                local screenCursorPos = ImGui.GetCursorScreenPosVec()
                drawSquare(screenCursorPos, red)
                ImGui.SetCursorPos(cursorPos)
                gemLoc[currentGem] = ImGui.GetCursorPosVec()
                screenGemLoc[currentGem] = ImGui.GetCursorScreenPosVec()
                gemButtons[currentGem] = ImGui.InvisibleButton((mq.TLO.Spell(spellIds[currentGem]).Name() or 'Empty'), 32,
                    32)
            elseif spellIds[currentGem] ~= 'Empty' and spellIds[currentGem] ~= nil then
                local cursorPos = ImGui.GetCursorPosVec()
                animSpellIcons:SetTextureCell(mq.TLO.Spell(spellIds[currentGem]).SpellIcon())
                ImGui.DrawTextureAnimation(animSpellIcons, 32, 32)
                ImGui.SetCursorPos(cursorPos)
                gemLoc[currentGem] = ImGui.GetCursorPosVec()
                screenGemLoc[currentGem] = ImGui.GetCursorScreenPosVec()
                gemButtons[currentGem] = ImGui.InvisibleButton(mq.TLO.Spell(spellIds[currentGem]).Name(), 32, 32)
            end

            drawSquare(screenGemLoc[modifyingGem.gem], green)

            if gemButtons[currentGem] then
                printf('gem %s clicked', currentGem)
                modifyingGem = {gem=currentGem, id=mq.TLO.Spell(currentGem).ID()}
                currentCategory = mq.TLO.Spell(spellIds[modifyingGem.id]).Category()
                currentSubcategory = mq.TLO.Spell(spellIds[modifyingGem.id]).Subcategory()
                currentSpell = mq.TLO.Spell(spellIds[modifyingGem.id]).Name()
            end
            if ImGui.IsItemHovered() then
                if ImGui.BeginTooltip() then
                    if mq.TLO.Spell(spellIds[currentGem]).Name() == nil then
                        ImGui.Text("Empty")
                    else
                        ImGui.Text(mq.TLO.Spell(spellIds[currentGem]).Name())
                    end
                end
                ImGui.EndTooltip()
            end
        end
    end
end

function MimicLoadoutWindow.DrawSpellsTab(charName, charTable)
    -- Draw Spellbar
    MimicLoadoutWindow.DrawCurrentSpellbar(charName, charTable)
    ImGui.SetCursorPos(60, 40)
    MimicLoadoutWindow.DrawSpellCategorySelect(charName, charTable)
    ImGui.SetCursorPos(212,40)
    MimicLoadoutWindow.DrawSpellSubcategorySelect(charName, charTable)
    ImGui.SetCursorPos(364,40)
    MimicLoadoutWindow.DrawSpellSelect(charName,charTable)
end

function MimicLoadoutWindow.DrawTabScreen(tab, charName, charTable)
    if tab == 'Spells' then
        MimicLoadoutWindow.DrawSpellsTab(charName, charTable)
    end
end

function MimicLoadoutWindow.DrawMimicLoadoutWindow(charName, charTable)
    ImGui.SetWindowSize("Loadout" .. charName, 600, 380)
    if ImGui.BeginTabBar("##loadoutSections") then
        for i = 1, #MimicLoadoutWindow.loadoutSections do
            if ImGui.BeginTabItem(MimicLoadoutWindow.loadoutSections[i]) then
                MimicLoadoutWindow.DrawTabScreen(MimicLoadoutWindow.loadoutSections[i], charName, charTable)
                ImGui.EndTabItem()
            end
        end
    end
    ImGui.EndTabBar()
end

return MimicLoadoutWindow
