
local Rx = include("../../rxlua/rx.lua");

local function Setup(parent)

	local panel = vgui.Create("DPanel", parent);

	local function paintFunc(size, frameArea, timelineLength)
		local w, h = size[1], size[2];
		local startX, endX = frameArea[1], frameArea[2];
	
		local frameWidth = (endX - startX) / timelineLength;
	
		surface.SetDrawColor(255, 255, 255, 255);
	
		for i = 0, timelineLength do
			local x = startX + frameWidth * i;
			surface.DrawLine(x, 6, x, panel:GetTall() - 6);
		end
	
	end

	panel:SetBackgroundColor(Color(64, 64, 64, 64));
	panel.Length = 100;

	local mousePressStream = Rx.Subject.create();
	panel.OnMousePressed = function(self, mousecode) mousePressStream(mousecode) end

	local paintStream = Rx.Subject.create();
	panel.Paint = function(self, width, height) paintStream(width, height) end

	local frameAreaStream = Rx.BehaviorSubject.create({0, 1});

	local sizeStream = Rx.Subject.create();
	
	sizeStream:subscribe(function(size) panel:SetSize(unpack(size)) end);

	local padding = 10;
	sizeStream:map(function(size) return size[1] end)
		:map(function(width)
			local startPoint = padding;
			local endPoint = width - padding;
			return {startPoint, endPoint};
		end):subscribe(frameAreaStream);

	local timelineLengthStream = Rx.BehaviorSubject.create(1);

	local clickPositionStream = mousePressStream:filter(function(mousecode) return mousecode == MOUSE_LEFT end)
		:with(frameAreaStream, timelineLengthStream)
		:map(function(mousecode, frameArea, timelineLength)
			local startX, endX = frameArea[1], frameArea[2];
			local posX, posY = panel:CursorPos();
	
			local targetX = posX - startX;
			local width = endX - startX;
			local frameWidth = width / timelineLength;
	
			local targetPos = 0;
			for i = 0, timelineLength do
				local x = frameWidth * i;
				local diff = math.abs(x - targetX);
				if diff <= frameWidth / 2 then
					targetPos = i;
					break;
				elseif i == timelineLength and targetX > x then
					targetPos = timelineLength;
				end
			end

			return targetPos;
		end);

	paintStream:map(function(width, height) return {width, height} end)
		:with(frameAreaStream, timelineLengthStream):subscribe(paintFunc);

	return panel, {
		Input = {
			Size = sizeStream,
			TimelineLength = timelineLengthStream,
		},
		Output = {
			FrameArea = frameAreaStream,
			ClickPosition = clickPositionStream,
		}
	};
	
end

return Setup;