-- Copyright (c) 2014 James King [metapyziks@gmail.com]
-- 
-- This file is part of GMTools.
-- 
-- GMTools is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as
-- published by the Free Software Foundation, either version 3 of
-- the License, or (at your option) any later version.
-- 
-- GMTools is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public License
-- along with GMTools. If not, see <http://www.gnu.org/licenses/>.

if CLIENT then
	SWEP.HoldType      = "pistol"
	SWEP.PrintName     = "Phaser"
	SWEP.ViewModelFOV  = 56
	SWEP.ViewModelFlip = false
	SWEP.Slot          = 1
	SWEP.SlotPos       = 1
	SWEP.DrawAmmo      = false
	SWEP.DrawCrosshair = true
	SWEP.UseHands      = true
end

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.Primary.Sound    = Sound("Weapon_AR2.Single")
SWEP.Primary.Recoil   = 2
SWEP.Primary.Damage   = 50
SWEP.Primary.NumShots = 1  
SWEP.Primary.Delay    = 0.125
SWEP.Primary.Ammo     = "none"  
SWEP.Primary.Force    = 2

SWEP.Primary.ChargeDecay  = 0.95
SWEP.Primary.RechargeRate = 0.25
SWEP.Primary.ClipSize     = 1
SWEP.Primary.DefaultClip  = 1
SWEP.Primary.Automatic    = true

SWEP.ReloadSound = "Weapon_Pistol.Reload"

SWEP._lastShot = 0
SWEP._lastCharge = 0

function SWEP:GetCharge()
	return math.Clamp(self._lastCharge + (CurTime() - self._lastShot) * self.Primary.RechargeRate, 0, 1)
end

function SWEP:Deploy()
	self._lastShot = CurTime()
	self._lastCharge = 0
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local firstTime = SERVER or CurTime() - self._lastShot >= self.Primary.Delay / 2

	local charge = self:GetCharge()

	if firstTime then
		self._lastShot = CurTime()
		self._lastCharge = charge * charge * self.Primary.ChargeDecay

		local nextShot = self._lastShot + self.Primary.Delay * (4 - 3 * charge)

		self.Weapon:SetNextPrimaryFire(nextShot)
		self.Weapon:SetNextSecondaryFire(nextShot)
	end

	self:ShootEffects()

	local punchP = math.Rand(-0.4, -0.2) * self.Primary.Recoil * (1 - charge)
	local punchY = math.Rand(-0.3,  0.2) * self.Primary.Recoil * (1 - charge)

	self.Owner:ViewPunch(Angle(punchP, punchY, 0))
	
	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 65536
	trace.filter = self.Owner

	local tr = util.TraceLine(trace)
	
	local vAng = (tr.HitPos - self.Owner:GetShootPos()):GetNormal():Angle()
	
	if SERVER then
		local dmginfo = DamageInfo()
		dmginfo:SetDamage(self.Primary.Damage * charge)
		dmginfo:SetAttacker(self:GetOwner())
		dmginfo:SetInflictor(self)
		
		if dmginfo.SetDamageType then
			dmginfo:SetDamagePosition(tr.HitPos)
			dmginfo:SetDamageType(DMG_PLASMA)
		end
		
		tr.Entity:DispatchTraceAttack(dmginfo, tr.HitPos, tr.HitPos - vAng:Forward() * 20)
	end

	if firstTime then
		local hit1, hit2 = tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal
		
		local effect = EffectData()
		effect:SetOrigin(tr.HitPos - vAng:Forward() * 4)
		effect:SetNormal(tr.HitNormal)
		effect:SetScale(0 * charge)

		util.Effect("AR2Impact", effect)
		
		self.Weapon:EmitSound("weapons/ar2/fire1.wav", 100, 100 + charge * 40)
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:Holster()
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then
	function SWEP:DoDrawCrosshair(x, y)
		local charge = self:GetCharge()
		local inner = CreateHollowCircle(x, y, 24, 25, (1 - charge) * math.pi * 0.5, charge * math.pi)
		local outer = CreateHollowCircle(x, y, 23, 26, (1 - charge) * math.pi * 0.5, charge * math.pi)
        local clr = team.GetColor(self.Owner:Team())

        draw.NoTexture()

		surface.SetDrawColor(Color(clr.r, clr.g, clr.b, 64))
		surface.DrawRect(x - 1, y - 3, 3, 6)
        
        for _, v in ipairs(outer) do
			surface.DrawPoly(v)
		end

		surface.SetDrawColor(Color(255, 255, 255, 64))
		surface.DrawRect(x, y - 2, 1, 4)

        for _, v in ipairs(inner) do
			surface.DrawPoly(v)
		end

		return true
	end
end
