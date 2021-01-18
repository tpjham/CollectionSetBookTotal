CollectionSetBookTotal = {}

local ADDON_NAME = "CollectionSetBookTotal"
local ADDON_DISPLAY_NAME = "Item set total progress"

local UnlockedPiecesTable = {}

-- Used only for debugging
-- local tempAllItems, tempFoundItems

local tlw, texture, label
tlw = WINDOW_MANAGER:CreateTopLevelWindow()
tlw:SetDimensions(200,200)
tlw:SetAnchor(CENTER, ZO_CollectionsBook_TopLevel, CENTER, 0, 0)
tlw:SetHidden(true)
texture = WINDOW_MANAGER:CreateControl(nil, tlw, CT_STATUSBAR)
texture:SetAnchor(CENTER,tlw,TOPLEFT,0,-265)
ApplyTemplateToControl(texture,"ZO_ArrowProgressBarWithBG")
label = texture:GetNamedChild("Progress")
ZO_StatusBar_SetGradientColor(texture, ZO_XP_BAR_GRADIENT_COLORS)



texture:SetHandler("OnValueChanged", function(value)
	-- These do nothing for the time being, they just seem to be required by SetValue and SetMinMax 
end)



texture:SetHandler("OnMinMaxValueChanged", function (_, newMin, newMax)
	-- These do nothing for the time being, they just seem to be required by SetValue and SetMinMax
end)


---- Provided by code65536
local function GetCollectionStatus( )
	local collected = 0
	local total = 0
	local setId = GetNextItemSetCollectionId()
	while (setId) do
		local setSize = GetNumItemSetCollectionPieces(setId)
		if (setSize > 0) then
			collected = collected + GetNumItemSetCollectionSlotsUnlocked(setId)
			total = total + setSize
		end
		setId = GetNextItemSetCollectionId(setId)
	end

	return collected, total
end
----

local function RefreshFoundItems (setItemId, slotsJustUnlockedMask)
	local foundItems, allItems = GetCollectionStatus()

	texture:SetMinMax(0, allItems)
	texture:SetValue(foundItems)
	label:SetText(zo_strformat(SI_ITEM_SETS_BOOK_CATEGORY_PROGRESS, foundItems, allItems) .. "  (" .. tostring(math.floor((foundItems / allItems)*100)) .. "%)")
	
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED,	RefreshFoundItems)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ITEM_SET_COLLECTION_UPDATED,	RefreshFoundItems)



local function InitializeSetBookProgress()
	
	local fragment = ZO_HUDFadeSceneFragment:New(tlw, 0, 0)
	
	--add my fragment to scenes:
	SCENE_MANAGER:GetScene("itemSetsBook"):AddFragment(fragment)
end



local function OnAddOnLoaded(_, addOnName)
	if addOnName == ADDON_NAME then
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

		-- Crude debugging commands
		-- SLASH_COMMANDS["/debugcollectionpostfound"] = function () 
		-- 																	d("Found " .. tostring(tempFoundItems) .. " of " .. tostring(tempAllItems))
		-- 																end
		-- SLASH_COMMANDS["/debugcollectionsetmax"] = function (newMaximum)
		-- 																		texture:SetMinMax(0, newMaximum)
		-- 																		label:SetText(zo_strformat(SI_ITEM_SETS_BOOK_CATEGORY_PROGRESS, tempFoundItems, newMaximum) .. "  (" .. tostring(math.floor((tempFoundItems / newMaximum)*100)) .. "%)")
		-- 																		d("Max changed to " .. tostring(newMaximum))
		-- 																end
		-- SLASH_COMMANDS["/debugcollectionsetbarvalue"] = function (newValue)
		-- 																		d("Bar value set")
		-- 																		texture:SetValue(newValue)
		-- 																end
		
		InitializeSetBookProgress()
	end
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

