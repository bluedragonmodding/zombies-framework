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

--spawns points 

local spawnPos = vector3(686.245, 577.950, 130.461)

AddEventHandler('onClientGameTypeStart', function()
    exports.spawnmanager:setAutoSpawnCallback(function()
        exports.spawnmanager:spawnPlayer({
            x = spawnPos.x,
            y = spawnPos.y,
            z = spawnPos.z,
            model = 's_m_y_armymech_01'
        }, function()
            TriggerEvent('chat:addMessage', {
                args = { 'Welcome to the party!~' }
            })
        end)
    end)

    exports.spawnmanager:setAutoSpawn(true)
    exports.spawnmanager:forceRespawn()
end)