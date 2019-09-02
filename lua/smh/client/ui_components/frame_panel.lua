
local Rx = SMH.Include("rxlua/rx.lua");
local RxUtils = SMH.Include("shared/rxutils.lua");

local function Paint(size, frameArea, zoom, scrollOffset, timelineLength)
	local width, height = unpack(size);
	local startX, endX = unpack(frameArea);

	local frameWidth = (endX - startX) / zoom;

	surface.SetDrawColor(255, 255, 255, 255);

	for i = 0, zoom do
		if scrollOffset + i < timelineLength then
			local x = startX + frameWidth * i;
			surface.DrawLine(x, 6, x, height - 6);
		end
	end
end

local function Setup(parent)

	local panel = vgui.Create("DPanel", parent);

	panel:SetBackgroundColor(Color(64, 64, 64, 64));
	panel.TimelineLength = 100;

	local scrollBar = vgui.Create("DPanel", panel);
	scrollBar.Paint = function(self, w, h) derma.SkinHook("Paint", "ScrollBarGrip", self, w, h) end

	local scrollBtnLeft = vgui.Create("DButton", panel);
	scrollBtnLeft:SetText("");
	scrollBtnLeft.Paint = function(self, w, h) derma.SkinHook("Paint", "ButtonLeft", self, w, h) end

	local scrollBtnRight = vgui.Create("DButton", panel);
	scrollBtnRight:SetText("");
	scrollBtnRight.Paint = function(self, w, h) derma.SkinHook("Paint", "ButtonRight", self, w, h) end

	local scrollBarAreaX = 0;
	local scrollBarAreaY = 0;
	local scrollBarAreaWidth = 0;
	local scrollBarAreaHeight = 0;

	local layoutChangedStream = Rx.Subject.create();

	local basePerformLayout = panel.PerformLayout;
	panel.PerformLayout = function(self, width, height)
		
		local scrollPadding = 18;
		local scrollHeight = 12;
		local scrollPosY = panel:GetTall() - scrollHeight;

		scrollBarAreaX, scrollBarAreaY = scrollPadding, scrollPosY;
		scrollBarAreaWidth, scrollBarAreaHeight = panel:GetWide() - scrollPadding * 2, scrollHeight;

		scrollBtnLeft:SetPos(scrollPadding - 12, scrollPosY);
		scrollBtnLeft:SetSize(12, scrollHeight);

		scrollBtnRight:SetPos(scrollPadding + scrollBarAreaWidth, scrollPosY);
		scrollBtnRight:SetSize(12, scrollHeight);

		layoutChangedStream();

	end

	-- VGUI binds

	local _, mousePressStream = RxUtils.bindDPanel(panel, nil, "OnMousePressed");
	local _, mouseScrollStream = RxUtils.bindDPanel(panel, nil, "OnMouseWheeled");

	local _, paintStream = RxUtils.bindDPanel(panel, nil, "Paint");

	local _, scrollBarMousePressStream = RxUtils.bindDPanel(scrollBar, nil, "OnMousePressed");
	local _, scrollBarMouseReleaseStream = RxUtils.bindDPanel(scrollBar, nil, "OnMouseReleased");
	local _, scrollBarMouseMoveStream = RxUtils.bindDPanel(scrollBar, nil, "OnCursorMoved");
	local scrollBarPosStream, _ = RxUtils.bindDPanel(scrollBar, "SetPos", nil);
	local scrollBarSizeStream, _ = RxUtils.bindDPanel(scrollBar, "SetSize", nil);

	local _, scrollBtnRightPressStream = RxUtils.bindDPanel(scrollBtnRight, nil, "DoClick");
	local _, scrollBtnLeftPressStream = RxUtils.bindDPanel(scrollBtnLeft, nil, "DoClick");

	-- Scroll bar logic

	local timelineLengthStream = Rx.BehaviorSubject.create(1);
	local zoomStream = Rx.BehaviorSubject.create(100);
	local scrollOffsetStream = Rx.BehaviorSubject.create(0);

	local transformScrollBarStream = timelineLengthStream:combineLatest(zoomStream, scrollOffsetStream, layoutChangedStream)
		:map(function(timelineLength, zoom, scrollOffset)
			if timelineLength == zoom then
				return scrollBarAreaX, scrollBarAreaY, scrollBarAreaWidth, scrollBarAreaHeight;
			end

			local barWidthPerc = zoom / timelineLength;
			barWidthPerc = barWidthPerc > 1 and 1 or barWidthPerc;

			local barXPerc = scrollOffset / (timelineLength - zoom);
			barXPerc = barXPerc < 0 and 0 or (barXPerc > 1 and 1 or barXPerc);

			local width = scrollBarAreaWidth * barWidthPerc;
			local height = scrollBarAreaHeight;
			local x = scrollBarAreaX + (scrollBarAreaWidth - width) * barXPerc;
			local y = scrollBarAreaY;

			return x, y, width, height;
		end);
	
	transformScrollBarStream:map(function(x, y, width, height) return x, y end):subscribe(scrollBarPosStream);
	transformScrollBarStream:map(function(x, y, width, height) return width, height end):subscribe(scrollBarSizeStream);

	local function handleScrollBarMovement(cursorPos, cursorXOffset, zoom, currentScrollOffset, timelineLength)
		local cursorX, _ = panel:CursorPos();
		local movePos = (cursorX - cursorXOffset) - scrollBarAreaX;

		local movableWidth = scrollBarAreaWidth - scrollBar:GetWide();
		if movableWidth ~= 0 then
			local numSteps = timelineLength - zoom;
			local targetScrollOffset = math.Round((movePos / movableWidth) * numSteps);

			if targetScrollOffset >= 0 and targetScrollOffset <= numSteps and targetScrollOffset ~= currentScrollOffset then
				scrollOffsetStream(targetScrollOffset);
			end
		elseif currentScrollOffset ~= 0 then
			scrollOffsetStream(0);
		end
	end

	local scrollBarLeftMousePressStream = scrollBarMousePressStream:filter(function(mousecode) return mousecode == MOUSE_LEFT end);
	local scrollBarLeftMouseReleaseStream = scrollBarMouseReleaseStream:filter(function(mousecode) return mousecode == MOUSE_LEFT end);
	scrollBarLeftMousePressStream
		:subscribe(function(mousecode)
			local cursorXOffset, _ = scrollBar:CursorPos();
			scrollBarMouseMoveStream:pack()
				:takeUntil(scrollBarLeftMouseReleaseStream)
				:with(Rx.Observable.of(cursorXOffset), zoomStream, scrollOffsetStream, timelineLengthStream)
				:subscribe(handleScrollBarMovement);
		end);
	scrollBarLeftMousePressStream:subscribe(function() scrollBar:MouseCapture(true) end);
	scrollBarLeftMouseReleaseStream:subscribe(function() scrollBar:MouseCapture(false) end);

	local zoomAddStream = Rx.Subject.create();
	
	zoomAddStream:with(zoomStream)
		:map(function(zoomAdd, zoom) return zoom + zoomAdd end)
		:map(function(zoom) return zoom > 500 and 500 or (zoom < 30 and 30 or zoom) end)
		:subscribe(zoomStream);

	mouseScrollStream:map(function(delta) return -delta end)
		:subscribe(zoomAddStream);

	local scrollOffsetAddStream = Rx.Subject.create();
	scrollOffsetAddStream:with(scrollOffsetStream)
		:map(function(scrollOffsetAdd, scrollOffset) return scrollOffset + scrollOffsetAdd end)
		:with(timelineLengthStream, zoomStream)
		:map(function(scrollOffset, timelineLength, zoom)
			return scrollOffset > (timelineLength - zoom) and (timelineLength - zoom) or (scrollOffset < 0 and 0 or scrollOffset) 
		end)
		:subscribe(scrollOffsetStream);

	scrollBtnLeftPressStream:map(function() return -1 end):subscribe(scrollOffsetAddStream);
	scrollBtnRightPressStream:map(function() return 1 end):subscribe(scrollOffsetAddStream);

	-- Other logic

	local sizeStream = Rx.Subject.create();
	
	sizeStream:subscribe(function(width, height) panel:SetSize(width, height) end);

	local frameAreaStream = Rx.BehaviorSubject.create(0, 1);

	local padding = 10;
	sizeStream
		:map(function(width, height)
			local startPoint = padding;
			local endPoint = width - padding;
			return startPoint, endPoint;
		end):subscribe(frameAreaStream);

	local clickPositionStream = mousePressStream:filter(function(mousecode) return mousecode == MOUSE_LEFT end)
		:with(frameAreaStream:pack(), zoomStream, scrollOffsetStream, timelineLengthStream)
		:map(function(mousecode, frameArea, zoom, scrollOffset, timelineLength)
			local startX, endX = unpack(frameArea);
			local posX, posY = panel:CursorPos();
	
			local targetX = posX - startX;
			local width = endX - startX;
			local framePosition = math.Round(scrollOffset + (targetX / width) * zoom);
			framePosition = framePosition < 0 and 0 or (framePosition >= timelineLength and timelineLength - 1 or framePosition);

			return framePosition;
		end);

	paintStream:pack():with(frameAreaStream:pack(), zoomStream, scrollOffsetStream, timelineLengthStream)
		:subscribe(Paint);

	return panel, {
		Input = {
			Size = sizeStream,
			TimelineLength = timelineLengthStream,
		},
		Output = {
			FrameArea = frameAreaStream,
			ClickPosition = clickPositionStream,
			ScrollOffset = scrollOffsetStream,
			Zoom = zoomStream,
		}
	};
	
end

return Setup;