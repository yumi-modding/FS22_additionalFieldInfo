AdditionalFieldInfo = {};
AdditionalFieldInfo.PrecisionFarming = "FS22_precisionFarming"
AdditionalFieldInfo.InfoMenu = "FS22_InfoMenu"

function AdditionalFieldInfo:buildFarmlandsMapOverlay(selectedFarmland)
    -- print("AdditionalFieldInfo:buildFarmlandsMapOverlay")
    if selectedFarmland then
        local farmLandArea =  g_i18n:formatArea(selectedFarmland.areaInHa, 2)
        self.selectedFarmlandAreaInHa = farmLandArea
    end
end
MapOverlayGenerator.buildFarmlandsMapOverlay = Utils.appendedFunction(MapOverlayGenerator.buildFarmlandsMapOverlay, AdditionalFieldInfo.buildFarmlandsMapOverlay)

function AdditionalFieldInfo:onFarmlandOverlayFinished(a, b, c, d)
    -- print("AdditionalFieldInfo:onFarmlandOverlayFinished")
    if not g_modIsLoaded[AdditionalFieldInfo.InfoMenu] then
        if self.mapOverlayGenerator.selectedFarmlandAreaInHa then
            if self.areaText == nil then
                local areaLabel = self.farmlandValueText:clone(self)
                self.farmlandValueText.parent:addElement(areaLabel)
                -- areaLabel:setBold(false)
                areaLabel:setText(g_i18n:getText("additionalFieldInfo_AREA")..":")
                areaLabel:applyProfile("ingameMenuMapMoneyLabel")
                areaLabel:setTextColor(1, 1, 1, 1)
                self.areaLabel = areaLabel
                local areaText = self.farmlandValueText:clone(self)
                self.farmlandValueText.parent:addElement(areaText)
                areaText:setText(self.mapOverlayGenerator.selectedFarmlandAreaInHa)
                areaText:applyProfile(InGameMenuMapFrame.PROFILE.MONEY_VALUE_NEUTRAL)
                self.areaText = areaText
                -- areaLabel:setTextColor(1, 1, 1, 1)
                areaText:setPosition(0.06, 0.04)
                areaLabel:setPosition(0, 0.04)
                -- local selfX, selfY = areaLabel:getPosition()
                -- print(string.format("Label x: %s, y: %s", selfX, selfY))
                -- local selfX, selfY = areaText:getPosition()
                -- print(string.format("Text  x: %s, y: %s", selfX, selfY))
            else
                local areaText = self.areaText
                local areaLabel = self.areaLabel
                areaText:setVisible(false)
                areaLabel:setVisible(false)
                areaText:setPosition(0.06, 0.04)
                areaLabel:setPosition(0, 0.04)
                areaText:setText(self.mapOverlayGenerator.selectedFarmlandAreaInHa)
                areaText:setVisible(true)
                areaLabel:setVisible(true)
            end
        else
            if self.areaText then
                self:removeElement(self.areaText)
            end
            if self.areaLabel then
                self:removeElement(self.areaLabel)
            end
        end
    end
end
InGameMenuMapFrame.onFarmlandOverlayFinished = Utils.prependedFunction(InGameMenuMapFrame.onFarmlandOverlayFinished, AdditionalFieldInfo.onFarmlandOverlayFinished)

function AdditionalFieldInfo:setFruitType(fruitTypeIndex, fruitGrowthState)
    if fruitTypeIndex > 0 then
        self.fruitType = self.fruitTypeManager:getFruitTypeByIndex(fruitTypeIndex)
        -- print("Seed usage: "..tostring(self.fruitType.seedUsagePerSqm * 10000))
        if fruitGrowthState >= self.fruitType.minHarvestingGrowthState + 1 and fruitGrowthState <= self.fruitType.maxHarvestingGrowthState + 1 then
            -- local pixelToSqm = g_currentMission:getFruitPixelsToSqm()
            local literPerSqm = self.fruitType.literPerSqm
            -- print("literPerSqm "..tostring(literPerSqm))
            -- print("pixelToSqm "..tostring(pixelToSqm))
            local threshingScale = 1    -- seems not used from gdn lua doc
            self.potentialHarvestQty = literPerSqm * threshingScale
        else
            self.potentialHarvestQty = nil
        end
    end
end
-- FieldInfoDisplay.setFruitType = Utils.prependedFunction(FieldInfoDisplay.setFruitType, AdditionalFieldInfo.setFruitType)

function AdditionalFieldInfo:clearCustomText(fieldInfo, customRows)
    for i = 1, FieldInfoDisplay.MAX_ROW_COUNT do
        local row = fieldInfo.rows[i]

        if row.infoType == FieldInfoDisplay.INFO_TYPE.CUSTOM and customRows ~= nil then
            for j = 1, #customRows do
                if customRows[j] == i then
                    fieldInfo:clearInfoRow(row)
                    break
                end
            end
        end
    end
end

function AdditionalFieldInfo:fieldAddFarmland(data, box)
    -- print("AdditionalFieldInfo:fieldAddFarmland")
    if self.currentField == nil then self.currentField = 4 end
    
    for _, farmLand in pairs(g_fieldManager.farmlandIdFieldMapping) do
        local bFound = false
        local farmLandArea = 0.
        local fieldAreaSum = 0.
        local farmLandPrice = 0.
        local isOwned = false
        for fieldIndex, field in pairs(farmLand) do
            if field.farmland.id == data.farmlandId then
                if self.currentField > (4 * #farmLand + 2) then self.currentField = 4 end
                if fieldIndex == math.floor(self.currentField / 4) then
                    bFound = true
                    local fieldArea =  g_i18n:formatArea(field.fieldArea, 2)
                    fieldAreaSum = fieldAreaSum + field.fieldArea
                    farmLandArea =  g_i18n:formatArea(field.farmland.areaInHa, 2)
                    farmLandPrice = field.farmland.price
                    isOwned = field.farmland.isOwned
                    local Field_xx_Area = string.format(g_i18n:getText("additionalFieldInfo_FIELD_AREA"), field.fieldId)
                    if not g_modIsLoaded[AdditionalFieldInfo.PrecisionFarming] then
                        -- Display Area of each field in the current land
                        box:addLine(Field_xx_Area, fieldArea)
                    end
                end
            end
        end
        if bFound then
            self.currentField = self.currentField + 1
            local farmland = g_farmlandManager:getFarmlandById(data.farmlandId)
            if farmland ~= nil then
                local Farm_Land_Area = g_i18n:getText("additionalFieldInfo_FARMLAND_AREA")
                farmLandArea =  g_i18n:formatArea(farmland.areaInHa, 2)
                box:addLine(Farm_Land_Area, farmLandArea)
                if fieldAreaSum > 0. and not farmland.isOwned then
                    local areaUnit = tostring(g_i18n:getAreaUnit())
                    local pricePerArea = farmLandPrice / g_i18n:getArea(fieldAreaSum)
                    local Price_On_Area = string.format(g_i18n:getText("additionalFieldInfo_PRICE_ON_AREA"), g_i18n:getAreaUnit())
                    -- Display Price per ha (per ac) of the cultivated area on land you don't own
                    box:addLine(Price_On_Area, g_i18n:formatMoney(pricePerArea, 0)..'/'..areaUnit)
                end
            end
            break
        end
    end
end
PlayerHUDUpdater.fieldAddFarmland = Utils.appendedFunction(PlayerHUDUpdater.fieldAddFarmland, AdditionalFieldInfo.fieldAddFarmland)
