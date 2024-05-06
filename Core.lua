local checkmarkIcon = "|TInterface\\RaidFrame\\ReadyCheck-Ready:0|t"
local select, UnitBuff, UnitDebuff, UnitAura, tonumber, strfind, hooksecurefunc, C_TransmogCollection =
    select, UnitBuff, UnitDebuff, UnitAura, tonumber, strfind, hooksecurefunc, C_TransmogCollection

local function addLine(self, message, hasCheckmark)
    local text = message
    if hasCheckmark then
        text = checkmarkIcon .. " " .. text
    end
    self:AddLine(text)
    self:Show()
end

local function hasTransmog(itemLink)
	local itemID = GetItemInfoFromHyperlink(itemLink)
    if C_TransmogCollection.PlayerHasTransmog(itemID) then return true end
    local appearanceID, sourceID = C_TransmogCollection.GetItemInfo(itemID)
    if sourceID and C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sourceID) then
        return true
    end
    if appearanceID then
        for i, sourceID in ipairs(C_TransmogCollection.GetAllAppearanceSources(appearanceID)) do
            if C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sourceID) then
                return true
            end
        end
    end
    return false
end

local function attachItemTooltip(self)
    local link = select(2, self:GetItem())
    if not link then return end

    local id = link:match("item:(%d+)")
    if not id then return end
    id = tonumber(id)

    C_Item.RequestLoadItemDataByID(id)

    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent = GetItemInfo(id)
    if not itemName then return end

    if itemQuality < 2 then return end
    if itemEquipLoc == "INVTYPE_AMMO" or itemEquipLoc == "INVTYPE_NECK" or
       itemEquipLoc == "INVTYPE_FINGER" or itemEquipLoc == "INVTYPE_TRINKET" or
       itemEquipLoc == "INVTYPE_BAG" or itemEquipLoc == "INVTYPE_QUIVER" or
       itemEquipLoc == "INVTYPE_RELIC" then return end

    if IsEquippableItem(itemLink) then
		if hasTransmog(itemLink) then
            addLine(self, "|cFFFFFFFFYou have this appearance|r", true)
        else
            addLine(self, "|cfff194f7New Appearance|r", false)
        end
    end
end

local TransmogTip = CreateFrame("Frame")
TransmogTip:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
TransmogTip:RegisterEvent("ADDON_LOADED")
TransmogTip:SetScript("OnEvent", function(self, event, arg1, ...) onEvent(self, event, arg1, ...) end);

function onEvent(self, event, arg1, ...)
  if event == "ADDON_LOADED" then
    if TransmogTipList == nil then
      TransmogTipList = {}
    end
  end
  if event== "PLAYER_EQUIPMENT_CHANGED" then
    itemID = GetInventoryItemID("player", arg1)
    if itemID then
      if not tContains(TransmogTipList, itemID) then
        table.insert(TransmogTipList, itemID)
      end
    end
  end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg, ...)
  if msg:find("TRANSMOG_SYNC:") then
    itemIDStr = string.gsub(msg, "TRANSMOG_SYNC:", "")
    itemID = tonumber(itemIDStr)
    if not tContains(TransmogTipList, itemID) then
      table.insert(TransmogTipList, itemID)
    end
    return true
  end
end)
GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
