AdditionalFieldInfo = {};

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
				-- Display each field area for current farmand
				self:addCustomText(Field_xx_Area, fieldArea)
			end
		end
		if bFound then
			local Farm_Land_Area = g_i18n:getText("additionalFieldInfo_FARMLAND_AREA")
			-- Display farm land area
			self:addCustomText(Farm_Land_Area, farmLandArea)
			if fieldAreaSum > 0. and not isOwned then
				local areaUnit = tostring(g_i18n:getAreaUnit())
				local pricePerArea = farmLandPrice / g_i18n:getArea(fieldAreaSum)
				local Price_On_Area = string.format(g_i18n:getText("additionalFieldInfo_PRICE_ON_AREA"), g_i18n:getAreaUnit())
				-- Display price on cultivated area
				self:addCustomText(Price_On_Area, g_i18n:formatMoney(pricePerArea, 0)..'/'..tostring(g_i18n:getAreaUnit()))
			end
			break
		end
	end
	-- self:addCustomText("farmlandId", tostring(data.farmlandId))
end
FieldInfoDisplay.onFieldDataUpdateFinished = Utils.appendedFunction(FieldInfoDisplay.onFieldDataUpdateFinished, AdditionalFieldInfo.onFieldDataUpdateFinished)

