--


local safezone ={
{ x = 450.5966, y = -998.9636, z = 28.4284, radius = 80.0 },--MISSON ROW 
{}
}

--give weapons and ammo and armor to player when they spawns--
ped = GetPlayerPed(-1)
GiveWeaponToPed(ped, GetHashKey("WEAPON_PISTOL"), 100, false, false),
GiveWeaponToPed(ped, GetHashKey("WEAPON_CARBINERIFLE"), 100, false, false),
GiveWeaponToPed(ped, GetHashKey("WEAPON_PUMPSHOTGUN"), 100, false, false),
GiveWeaponToPed(ped, GetHashKey("WEAPON_KNIFE"), 100, false, false),
GiveWeaponToPed(ped, GetHashKey("WEAPON_FLASHLIGHT"), 100, false, false),

--spawns points for player to spawn at--
local spawnPos = vector3(686.245, 577.950, 130.461)

AddEventHandler('onClientGameTypeStart', function()
    exports.spawnmanager:setAutoSpawnCallback(function()
        exports.spawnmanager:spawnPlayer({
            x = spawnPos.x,
            y = spawnPos.y,
            z = spawnPos.z,
            model = 's_m_y_armymech_01'},
            function()
            TriggerEvent('chat:addMessage', {
                args = { 'Welcome to the party!~' }
            })
        end)
    end)

    exports.spawnmanager:setAutoSpawn(true)
    exports.spawnmanager:forceRespawn()
end)
-- start of the zombies scripts --
DecorRegister('RegisterZombie', 2)

AddRelationshipGroup('ZOMBIE')
SetRelationshipBetweenGroups(0, GetHashKey('ZOMBIE'), GetHashKey('PLAYER'))
SetRelationshipBetweenGroups(5, GetHashKey('PLAYER'), GetHashKey('ZOMBIE'))

function IsPlayerShooting()
    return Shooting
end

function IsPlayerRunning()
    return Running
end

Citizen.CreateThread(function()-- Will only work in it's own while loop
    while true do
        Citizen.Wait(0)

        -- Peds
        SetPedDensityMultiplierThisFrame(1.0)
        SetScenarioPedDensityMultiplierThisFrame(1.0, 1.0)

        -- Vehicles
        SetRandomVehicleDensityMultiplierThisFrame(0.0)
        SetParkedVehicleDensityMultiplierThisFrame(0.0)
        SetVehicleDensityMultiplierThisFrame(0.0)
    end
end)

Citizen.CreateThread(function()-- Will only work in it's own while loop
    while true do
        Citizen.Wait(0)

        if IsPedShooting(PlayerPedId()) then
	        Shooting = true
	        Citizen.Wait(5000)
	        Shooting = false
	    end

	    if IsPedSprinting(PlayerPedId()) or IsPedRunning(PlayerPedId()) then
	        if Running == false then
	            Running = true
	        end
	    else
	        if Running == true then
	            Running = false
	        end
	    end
    end
end)

Citizen.CreateThread(function()
	for _, zone in pairs(SafeZones) do
    	local Blip = AddBlipForRadius(zone.x, zone.y, zone.z, zone.radius)
		SetBlipHighDetail(Blip, true)
    	SetBlipColour(Blip, 2)
    	SetBlipAlpha(Blip, 128)
	end

    while true do
        Citizen.Wait(0)

    	for _, zone in pairs(SafeZones) do
	        local Zombie = -1
	        local Success = false
	        local Handler, Zombie = FindFirstPed()

	        repeat
	            if IsPedHuman(Zombie) and not IsPedAPlayer(Zombie) and not IsPedDeadOrDying(Zombie, true) then
	                local pedcoords = GetEntityCoords(Zombie)
	              	local zonecoords = vector3(zone.x, zone.y, zone.z)
	                local distance = #(zonecoords - pedcoords)

	                if distance <= zone.radius then
	                    DeleteEntity(Zombie)
	                end
	            end

	            Success, Zombie = FindNextPed(Handler)
	        until not (Success)

	        EndFindPed(Handler)
	    end
	        
		local Zombie = -1
	 	local Success = false
		local Handler, Zombie = FindFirstPed()

	    repeat
        	Citizen.Wait(10)

	        if IsPedHuman(Zombie) and not IsPedAPlayer(Zombie) and not IsPedDeadOrDying(Zombie, true) then
	            if not DecorExistOn(Zombie, 'RegisterZombie') then
	                ClearPedTasks(Zombie)
	                ClearPedSecondaryTask(Zombie)
	                ClearPedTasksImmediately(Zombie)
	                TaskWanderStandard(Zombie, 10.0, 10)
	                SetPedRelationshipGroupHash(Zombie, 'ZOMBIE')
	                ApplyPedDamagePack(Zombie, 'BigHitByVehicle', 0.0, 1.0)
	                SetEntityHealth(Zombie, 200)

	                RequestAnimSet('move_m@drunk@verydrunk')
	                while not HasAnimSetLoaded('move_m@drunk@verydrunk') do
	                    Citizen.Wait(0)
	                end
	                SetPedMovementClipset(Zombie, 'move_m@drunk@verydrunk', 1.0)

	                SetPedConfigFlag(Zombie, 100, false)
	                DecorSetBool(Zombie, 'RegisterZombie', true)
	            end

	            SetPedRagdollBlockingFlags(Zombie, 1)
			    SetPedCanRagdollFromPlayerImpact(Zombie, false)
			    SetPedSuffersCriticalHits(Zombie, true)
			    SetPedEnableWeaponBlocking(Zombie, true)
			    DisablePedPainAudio(Zombie, true)
			    StopPedSpeaking(Zombie, true)
			    SetPedDiesWhenInjured(Zombie, false)
			    StopPedRingtone(Zombie)
			    SetPedMute(Zombie)
			    SetPedIsDrunk(Zombie, true)
			    SetPedConfigFlag(Zombie, 166, false)
			    SetPedConfigFlag(Zombie, 170, false)
			    SetBlockingOfNonTemporaryEvents(Zombie, true)
			    SetPedCanEvasiveDive(Zombie, false)
			    RemoveAllPedWeapons(Zombie, true)

	            local PlayerCoords = GetEntityCoords(PlayerPedId())
	            local PedCoords = GetEntityCoords(Zombie)
	            local Distance = #(PedCoords - PlayerCoords)
	            local DistanceTarget

	           	if IsPlayerShooting() then
	                DistanceTarget = 120.0
	            elseif IsPlayerRunning() then
	                DistanceTarget = 50.0
	            else
	                DistanceTarget = 20.0
	            end

	            if Distance <= DistanceTarget and not IsPedInAnyVehicle(PlayerPedId(), false) then
	                TaskGoToEntity(Zombie, PlayerPedId(), -1, 0.0, 2.0, 1073741824, 0)
	            end

	            if Distance <= 1.3 then
	                if not IsPedRagdoll(Zombie) and not IsPedGettingUp(Zombie) then
	                	local health = GetEntityHealth(PlayerPedId())
	                    if health == 0 then
	                        ClearPedTasks(Zombie)
	                        TaskWanderStandard(Zombie, 10.0, 10)
	                    else
	                        RequestAnimSet('melee@unarmed@streamed_core_fps')
	                        while not HasAnimSetLoaded('melee@unarmed@streamed_core_fps') do
	                            Citizen.Wait(10)
	                        end

	                        TaskPlayAnim(Zombie, 'melee@unarmed@streamed_core_fps', 'ground_attack_0_psycho', 8.0, 1.0, -1, 48, 0.001, false, false, false)

	                        ApplyDamageToPed(PlayerPedId(), 5, false)
	                    end
	                end
	            end
	            
	            if not NetworkGetEntityIsNetworked(Zombie) then
	                DeleteEntity(Zombie)
	            end
	        end
	        
	        Success, Zombie = FindNextPed(Handler)
	   	until not (Success)

    	EndFindPed(Handler)
   	end
end)