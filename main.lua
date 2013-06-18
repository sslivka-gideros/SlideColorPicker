local slideColorPicker = SlideColorPicker.new()
stage:addChild(slideColorPicker)
slideColorPicker:setPosition(application:getDeviceWidth()/2 - slideColorPicker:getWidth()/2, 5)

function onColorChanged(e)
	application:setBackgroundColor(e.color)
end
slideColorPicker:addEventListener("COLOR_CHANGED", onColorChanged)

