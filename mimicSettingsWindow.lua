local ImGui = require('ImGui')

MimicSettingsWindow = {}


function MimicSettingsWindow.DrawSettingsWindow()
    ImGui.SetWindowSize('Settings', 1000,1000)
    ImGui.SetCursorPos(4,4)
    ImGui.Text("Test")
end

return MimicSettingsWindow
