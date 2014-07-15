-- Copyright (c) 2014 James King [metapyziks@gmail.com]
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

function EFFECT:Init(data)
    self.ShotStart = data:GetStart()
    self.ShotEnd   = data:GetOrigin()

    self:SetRenderBoundsWS(self.ShotStart, self.ShotEnd)

    self.Duration = data:GetScale()

    self.Initial = CurTime()
    self.FadeIn  = self.Initial + 0.1 * self.Duration
    self.FadeOut = self.Initial + 0.5 * self.Duration
    self.EndTime = self.Initial + self.Duration

    local ply = data:GetEntity()

    if IsValid(ply) and ply:IsPlayer() then
        self.Color = team.GetColor(ply:Team())
    else
        self.Color = Color(255, 255, 255, 255)
    end

    self.Color.a = 127

    self.Width    = 0
    self.WidthMax = data:GetScale() * 4
end

function EFFECT:Think()
    if CurTime() > self.EndTime then
        return false
    end

    return true
end

local _beamMaterial = Material("effects/blueblacklargebeam")
function EFFECT:Render()
    if CurTime() < self.FadeIn then
        local t = (CurTime() - self.Initial) / (self.FadeIn - self.Initial)
        self.Width = t * self.WidthMax
    elseif CurTime() < self.FadeOut then
        self.Width = self.WidthMax
    else
        local t = (CurTime() - self.FadeOut) / (self.EndTime - self.FadeOut)
        self.Width = (1 - t) * self.WidthMax
    end

    render.SetMaterial(_beamMaterial)
    render.DrawBeam(self.ShotStart, self.ShotEnd, self.Width, 0, 0, self.Color)
end
