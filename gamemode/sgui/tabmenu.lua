-- Copyright (c) 2014 James King [metapyziks@gmail.com] and George Albany [megacake1234@gmail.com]
-- 
-- This file is part of Final Frontier.
-- 
-- Final Frontier is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as
-- published by the Free Software Foundation, either version 3 of
-- the License, or (at your option) any later version.
-- 
-- Final Frontier is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public License
-- along with Final Frontier. If not, see <http://www.gnu.org/licenses/>.

local BLACK = Color(0, 0, 0, 255)
local BASE = "container"

GUI.BaseName = BASE

GUI.Color = Color(191, 191, 191, 255)

GUI._tabs = nil
GUI._current = 0
GUI._pages = nil
GUI._pageNumber = 0
GUI._pageLimit = 4

GUI._leftButton = nil
GUI._rightButton = nil

function GUI:Initialize()
    self.Super[BASE].Initialize(self)

    self._tabs = {}
    self._pages = {}
end

function GUI:AddTab(text)
    local tab = sgui.Create(self, "tab")
    tab.Text = text

    table.insert(self._tabs, tab)
    self:UpdateTabPositions()

    if self._current == 0 then
        self:SetCurrentIndex(1)
    end

    return tab
end

function GUI:SetTabsPerPage(number)
    self._pageLimit = number
end

function GUI:SetBounds(bounds)
    self.Super[BASE].SetBounds(self, bounds)
    self:UpdateTabPositions()
end

function GUI:GetCurrentIndex()
    return self._current
end

function GUI:GetCurrent()
    return self._tabs[self._current]
end

function GUI:OnChangeCurrent() end

function GUI:SetCurrentIndex(index)
    if index < 1 or index > #self._tabs then
        index = 0
    end

    if self._current ~= index then
        self._current = index
        self:OnChangeCurrent(index)
    end
end

function GUI:SetCurrentPage(pageIndex)
   self._pageNumber = pageIndex 
   self:UpdateTabPositions();
end

function GUI:SetCurrent(tab)
    if type(tab) == "string" then
        for i, v in ipairs(self._tabs) do
            if v.Text == tab then
                self:SetCurrentIndex(i)
                return
            end
        end
    else
        for i, v in ipairs(self._tabs) do
            if v == tab then
                self:SetCurrentIndex(i)
                return
            end
        end
    end
end

function GUI:GetTab(index)
    return self._tabs[index]
end

function GUI:GetTabCount()
    return #self._tabs
end

function GUI:UpdateTabPositions()
    local margin = 8
    local width = (self:GetWidth() - margin) / self._pageLimit

    local left = margin
    
    if #self._tabs > self._pageLimit then
        self._pages = {}
        for i=0, (#self._tabs/self._pageLimit) do
            self._pages[i] = {}
        end
        for i, tab in ipairs(self._tabs) do
            self._pages[i/self._pageLimit][i%self._pageLimit] = tab
        end
        self._tabs = self._pages[self._pageNumber]
        
        self._leftButton = sgui.Create(self, "button")
        self._leftButton:SetHeight(self:GetHeight() - margin * 2)
        self._leftButton:SetWidth(self._leftButton:GetHeight())
        self._leftButton:SetOrigin(0,0)
        self._leftButton.Text = "<"
        self._leftButton.CanClick = self._pageNumber > 1
        
        self._rightButton = sgui.Create(self, "button")
        self._rightButton:SetHeight(self:GetHeight() - margin * 2)
        self._rightButton:SetWidth(self._rightButton:GetHeight())
        self._rightButton:SetOrigin(self:GetWidth() - self._rightButton:GetWidth(), 0)
        self._rightButton.Text = ">"
        self._rightButton.CanClick = self._pageNumber < #self._pages
        
        if SERVER then
        self._leftButton.OnClick = function(btn)
            self:SetCurrentPage(self._pageNumber-1)
        end
        
        self._rightButton.OnClick = function(btn)
            self:SetCurrentPage(self._pageNumber+1)
        end
        end
    end

    for i, tab in ipairs(self._tabs) do
        tab:SetHeight(self:GetHeight() - margin * 2)
        tab:SetWidth(width - margin)
        tab:SetOrigin(left, margin)
        left = left + width
    end
    
end

if SERVER then
    function GUI:UpdateLayout(layout)
        self.Super[BASE].UpdateLayout(self, layout)

        layout.current = self:GetCurrentIndex()
    end
end

if CLIENT then
    function GUI:Draw()
        surface.SetDrawColor(self.Color)
        surface.DrawOutlinedRect(self:GetGlobalRect())

        self.Super[BASE].Draw(self)
    end

    function GUI:UpdateLayout(layout)
        self.Super[BASE].UpdateLayout(self, layout)

        self:SetCurrentIndex(layout.current)
    end
end
