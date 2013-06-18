function hex2rbg(hex)
	local rgb, d = {}, {65536, 256, 1}
	for i = 1, 3 do
		rgb[i] = math.floor(hex/d[i])
		hex = math.fmod(hex, d[i])
	end
	return rgb[1], rgb[2], rgb[3]
end

function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function ave(v1, v2, p)
	return v1 + round(p * (v2 - v1))
end

function calculateColor(colors, pos, inc)
	local i = math.floor(pos/(255/inc)) + 1
	local p = math.fmod(pos, 255/inc)/(255/inc)
	if i < 1 then
		return colors[1]
	end
	if i >= #colors then
		return colors[#colors]
	end
	local r1, g1, b1 = hex2rbg(colors[i])
	local r2, g2, b2 = hex2rbg(colors[i+1])
	local r = ave(r1, r2, p);
	local g = ave(g1, g2, p);
	local b = ave(b1, b2, p);
	return r*65536 + g*256 + b
end

SlideColorPicker = Core.class(Sprite)

function SlideColorPicker:init()
	self.colors = {0xFF0000, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0xFF00FF, 0xFF0000}
	self.inc = 5
	self.p = Bitmap.new(Texture.new("palette.png", true))
	self.arrows = Bitmap.new(Texture.new("arrows.png", true))
	self.pBorder = Shape.new()
	self.pBorder:setLineStyle(1, 0x000000, 1)
	
	self.p:setPosition(1, 12)
	self:addChild(self.p)
	self.pBorder:beginPath()
	self.pBorder:moveTo(self.p:getX() - 1, self.p:getY())
	self.pBorder:lineTo(self.p:getX() + self.p:getWidth() - 1, self.p:getY())
	self.pBorder:lineTo(self.p:getX() + self.p:getWidth() - 1, self.p:getY() + self.p:getHeight() - 1)
	self.pBorder:lineTo(self.p:getX() - 1, self.p:getY() + self.p:getHeight() - 1)
	self.pBorder:closePath()
	self.pBorder:endPath()
	self:addChild(self.pBorder)
	self.arrows:setPosition(self.p:getWidth()/2 - 5, 0)
	self:addChild(self.arrows)
	self:addEventListener(Event.ADDED_TO_STAGE, self.onAddedToStage, self)
end

function SlideColorPicker:onAddedToStage(e)
	self:removeEventListener(Event.ADDED_TO_STAGE, self.onAddedToStage, self)
	self:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
end

function SlideColorPicker:onMouseDown(e)
	local x, y = self:globalToLocal(e.x, e.y)
	if self.p:hitTestPoint(e.x, e.y) or self.arrows:hitTestPoint(e.x, e.y) then
		self.arrows.isDragging = true
		self.arrows:setX(x - self.arrows:getWidth()/2)
		self:changeColor()
		self:addEventListener(Event.MOUSE_MOVE, self.onMouseMove, self)
		self:addEventListener(Event.MOUSE_UP, self.onMouseUp, self)
	end
end

function SlideColorPicker:onMouseMove(e)
	local x, y = self:globalToLocal(e.x, e.y)
	if self.arrows.isDragging then
		if x < self.p:getX() then
			self.arrows:setX(self.p:getX() - self.arrows:getWidth()/2)
		elseif x > self.p:getX() + self.p:getWidth() then
			self.arrows:setX(self.p:getX() + self.p:getWidth() - self.arrows:getWidth()/2)
		else
			self.arrows:setX(x - self.arrows:getWidth()/2)
		end
		self:changeColor()
	end
end

function SlideColorPicker:onMouseUp(e)
	if self.arrows.isDragging then
		self.arrows.isDragging = false
		self:removeEventListener(Event.MOUSE_MOVE, self.onMouseMove, self)
		self:removeEventListener(Event.MOUSE_UP, self.onMouseUp, self)
	end
end

function SlideColorPicker:changeColor()
	self.e = Event.new("COLOR_CHANGED")
	self.e.color = calculateColor(self.colors, self.arrows:getX() + 5, 5)
	self:dispatchEvent(self.e)
end
