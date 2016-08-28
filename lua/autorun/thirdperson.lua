if SERVER then AddCSLuaFile() end

--> Set and get class of a player
local meta = FindMetaTable( "Player" )

function meta:GetThirdPersonNumber()

	return self:GetNWInt( "S3RD" )

end

function meta:SetThirdPersonNumber( amt )

	return self:SetNWInt( "S3RD", amt )

end

if SERVER then

	util.AddNetworkString( "UpdateS3rd" )

	--> F keys
	hook.Add( "ShowHelp", "ChangeS3rdView", function( ply ) --> F1

		if !ply:Alive() then return end

		if ply:GetThirdPersonNumber() >= 4 then

			ply:SetThirdPersonNumber( 0 )

		else

			ply:SetThirdPersonNumber( ply:GetThirdPersonNumber() + 1 )

		end

		local UD = 0
		local RL = 0
		local FB = 0

		if ply:GetThirdPersonNumber() == 1 then

			UD = 10 --> Up / Down
			RL = -50 --> Right / Left.
			FB = -100 --> Forward / Backward.

		elseif ply:GetThirdPersonNumber() == 2 then

			UD = 20 --> Up / Down
			RL = 0 --> Right / Left.
			FB = -100 --> Forward / Backward.

		elseif ply:GetThirdPersonNumber() == 3 then

			UD = 10 --> Up / Down
			RL = 50 --> Right / Left.
			FB = -100 --> Forward / Backward.

		elseif ply:GetThirdPersonNumber() == 4 then

			UD = 40 --> Up / Down
			RL = 0 --> Right / Left.
			FB = -60 --> Forward / Backward.

		end

		net.Start("Update3rd")

			net.WriteInt(UD, 8)
			net.WriteInt(RL, 8)
			net.WriteInt(FB, 8)

		net.Send(ply)

	end )

	hook.Add("PlayerDeath", "FixSimplerThirdPerson", function(ply)

		ply:SetThirdPersonNumber( 0 )

		local UD = 0
		local RL = 0
		local FB = 0

		net.Start("Update3rd")

			net.WriteInt(UD, 8)
			net.WriteInt(RL, 8)
			net.WriteInt(FB, 8)

		net.Send(ply)

	end)

else

	--> Calc the camera offset and upadte
	local CameraOffset = { }

	net.Receive( "Update3rd", function()

		CameraOffset.UD = net.ReadInt(8)
		CameraOffset.RL = net.ReadInt(8)
		CameraOffset.FB = net.ReadInt(8)

	end )

	--> Draw the plyaer or not
	hook.Add( "ShouldDrawLocalPlayer", "ThirdPersonDrawPlayer", function()

		return LocalPlayer():GetThirdPersonNumber() != 0 && !LocalPlayer():InVehicle() || LocalPlayer():IsPlayingTaunt()

	end )

	--> Calc the view and return it
	hook.Add( "CalcView", "ThirdPersonCalcView", function( ply, Origin, Ang, Fov )

		if ply:GetThirdPersonNumber() != 0 && !ply:InVehicle() then

			local TraceData   = { }
			TraceData.start   = ply:EyePos()
			TraceData.endpos  = ply:EyePos() + ( ply:GetUp() * CameraOffset.UD ) + ( ply:GetRight() * CameraOffset.RL ) + ( ply:GetForward() * CameraOffset.FB )
			TraceData.filter  = ply
			TraceData.mask    = MASK_SOLID_BRUSHONLY

			local Trace   = util.TraceLine( TraceData )
			
			local View    = { }
			View.origin   = Trace.HitPos + ply:GetForward() * 8
			View.angles   = ply:GetAngles()
			View.fov      = Fov

			return View

		end

		return false

	end )

end