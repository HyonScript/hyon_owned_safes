PlayerData = {}
Citizen.CreateThread(function()
    while PlayerData.identifier == nil do
        PlayerData = ESX.GetPlayerData()
        Citizen.Wait(1)
    end
end)

Safes = {}
local own_safes = {}

RegisterNetEvent("hyon_owned_safes:updateClientData", function(server_safes)
    Safes = server_safes
end)

Citizen.CreateThread(function()
while true do
local wait = 1000
if #Safes > 0 then
	for k,v in ipairs(Safes) do
		local pPed = PlayerPedId()
		local playerco = GetEntityCoords(pPed)
		local coords = vec3(v.x, v.y, v.z)
		local distance = #(playerco - coords)
		local hash = GetHashKey(Config.SafeModel)
		if distance <= 40 then
			if Safes[k].object == nil then
			Citizen.Wait(100)
			Safes[k].object = CreateObject(hash, v.x, v.y, v.z, false, true, false)
			SetEntityHeading(Safes[k].object, v.heading)
			FreezeEntityPosition(Safes[k].object, true)
			SetEntityInvincible(Safes[k].object, true)
			SetBlockingOfNonTemporaryEvents(Safes[k].object, true)
			end
			if distance <= 2 then
			wait = 5
			DrawText3Ds(v.x, v.y, v.z+1, Config.Locales.openmenu)
			if IsControlJustReleased(0,38) then
			openmenu(v.id)
			end
			end
		elseif Safes[k].object ~= nil then
		DeleteEntity(Safes[k].object)
		Safes[k].object = nil
		end
	end
end
Citizen.Wait(wait)
end
end)

RegisterNetEvent("hyon_owned_safes:delete_safe")
AddEventHandler("hyon_owned_safes:delete_safe", function(safeid)
	for i = 1, #Safes do
		if Safes[i].id == safeid then
		DeleteEntity(Safes[i].object)
		end
	end
end)

RegisterNetEvent("hyon_owned_safes:open_thesafe")
AddEventHandler("hyon_owned_safes:open_thesafe", function(safeid)
   TriggerEvent('ox_inventory:openInventory', 'stash', safeid)
    Wait(2000)
    LoadAnimDict('anim@gangops@facility@servers@bodysearch@')
    TaskPlayAnim(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false )
end)

RegisterNetEvent("hyon_owned_safes:use_safe")
AddEventHandler("hyon_owned_safes:use_safe", function(safeid)
    Wait(100)
   LoadAnimDict('anim@gangops@facility@servers@bodysearch@')
    TaskPlayAnim(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false )
end)

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.30, 0.30)
    SetTextFont(22)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370

end
--local new_options = {}
function openmenu(id)
local _id = id
local pPed = PlayerPedId()
local _owner1 = true
local _owner2 = true
local _cracked = false
local _repair = true
local _count = exports.ox_inventory:Search('count', Config.Items_crack_safe)

local new_options = {}
local allow_options = {}
		local op = {
		icon = "fa fa-info",
		title = Config.Locales.menu_safe_id .. ": " .. _id,
		}
		table.insert(new_options, op)
		if PlayerData.identifier == Safes[_id].owner or Safes[_id].cracked == "true" then
		_owner1 = false
		end
		if PlayerData.identifier == Safes[_id].owner then
		_owner2 = false
		end
		for i = 1, #Safes[_id].access_list do
			if Safes[_id].access_list[i] == PlayerData.identifier then
			_owner = false
			end
		end
		if Safes[_id].cracked == "true" then
		_cracked = true
		_repair = false
		end
		local op1 = {
		icon = "fa fa-lock-open",
		title = Config.Locales.menu_open_safe,
		disabled = _owner1,
		onSelect = function(args)
		TriggerServerEvent("hyon_owned_safes:open_safe", _id)
		end,
		}
		table.insert(new_options, op1)
		Citizen.Wait(10)
		local op2 = {
		icon = "fa fa-xmark",
		title = Config.Locales.menu_remove_safe,
		disabled = _owner2,
		onSelect = function(args)
		TriggerServerEvent("hyon_owned_safes:pick_up_safe", _id)
		end,
		}
		table.insert(new_options, op2)
		
		Citizen.Wait(10)
		local op5 = {
		icon = "fa fa-list",
		title = Config.Locales._allow_list,
		menu = 'allow_list',
		disabled = _owner2,
		}
		table.insert(new_options, op5)
		
		if Config.Safes_Crack then
		local op3 = {
		icon = "fa fa-xmark",
		title = Config.Locales.crack_the_safe,
		disabled = _cracked,
		onSelect = function(args)
		lib.hideContext(onExit)
		Citizen.Wait(1000)
		if _count > 0 then
		FreezeEntityPosition(pPed, true)
		TaskStartScenarioInPlace(pPed, 'WORLD_HUMAN_WELDING', 0, true)
			local success = lib.skillCheck({Config.SkillCheck1, Config.SkillCheck2, Config.SkillCheck3})
				if success == true then
				ClearPedTasksImmediately(pPed)
				FreezeEntityPosition(pPed, false)
				TriggerEvent("ESX:Notify", "succes", 3000, Config.Locales.notif_cracked)
				if Config.remove_item then
					TriggerServerEvent("hyon_owned_safes:remove_wedding_gun", _id)
				end
				TriggerServerEvent("hyon_owned_safes:cracked_safe", _id)
				else
				if Config.remove_item then
					TriggerServerEvent("hyon_owned_safes:remove_wedding_gun", _id)
				end
				TriggerEvent("ESX:Notify", "error", 3000, Config.Locales.failed_crack)
				ClearPedTasksImmediately(pPed)
				FreezeEntityPosition(pPed, false)
				end
		else
			TriggerEvent("ESX:Notify", "error", 3000, Config.Locales.no_item)
		end
		end,
		}
		table.insert(new_options, op3)
		end
		if Config.Safes_Crack then
		local op4 = {
		icon = "fa fa-screwdriver-wrench",
		title = Config.Locales.repair_safe,
		disabled = _repair,
		onSelect = function(args)
		FreezeEntityPosition(pPed, true)
		LoadAnimDict('anim@gangops@facility@servers@bodysearch@')
		TaskPlayAnim(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false )
		Citizen.Wait(2000)
		FreezeEntityPosition(pPed, false)
		TriggerEvent("ESX:Notify", "succes", 3000, Config.Locales.notif_cracked)
		TriggerServerEvent("hyon_owned_safes:repair_safe_", _id)
		end,
		}
		table.insert(new_options, op4)
		end
		local ap1 = {
		icon = "fa fa-plus",
		title = Config.Locales.add_allow_list,
		disabled = _owner2,
		onSelect = function(args)
		local input = lib.inputDialog(Config.Locales.add_allow_list, {Config.Locales.player_id})

		if not input then return end
		local play_er_id = tonumber(input[1])
		--Bugged wait for update
		--TriggerServerEvent("hyon_owned_safes:add_allow_list", _id, play_er_id)
		end,
		}
		table.insert(allow_options, ap1)
		
		if #Safes[id].access_list > 0 then
		local players = ESX.Game.GetPlayers()
			for i = 1, #Safes[id].access_list do
					for k,v in ipairs(players) do
						local target = GetPlayerServerId(v)
						local players2 = ESX.GetPlayerData(target)
						--print(json.encode(firstName))
						if players2.identifier == Safes[id].access_list[i] then
									local alp = {
									icon = "fa fa-minus",
									title = Config.Locales.remove_player .. " " .. players2.firstName .. " " .. players2.lastName,
									disabled = _owner2,
									onSelect = function(args)
									TriggerServerEvent("hyon_owned_safes:remove_allow_list", _id, players2.identifier)
									end,
									}
									table.insert(allow_options, alp)
						end
					end
			end
		end
lib.registerContext(
{
    id = 'open_menu',
    title = Config.Locales.menu_title,
    onExit = function()
    end,
    options = new_options,
    {
        id = 'allow_list',
        title = Config.Locales._allow_list,
        menu = 'open_menu',
        options = allow_options
    }
})
lib.showContext('open_menu')
end