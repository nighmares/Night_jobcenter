ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('Night:setjob')
AddEventHandler('Night:setjob', function(nombre,grado)
    local _source = source
	local xPlayer  = ESX.GetPlayerFromId(source)

    if xPlayer then
        xPlayer.setJob(nombre, grado)
       
    end    

end)    

