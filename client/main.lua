ESX              = nil
local PlayerData = {}
local pedspawneado = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

---- npc spawn

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		for k, v in pairs(Config.ubicacion) do
			local cordenadasped = GetEntityCoords(PlayerPedId())	
			local dist = #(v.Cordenadas - cordenadasped)
			
			if dist < 11 and pedspawneado == false then
				TriggerEvent('Night:npcenter',v.Cordenadas,v.h)
				pedspawneado = true
			end
			if dist >= 10  then
				pedspawneado = false
                SetEntityAlpha(tunpc, 1, false)
				DeletePed(tunpc)

			end
		end
	end
end)

RegisterNetEvent('Night:npcenter')
AddEventHandler('Night:npcenter',function(coords,heading)
	local hash = GetHashKey(Config.npc)  --- change the npc to your liking
	if not HasModelLoaded(hash) then
		RequestModel(hash)
		Wait(10)
	end
	while not HasModelLoaded(hash) do 
		Wait(10)
	end

    pedspawneado = true
	tunpc = CreatePed(5, hash, coords, heading, false, false)
	FreezeEntityPosition(tunpc, true)
    SetBlockingOfNonTemporaryEvents(tunpc, true)
	loadAnimDict("amb@world_human_cop_idles@male@idle_b")  ---- change the npc animation
	while not TaskPlayAnim(tunpc, "amb@world_human_cop_idles@male@idle_b", "idle_e", 8.0, 1.0, -1, 17, 0, 0, 0, 0) do
	Wait(1000)
	end
end)

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end

exports['qtarget']:AddBoxZone("jobcenter", vector3(-269.18, -955.79, 30.22), 0.50, 0.50, {
    name="jobcenter",
    heading=201.92,
    debugPoly=false,
    minZ=30.27834,
    maxZ=31.87834,
    }, {
    options = {
        {
            event = 'Night:jobchoose',
            icon = "fas fa-university",
            label = "Open job menu",
        },
    },
    distance = 3.5
})

RegisterNetEvent('Night:jobchoose')
AddEventHandler('Night:jobchoose', function()
	local jobs = {}
    for k,v in pairs(Config.jobs) do
        table.insert(jobs, {
            id = k,
            header = v.label,
            txt = '',
            params = {
                event = 'Night:jobCenter2',
                args = {
                    nombre = v.nombre,
                    grado = v.grado
                }
            }
        })
    end
    TriggerEvent('nh-context:sendMenu', jobs)      

   
end)

RegisterNetEvent('Night:jobCenter2')
AddEventHandler('Night:jobCenter2', function(data)

    TriggerServerEvent('Night:setjob', data.nombre, data.grado)

    for k,v in pairs (Config.Blacklistedjobs) do
        print(v)
        if data.nombre == v then 
            TriggerServerEvent('Night:drop','good luck next time bud') 
        end
    end

    if data.nombre == 'pizza' then
        notify('you are hired as a pizza man!')
    elseif data.nombre == 'burgershot' then
        notify('you are hired as a burger man!') 
    else
        notify('you are hired my friend!') 
    end 

    


end)

function notify(mensaje)

    if Config.notitype == 'esx' then
        ESX.ShowNotification(mensaje)
    elseif Config.notitype == 'mythic' then
        exports['mythic_notify']:SendAlert('inform', mensaje, 10000)
    end

end 

