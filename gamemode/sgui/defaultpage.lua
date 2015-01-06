local BASE = "page"

GUI.BaseName = BASE

GUI.TabIndex = 0
GUI.TabName = "PAGE"

function GUI:Initialize()
    self.Super[BASE].Initialize(self)
	
	sgui.assignPage(self.Name, self.TabIndex)
end