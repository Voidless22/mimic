local ImGui = require('ImGui')

MimicConfigWindow = {}

function MimicConfigWindow.DrawConfigWindow(charName,charTable)
    ImGui.SetWindowSize("Mimic Config"..charName, 256,512)
    ImGui.Text("test")
end


return MimicConfigWindow