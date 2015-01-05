local BASE = "page"

GUI.BaseName = BASE

function GUI:Initalize()
    self.Super[BASE].Initalize(self)
    
    sgui.addPage(self.Name)
end
