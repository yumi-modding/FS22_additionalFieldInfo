AdditionalFieldInfo = {};

function AdditionalFieldInfo:setFruitType(fruitTypeIndex, fruitGrowthState)
	if fruitTypeIndex > 0 then
		self.fruitType = self.fruitTypeManager:getFruitTypeByIndex(fruitTypeIndex)
		-- print("Seed usage: "..tostring(self.fruitType.seedUsagePerSqm * 10000))
		if fruitGrowthState >= self.fruitType.minHarvestingGrowthState + 1 and fruitGrowthState <= self.fruitType.maxHarvestingGrowthState + 1 then
			-- local pixelToSqm = g_currentMission:getFruitPixelsToSqm()
			local literPerSqm = self.fruitType.literPerSqm
			-- print("literPerSqm "..tostring(literPerSqm))
			-- print("pixelToSqm "..tostring(pixelToSqm))
			local threshingScale = 1	-- seems not used from gdn lua doc
			self.potentialHarvestQty = literPerSqm * threshingScale
		else
			self.potentialHarvestQty = nil
		end
	end
end
FieldInfoDisplay.setFruitType = Utils.prependedFunction(FieldInfoDisplay.setFruitType, AdditionalFieldInfo.setFruitType)

function AdditionalFieldInfo:onFieldDataUpdateFinished(data)
	if data == nil then return; end

	-- if self.displayDebug == nil  then self.displayDebug = true end
	-- if self.displayDebug then
	-- 	DebugUtil.printTableRecursively(g_i18n, " ", 1, 2);
	-- 	self.displayDebug = false
	-- end

	self:clearCustomText()
	for _, farmLand in pairs(g_fieldManager.farmlandIdFieldMapping) do
		local bFound = false
		local farmLandArea = 0.
		local fieldAreaSum = 0.
		local farmLandPrice = 0.
		local isOwned = false
		for _, field in pairs(farmLand) do
			if field.farmland.id == data.farmlandId then
				bFound = true
				local fieldArea =  g_i18n:formatArea(field.fieldArea, 2)
				fieldAreaSum = fieldAreaSum + field.fieldArea
				farmLandArea =  g_i18n:formatArea(field.farmland.areaInHa, 2)
				farmLandPrice = field.farmland.price
				isOwned = field.farmland.isOwned
				local Field_xx_Area = string.format(g_i18n:getText("additionalFieldInfo_FIELD_AREA"), field.fieldId)
				-- Display Area of each field in the current land
				self:addCustomText(Field_xx_Area, fieldArea)
				if self.potentialHarvestQty ~= nil and self.fruitType ~= nil then
					-- local oldmultiplier = g_currentMission:getHarvestScaleMultiplier(self.fruitType, data.fertilizerFactor, data.plowFactor, data.cultivatorFactor, data.weedFactor)
					-- print("oldmultiplier "..tostring(oldmultiplier))
					local multiplier = g_currentMission:getHarvestScaleMultiplier(self.fruitType, data.fertilizerFactor, data.needsPlowFactor, data.needsLimeFactor, data.weedFactor)
					multiplier = 1.1 * multiplier -- Add 10% more for now since it looks like prediction are always less than real yield
					-- print("multiplier "..tostring(multiplier))
					local fillType = self.fruitTypeManager:getFillTypeByFruitTypeIndex(self.fruitType.index)
					local massPerLiter = fillType.massPerLiter

					-- Display Potential harvest quantity
					local Potential_Harvest = g_i18n:getText("additionalFieldInfo_POTENTIAL_HARVEST")
					local potentialHarvestQty = self.potentialHarvestQty * field.fieldArea * multiplier * 10000 -- ha to sqm
					self:addCustomText(Potential_Harvest, g_i18n:formatVolume(potentialHarvestQty, 0))

					-- Display Potential yield
					local Potential_Yield = g_i18n:getText("additionalFieldInfo_POTENTIAL_YIELD")
					local potentialYield = (potentialHarvestQty * massPerLiter) / g_i18n:getArea(field.fieldArea)
					self:addCustomText(Potential_Yield, string.format("%1.2f T/"..tostring(g_i18n:getAreaUnit()), potentialYield))

				end
			end
		end
		if bFound then
			local Farm_Land_Area = g_i18n:getText("additionalFieldInfo_FARMLAND_AREA")
			-- Display Current land area
			self:addCustomText(Farm_Land_Area, farmLandArea)
			if fieldAreaSum > 0. and not isOwned then
				local areaUnit = tostring(g_i18n:getAreaUnit())
				local pricePerArea = farmLandPrice / g_i18n:getArea(fieldAreaSum)
				local Price_On_Area = string.format(g_i18n:getText("additionalFieldInfo_PRICE_ON_AREA"), g_i18n:getAreaUnit())
				-- Display Price per ha (per ac) of the cultivated area on land you don't own
				self:addCustomText(Price_On_Area, g_i18n:formatMoney(pricePerArea, 0)..'/'..tostring(g_i18n:getAreaUnit()))
			end
			break
		end
	end
	-- self:addCustomText("farmlandId", tostring(data.farmlandId))
end
FieldInfoDisplay.onFieldDataUpdateFinished = Utils.appendedFunction(FieldInfoDisplay.onFieldDataUpdateFinished, AdditionalFieldInfo.onFieldDataUpdateFinished)

