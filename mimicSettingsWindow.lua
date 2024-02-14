local ImGui = require('ImGui')
local mq = require('mq')
MimicSettingsWindow = {}

MimicSettingsWindow.section_listbox = {
    items = {},
    selected = 1
}


function MimicSettingsWindow.GetSections()
    for settingName, value in pairs(Settings) do
        if type(Settings[settingName] ~= 1) then
            for toonName, settingValue in pairs(Settings[settingName]) do
                local nameFound = false
                for index, value in ipairs(MimicSettingsWindow.section_listbox.items) do
                    if not nameFound then
                        if value == toonName then
                            nameFound = true
                        end
                    end
                end
                if not nameFound then
                    table.insert(MimicSettingsWindow.section_listbox.items, toonName)
                end
            end
        end
    end
end

function MimicSettingsWindow.sectionHandler(section)
    ImGui.SetCursorPos(10, 60)

    if ImGui.BeginListBox("", ImVec2(150, 350)) then
        for i, item in pairs(MimicSettingsWindow.section_listbox.items) do
            local _, clicked = ImGui.Selectable(item, MimicSettingsWindow.section_listbox.selected == i)
            ImGui.Separator()
            if clicked then MimicSettingsWindow.section_listbox.selected = i end
        end
    end
    ImGui.EndListBox()
end

function MimicSettingsWindow.DrawSettingsWindow()
    local settingsPath = 'mimicSettings.lua'
    ImGui.SetWindowSize('Settings', 500, 500)
    MimicSettingsWindow.GetSections()
    MimicSettingsWindow.sectionHandler()
    local section = MimicSettingsWindow.section_listbox.items[MimicSettingsWindow.section_listbox.selected]
    ImGui.SetCursorPos(170, 60)
    local settingToggles = {}
    for settingName, value in pairs(Settings) do
        for toonName, settingValue in pairs(Settings[settingName]) do
            if toonName == section then
                ImGui.SetCursorPos(170, ImGui.GetCursorPosY())
                if type(settingValue) == 'boolean' then
                    ImGui.Text(settingName)
                    ImGui.SameLine()
                    ImGui.SetCursorPosX(350)
                    local settingValue, clicked = ImGui.Checkbox("##" .. settingName, settingValue)
                    if clicked then
                        Settings[settingName][toonName] = not Settings[settingName][toonName]

                        mq.pickle(settingsPath, Settings)
                        local fileData = loadfile(mq.configDir .. '/' .. settingsPath)
                        Settings = fileData()
                    end
                end
            end
        end
    end
end

return MimicSettingsWindow
