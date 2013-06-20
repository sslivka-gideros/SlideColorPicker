SlideColorPicker = Core.class(Sprite)

function SlideColorPicker:init()
	self.colors = {0xFF0000, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0xFF00FF, 0xFF0000}
	self.hue = Bitmap.new(Texture.new("hue.png", true))
	self.hue:setPosition(0, 0)
	self.arrows = Texture.new("arrows.png", true)
	self.hueArrows = Bitmap.new(self.arrows)
	self.hueArrows:setPosition(147, 0)
	self.brightnessBg = Sprite.new()
	self.brightness = Bitmap.new(Texture.new("brightness.png", true))
	self.brightness:setPosition(0, 53)
	self.brightnessArrows = Bitmap.new(self.arrows)
	self.brightnessArrows:setPosition(147, 53)
	
	self:addChild(self.hue)
	self:addChild(self.hueArrows)
	self:addChild(self:drawRec(0, 0, 306, 47, 1, 0x000000, 1, Shape.NONE, 0x000000, 1))
	self:addChild(self.brightnessBg)
	self:addChild(self.brightness)
	self:addChild(self.brightnessArrows)
	self:addChild(self:drawRec(0, 53, 306, 47, 1, 0x000000, 1, Shape.NONE, 0x000000, 1))
	
	self:addEventListener(Event.ADDED_TO_STAGE, self.onAddedToStage, self)
end

function SlideColorPicker:drawRec(x, y, w, h, bw, bc, ba, fs, fc, fa)
	local shape = Shape.new()
	shape:setLineStyle(bw, bc, ba)
	shape:setFillStyle(fs, fc, fa)
	shape:beginPath()
	shape:moveTo(x, y)
	shape:lineTo(x + w, y)
	shape:lineTo(x + w, y + h)
	shape:lineTo(x, y + h)
	shape:closePath()
	shape:endPath()
	return shape
end

function SlideColorPicker:onAddedToStage(e)
	self:removeEventListener(Event.ADDED_TO_STAGE, self.onAddedToStage, self)
	self:update()
	self:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
	self:addEventListener(Event.MOUSE_MOVE, self.onMouseMove, self)
	self:addEventListener(Event.MOUSE_UP, self.onMouseUp, self)
end

function SlideColorPicker:onMouseDown(e)
	local x, y = self:globalToLocal(e.x, e.y)
	if self.hue:hitTestPoint(e.x, e.y) or self.hueArrows:hitTestPoint(e.x, e.y) then
		self.hueArrows.isDragging = true
		self.hueArrows:setX(x - 6)
		self:update()
	end
	if self.brightness:hitTestPoint(e.x, e.y) or self.brightnessArrows:hitTestPoint(e.x, e.y) then
		self.brightnessArrows.isDragging = true
		self.brightnessArrows:setX(x - 6)
		self:update()
	end
end

function SlideColorPicker:onMouseMove(e)
	local x, y = self:globalToLocal(e.x, e.y)
	if self.hueArrows.isDragging then
		if x < 0 then
			self.hueArrows:setX(-6)
		elseif x > 306 then
			self.hueArrows:setX(300)
		else
			self.hueArrows:setX(x - 6)
		end
		self:update()
	end
	if self.brightnessArrows.isDragging then
		if x < 0 then
			self.brightnessArrows:setX(-6)
		elseif x > 306 then
			self.brightnessArrows:setX(300)
		else
			self.brightnessArrows:setX(x - 6)
		end
		self:update()
	end
end

function SlideColorPicker:onMouseUp(e)
	if self.hueArrows.isDragging then
		self.hueArrows.isDragging = false
	end
	if self.brightnessArrows.isDragging then
		self.brightnessArrows.isDragging = false
	end
end

function SlideColorPicker:hex2rbg(hex)
	local rgb, d = {}, {65536, 256, 1}
	for i = 1, 3 do
		rgb[i] = math.floor(hex/d[i])
		hex = math.fmod(hex, d[i])
	end
	return rgb[1], rgb[2], rgb[3]
end

function SlideColorPicker:rgb2hsl(r, g, b)
	r, g, b = r/255, g/255, b/255
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local h
	local s
	local l = (max + min)/2
	if max == min then
		h, s = 0, 0
	else
		local d = max - min
		if l > 0.5 then
			s = d/(2 - max - min)
		else 
			s = d/(max + min)
		end
		if max == r then
			if g < b then
				h = (g - b)/d + 6
			else
				h = (g - b)/d
			end
		elseif max == g then
			h = (b - r)/d + 2
		elseif max == b then
			h = (r - g)/d + 4
		end
		h = h/6
	end
	return math.floor(h*360 + 0.5), math.floor(s*100 + 0.5), math.floor(l*100 + 0.5)
end

function SlideColorPicker:hue2rgb(p, q, t)
	if t < 0 then t = t + 1 end
	if t > 1 then t = t - 1 end
	if t < 1/6 then return p + (q - p)*6*t end
	if t < 1/2 then return q end
	if t < 2/3 then return p + (q - p)*(2/3 - t)*6 end
	return p
end
 
function SlideColorPicker:hsl2rgb(h, s, l)
	h, s, l = h/360, s/100, l/100
	local r, g, b
	if s == 0 then
		r, g, b = 1, 1, l
	else
		local q
		if l < 0.5 then
			q = l*(1 + s)
		else
			q = l + s - l*s
		end
		local p = 2*l - q
		r = self:hue2rgb(p, q, h + 1/3)
		g = self:hue2rgb(p, q, h)
		b = self:hue2rgb(p, q, h - 1/3)
	end
	return math.floor(r*255 + 0.5), math.floor(g*255 + 0.5), math.floor(b*255 + 0.5)
end

function SlideColorPicker:round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function SlideColorPicker:ave(v1, v2, p)
	return v1 + self:round(p * (v2 - v1))
end

function SlideColorPicker:getHue()
	local i = math.floor((self.hueArrows:getX() + 6)/51) + 1
	local p = math.fmod((self.hueArrows:getX() + 6), 51)/51
	if i < 1 then
		return self.colors[1]
	end
	if i >= #self.colors then
		return self.colors[#self.colors]
	end
	local r1, g1, b1 = self:hex2rbg(self.colors[i])
	local r2, g2, b2 = self:hex2rbg(self.colors[i+1])
	local r = self:ave(r1, r2, p);
	local g = self:ave(g1, g2, p);
	local b = self:ave(b1, b2, p);
	return r*65536 + g*256 + b
end

function SlideColorPicker:getBrightness(color)
	self.brightnessBg:addChild(self:drawRec(0, 53, 306, 47, 0, 0x000000, 1, Shape.SOLID, color, 1))
	local r, g, b = self:hex2rbg(color)
	local h, s, l = self:rgb2hsl(r, g, b)
	local l = (self.brightnessArrows:getX()+6)/306*100
	r, g, b = self:hsl2rgb(h, s, l)
	return r*65536 + g*256 + b
end

function SlideColorPicker:update()
	self.e = Event.new("COLOR_CHANGED")
	self.currColor = self:getHue()
	self.currColor = self:getBrightness(self.currColor)
	self.e.color = self.currColor
	self:dispatchEvent(self.e)
end
