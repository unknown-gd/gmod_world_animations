local addon_name = "Simple World Interactions"
local IsValid = IsValid

if (SERVER) then

	util.AddNetworkString( addon_name )

	-- PLAYER:RunGesture( slot, act, akill )
	do

		local net_WriteTable = net.WriteTable
		local net_Broadcast = net.Broadcast
		local net_Start = net.Start

		local PLAYER = FindMetaTable( "Player" )
		function PLAYER:RunGesture( slot, act, akill )
			net_Start( addon_name )
				net_WriteTable({ self, slot, act, akill == nil and true or akill == true })
			net_Broadcast()
		end

	end

	-- PlayerUse
	do

		local presstable = {"func_button", "gmod_button", "gmod_wire_button", "gmod_wire_keypad", "gmod_wire_keyboard"}
		local pushtable = {"prop_door_rotating", "func_door_rotating", "gmod_wire_lever"}
		local CurTime = CurTime
		local ipairs = ipairs

		hook.Add("PlayerUse", addon_name, function( ply, ent )
			if IsValid( ply ) and IsValid( ent ) then
				if ply:KeyDown( IN_USE ) then return end

				if ((ply[addon_name] or 0) > CurTime()) then return end
				ply[addon_name] = CurTime() + 1

				local class = ent:GetClass()
				for num, value in ipairs( pushtable ) do
					if (value == class) then
						ply:RunGesture( GESTURE_SLOT_CUSTOM, ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM )
						return
					end
				end

				for num, value in ipairs( presstable ) do
					if (value == class) then
						ply:RunGesture( GESTURE_SLOT_CUSTOM, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST )
						return
					end
				end

			end
		end)

	end

	-- Physics Gun Pickup
	hook.Add("OnPlayerPhysicsPickup", addon_name, function( ply, ent )
		if IsValid( ply ) and IsValid( ent ) then
			ply:RunGesture( GESTURE_SLOT_CUSTOM, ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE )
		end
	end)

	-- Physics Gun Drop
	hook.Add("OnPlayerPhysicsDrop", addon_name, function( ply, ent, thrown )
		if IsValid( ply ) and IsValid( ent ) then
			if (thrown == true) then
				ply:RunGesture( GESTURE_SLOT_CUSTOM, ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE )
			else
				ply:RunGesture( GESTURE_SLOT_CUSTOM, ACT_GMOD_GESTURE_ITEM_PLACE )
			end
		end
	end)

	-- On Water
	hook.Add("OnEntityWaterLevelChanged", addon_name, function( ply, old, new )
		if ply:IsPlayer() then
			if (new < 3) and (old >= 3) then
				ply:RunGesture( GESTURE_SLOT_CUSTOM, ACT_FLINCH_PHYSICS )
			elseif (new == 3) then
				ply:RunGesture( GESTURE_SLOT_CUSTOM, ACT_FLINCH_STOMACH )
			end
		end
	end)
end

if (CLIENT) then

	local engine_TickInterval = engine.TickInterval
	local net_ReadTable = net.ReadTable
	local timer_Simple = timer.Simple

	net.Receive(addon_name, function()
		local data = net_ReadTable()
		if (data) then
			local ply = data[1]
			if IsValid( ply ) then
				timer_Simple(engine_TickInterval(), function()
					if IsValid( ply ) then
						ply:AnimRestartGesture( data[2], data[3], data[4] )
					end
				end)
			end
		end
	end)

end