Safes = {}


MySQL.ready(function()
    local database = MySQL.Sync.fetchAll('SELECT * FROM owned_safes')
    for k, v in pairs(database) do
        local id = v.id
        local identifier = v.owner
		local x = v.x
		local y = v.y
		local z = v.z
		local heading = v.heading
		local cracked = v.cracked
		local access_list = json.decode(v.access_list)
        Safes[id] = {
            id = id,
            owner = identifier,
			x = x,
			y = y,
			z = z,
			heading = heading,
			cracked = cracked,
			access_list = access_list,
        }
    end
    Citizen.Wait(100)
    updateSafes()
end)

ESX.RegisterUsableItem('owned_safe', function(source)
	local _source = source
	TriggerClientEvent("hyon_owned_safes:use_safe", _source)
	local xPlayer = ESX.GetPlayerFromId(_source)
	local player_ped  = GetPlayerPed(_source)
	local coords = GetEntityCoords(player_ped)
	local _coords = GetOffsetFromEntityInWorldCoords(player_ped, 0.0, 1.0, 0.0)
	local _heading = GetEntityHeading(player_ped)

	Citizen.Wait(100)
	xPlayer.removeInventoryItem("owned_safe", 1)
	local id = #Safes+1
	local identifier = xPlayer.getIdentifier()
	local x = _coords.x 
	local y = _coords.y
	local z = _coords.z
	local heading = _heading
	local cracked = "false"
	local access_list = {}
	Citizen.Wait(100)

	MySQL.Async.insert('INSERT INTO owned_safes (id, owner, x, y, z, heading, cracked, access_list) VALUES (@id, @owner, @x, @y, @z, @heading, @cracked, @access_list)',
    {['id'] = id, ['owner'] = identifier, ['x'] = x, ['y'] = y, ['z'] = z, ['heading'] = heading, ['cracked'] = cracked, ['access_list'] = json.encode(access_list)},
        function() 
            Safes[id] = {
            id = id,
            owner = identifier,
			x = x,
			y = y,
			z = z,
			heading = heading,
			cracked = cracked,
			access_list = access_list,
            }
			TriggerClientEvent('esx:showNotification', _source, Config.Locales.place_safe, "success")
            updateSafes()
		end)
end)


RegisterNetEvent("hyon_owned_safes:remove_wedding_gun")
AddEventHandler("hyon_owned_safes:remove_wedding_gun", function(safeid)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	Citizen.Wait(100)
	xPlayer.removeInventoryItem(Config.Items_crack_safe, 1)
end)

RegisterNetEvent("hyon_owned_safes:cracked_safe")
AddEventHandler("hyon_owned_safes:cracked_safe", function(safeid)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier =  ESX.GetPlayerFromId(src).identifier
	local _id = safeid
	local _cracked = "true"
	local safe_id = nil
	for i = 1 , #Safes do
		if Safes[i].id == _id then
		safe_id = i
		end
	end
	Citizen.Wait(100)
	MySQL.Async.insert('UPDATE owned_safes SET cracked = @cracked WHERE id = @id',
    {['id'] = _id, ['cracked'] = _cracked},
        function() 
			Safes[safe_id].cracked = _cracked
            updateSafes()
		end)
end)

RegisterNetEvent("hyon_owned_safes:repair_safe_")
AddEventHandler("hyon_owned_safes:repair_safe_", function(safeid)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier =  ESX.GetPlayerFromId(src).identifier
	local _id = safeid
	local _cracked = "false"
	local safe_id = nil
	for i = 1 , #Safes do
		if Safes[i].id == _id then
		safe_id = i
		end
	end
	Citizen.Wait(100)
	MySQL.Async.insert('UPDATE owned_safes SET cracked = @cracked WHERE id = @id',
    {['id'] = _id, ['cracked'] = _cracked},
        function() 
			Safes[safe_id].cracked = _cracked
            updateSafes()
		end)
end)

RegisterNetEvent("hyon_owned_safes:add_allow_list")
AddEventHandler("hyon_owned_safes:add_allow_list", function(safeid, plid)
    local src = source
	local allow_src = plid
	local _id = safeid
    local xPlayer = ESX.GetPlayerFromId(src)
	local allowid = ESX.GetPlayerFromId(allow_src)
	local allow_identifier = ESX.GetPlayerFromId(allow_src).identifier
    local identifier =  ESX.GetPlayerFromId(src).identifier
	local safe_id = nil
	for i = 1 , #Safes do
		if Safes[i].id == _id then
		safe_id = i
		end
	end
	Citizen.Wait(100)
	local newlist = Safes[_id].access_list
	table.insert(newlist, allow_identifier)
	MySQL.Async.insert('UPDATE owned_safes SET access_list = @access_list WHERE id = @id',
    {['id'] = _id, ['access_list'] = json.encode(newlist)},
        function() 
			Safes[safe_id].access_list = newlist
            updateSafes()
		end)
end)

RegisterNetEvent("hyon_owned_safes:remove_allow_list")
AddEventHandler("hyon_owned_safes:remove_allow_list", function(safeid, plidentifier)
    local src = source
	local allow_src = plidentifier
	local _id = safeid
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier =  ESX.GetPlayerFromId(src).identifier
	local safe_id = nil
	local remove_id = nil
	for i = 1 , #Safes do
		if Safes[i].id == _id then
		safe_id = i
		end
	end
	Citizen.Wait(100)
	local newlist = Safes[_id].access_list
	for i = 1, #Safes[safe_id].access_list do
		if Safes[safe_id].access_list[i] == allow_src then
		removeid_= i
		end
	end
	
	table.remove(newlist, removeid)
	MySQL.Async.insert('UPDATE owned_safes SET access_list = @access_list WHERE id = @id',
    {['id'] = _id, ['access_list'] = json.encode(newlist)},
        function() 
			Safes[safe_id].access_list = newlist
            updateSafes()
		end)
end)

RegisterNetEvent("hyon_owned_safes:open_safe")
AddEventHandler("hyon_owned_safes:open_safe", function(safeid)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier =  ESX.GetPlayerFromId(src).identifier

    MySQL.Async.fetchAll('SELECT id FROM owned_safes WHERE id = @id',
    { 
      ['@id'] =	safeid
    }, 
    function()
		local nameid = 'owned_safe'
		local newnameid = nameid .. " id:" .. safeid
        exports.ox_inventory:RegisterStash(newnameid, Config.Locales.open_safe_stash_title, Config.SafeSlots, Config.SafeWeight, Safes[safeid].owner)
        TriggerClientEvent("hyon_owned_safes:open_thesafe", src, newnameid)
    end)
end)

RegisterNetEvent("hyon_owned_safes:pick_up_safe")
AddEventHandler("hyon_owned_safes:pick_up_safe", function(safeid)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier =  ESX.GetPlayerFromId(src).identifier
	local nameid = 'owned_safe'
	local newnameid = nameid .. " id:" .. safeid
	local amount = 0
	for i = 1, Config.SafeSlots do
		exports.ox_inventory:GetSlot(newnameid, i)
			if exports.ox_inventory:GetSlot(newnameid, i) ~= nil then
				amount = amount+1
			end
	end
	Citizen.Wait(100)
	if amount == 0 then
    MySQL.Async.execute("DELETE FROM owned_safes WHERE id = @id", {
        ["id"] = safeid
    }, function()
	TriggerClientEvent("hyon_owned_safes:delete_safe", src, safeid)
	Citizen.Wait(10)
	xPlayer.addInventoryItem('owned_safe', 1)
	for i = 1 , #Safes do
		if Safes[i].id == safeid then
			table.remove(Safes, i)
		end
	end
	updateSafes()
    end)
	else
		TriggerClientEvent('esx:showNotification', src, Config.Locales.noempty, "error")
	end
	
end)


function getEntityMatrix(element)
    local rot = GetEntityRotation(element) -- ZXY
    local rx, ry, rz = rot.x, rot.y, rot.z
    rx, ry, rz = math.rad(rx), math.rad(ry), math.rad(rz)
    local matrix = {}
    matrix[1] = {}
    matrix[1][1] = math.cos(rz)*math.cos(ry) - math.sin(rz)*math.sin(rx)*math.sin(ry)
    matrix[1][2] = math.cos(ry)*math.sin(rz) + math.cos(rz)*math.sin(rx)*math.sin(ry)
    matrix[1][3] = -math.cos(rx)*math.sin(ry)
    matrix[1][4] = 1
    
    matrix[2] = {}
    matrix[2][1] = -math.cos(rx)*math.sin(rz)
    matrix[2][2] = math.cos(rz)*math.cos(rx)
    matrix[2][3] = math.sin(rx)
    matrix[2][4] = 1
	
    matrix[3] = {}
    matrix[3][1] = math.cos(rz)*math.sin(ry) + math.cos(ry)*math.sin(rz)*math.sin(rx)
    matrix[3][2] = math.sin(rz)*math.sin(ry) - math.cos(rz)*math.cos(ry)*math.sin(rx)
    matrix[3][3] = math.cos(rx)*math.cos(ry)
    matrix[3][4] = 1
	
    matrix[4] = {}
    local pos = GetEntityCoords(element)
    matrix[4][1], matrix[4][2], matrix[4][3] = pos.x, pos.y, pos.z - 1.0
    matrix[4][4] = 1
	
    return matrix
end

function GetOffsetFromEntityInWorldCoords(entity, offX, offY, offZ)
    local m = getEntityMatrix(entity)
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return vector3(x, y, z)
end


RegisterNetEvent("esx:playerLoaded", function(source, xPlayer)
    TriggerClientEvent("hyon_owned_safes:updateClientData", source, _G["Safes"])
end)

function updateSafes()
    TriggerClientEvent("hyon_owned_safes:updateClientData", -1, _G["Safes"])
end