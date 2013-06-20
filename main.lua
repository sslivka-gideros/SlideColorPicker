local slideColorPicker = SlideColorPicker.new()
function onColorChanged(e)
	application:setBackgroundColor(e.color)
end
slideColorPicker:addEventListener("COLOR_CHANGED", onColorChanged)
stage:addChild(slideColorPicker)
slideColorPicker:setPosition(application:getDeviceWidth()/2 - slideColorPicker:getWidth()/2, 5)
