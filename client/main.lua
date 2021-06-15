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


RegisterNetEvent('Night:jobs', function()
    TriggerEvent('nh-context:sendMenu', {
        {
            id = 1,
            header = "Escoger trabajo",
            txt = ""
        },
        {
            id = 2,
            header = "burger job",
            txt = "start: 100 for the day",
            params = {
                event = "Night:jobchoose",
                args = {
                    nombre = 'burgershot',
                    label = 'hamburgesas',
					grado = 0,
                    
                }
            }
        },
        {
            id = 3,
            header = "taco job",
            txt = "start: 100 for the day",
            params = {
                event = "Night:jobchoose",
                args = {
                    nombre = 'taco',
					grado = 0,
                    
                }
            }
        },
        {
            id = 4,
            header = "Police job",
            txt = "start: 200 for the day",
            params = {
                event = "Night:jobchoose",
                args = {
                    nombre = 'police',
					grado = 0,
                    
                }
            }
        },
        {
            id = 5,
            header = "ambulance",
            txt = "start: 50 for the day",
            params = {
                event = "Night:jobchoose",
                args = {
                    nombre = 'ambulance',
					grado = 0,
                    
                }
            }
        },
        {
            id = 6,
            header = "unemployed",
            txt = "Rent tribike",
            params = {
                event = "Night:jobchoose",
                args = {
                    nombre = 'unemployed',
					grado = 0,
                    
                }
            }
        },
        
    })
end)

Citizen.CreateThread(function()
    local biker = {
		`cs_nigel`
    }

    exports['bt-target']:AddTargetModel(biker, {
        options = {
            {
                event = 'Night:jobs',
                icon = 'fas fa-glass-martini-alt',
                label = "Open cycles menu"
            },
        },
        job = {'all'},
        distance = 1.5
    })
end)

RegisterNetEvent('Night:jobchoose')
AddEventHandler('Night:jobchoose', function(jobs)
	local nombre = jobs.nombre
	local grado = jobs.grado

	TriggerServerEvent('Night:setjob', nombre, grado)
    exports['mythic_notify']:SendAlert('inform', 'you are hired my friend!')

end)	