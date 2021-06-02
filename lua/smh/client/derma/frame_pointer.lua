
local Rx = SMH.Include("rxlua/rx.lua");
local RxUtils = SMH.Include("shared/rxutils.lua");

local function Create(parent, pointyBottom)

	local handleMovement;

	local panel = vgui.Create("DPanel", parent);
	
	panel:SetSize(8, 15);
	panel.Color = Color(0, 200, 0);
	panel.VerticalPosition = 0;

	local paintFunc = function(w, h, outlineColor)
		surface.SetDrawColor(panel.Color);
		surface.DrawRect(1, 1, w - 1, h - 1);

		surface.SetDrawColor(unpack(outlineColor));
		surface.DrawLine(0, 0, w, 0);
		surface.DrawLine(w, 0, w, h);
		surface.DrawLine(w, h, 0, h);
		surface.DrawLine(0, h, 0, 0);
	end

	local paintFuncPointy = function(w, h, outlineColor)
		surface.SetDrawColor(panel.Color);
		draw.NoTexture();
		surface.DrawRect(1, 1, w - 1, h - (h * 0.25));
		surface.DrawPoly({
			{ x = 1, y = h - (h * 0.25) },
			{ x = w - 1, y = h - (h * 0.25) },
			{ x = w / 2, y = h - 1 },
		});

		surface.SetDrawColor(unpack(outlineColor));
		surface.DrawLine(0, 0, w, 0);
		surface.DrawLine(w, 0, w, h - (h * 0.25));
		surface.DrawLine(w, h - (h * 0.25), w / 2, h);
		surface.DrawLine(w / 2, h, 0, h - (h * 0.25));
		surface.DrawLine(0, h - (h * 0.25), 0, 0);
	end

	-- VGUI binds

	local _, mousePressStream = RxUtils.bindDPanel(panel, nil, "OnMousePressed");
	local _, mouseReleaseStream = RxUtils.bindDPanel(panel, nil, "OnMouseReleased");
	local _, cursorMoveStream = RxUtils.bindDPanel(panel, nil, "OnCursorMoved");
	local _, paintStream = RxUtils.bindDPanel(panel, nil, "Paint");
	local mouseCaptureStream, _ = RxUtils.bindDPanel(panel, "MouseCapture", nil);

	-- Other logic

	local leftMousePressStream = mousePressStream:filter(function(mousecode) return mousecode == MOUSE_LEFT end);
	local leftMouseReleaseStream = mouseReleaseStream:filter(function(mousecode) return mousecode == MOUSE_LEFT end);
	local rightMousePressStream = mousePressStream
		:filter(function(mousecode) return mousecode == MOUSE_RIGHT and not input.IsKeyDown(KEY_LCONTROL) end);
	local middleMousePressStream = mousePressStream
		:filter(function(mousecode) return mousecode == MOUSE_MIDDLE or (mousecode == MOUSE_RIGHT and input.IsKeyDown(KEY_LCONTROL)) end);
	local middleMouseReleaseStream = mouseReleaseStream
		:filter(function(mousecode) return mousecode == MOUSE_MIDDLE or (mousecode == MOUSE_RIGHT and input.IsKeyDown(KEY_LCONTROL)) end);

	local startDragStream = Rx.Subject.create();
	
	leftMousePressStream
		:map(function(mousecode) return leftMouseReleaseStream end)
		:subscribe(startDragStream);

	startDragStream:subscribe(function(observable)
		mouseCaptureStream(true);
		observable:first():subscribe(function() mouseCaptureStream(false) end);
	end);

	local inputPositionStream = Rx.BehaviorSubject.create(0);
	local outputPositionStream = Rx.Subject.create();
	
	local combinedPositionStream = inputPositionStream:merge(outputPositionStream);
	
	local frameAreaStream = Rx.BehaviorSubject.create(0, 0);
	local timelineLengthStream = Rx.BehaviorSubject.create(0);
	local scrollOffsetStream = Rx.BehaviorSubject.create(0);
	local zoomStream = Rx.BehaviorSubject.create(100);

	Rx.Observable.combineLatest(combinedPositionStream, frameAreaStream:pack(), scrollOffsetStream, zoomStream)
		:subscribe(function(position, frameArea, scrollOffset, zoom)
			local startX, endX = unpack(frameArea);
			local height = panel.VerticalPosition;

			local frameAreaWidth = endX - startX;
			if position == nil then
				position = -1;
			end
			local positionWithOffset = position - scrollOffset;
			local x = startX + (positionWithOffset / zoom) * frameAreaWidth;
		
			panel:SetPos(x - panel:GetWide() / 2, height - panel:GetTall() / 2);
		end);

	local outlineColorStream = Rx.BehaviorSubject.create({0, 0, 0});
	startDragStream:subscribe(function(observable)
		outlineColorStream({255, 255, 255});
		observable:first():subscribe(function() outlineColorStream({0, 0, 0}) end);
	end);

	local filteredPaintStream = paintStream:pack()
		:with(outlineColorStream, combinedPositionStream, scrollOffsetStream, zoomStream)
		:filter(function(size, outlineColor, position, scrollOffset, zoom) return position >= scrollOffset and position <= (scrollOffset + zoom) end)
		:map(function(size, outlineColor, ...) return size[1], size[2], outlineColor end);
		
	if pointyBottom then
		filteredPaintStream:subscribe(paintFuncPointy);
	else
		filteredPaintStream:subscribe(paintFunc);
	end

	startDragStream:subscribe(function(observable)
		cursorMoveStream:pack():takeUntil(observable)
			:with(frameAreaStream:pack(), scrollOffsetStream, zoomStream, timelineLengthStream)
			:subscribe(handleMovement);
	end);

	local distinctOutputPositionStream = Rx.Subject.create();
	distinctOutputPositionStream:distinctUntilChanged():subscribe(outputPositionStream);
	
	handleMovement = function(cursorPos, frameArea, scrollOffset, zoom, totalFrames)
	
		local cursorX, cursorY;
		if parent ~= nil then 
			cursorX, cursorY = parent:CursorPos();
		else
			cursorX, cursorY = input.GetCursorPos();
		end
		
		local startX, endX = unpack(frameArea);
	
		local targetX = cursorX - startX;
		local width = endX - startX;

		local targetPos = math.Round(scrollOffset + (targetX / width) * zoom);
		targetPos = targetPos < 0 and 0 or (targetPos > totalFrames - 1 and totalFrames - 1 or targetPos);

		distinctOutputPositionStream(targetPos);
	
	end

	return panel, {
		Input = {
			Position = inputPositionStream,
			StartDrag = startDragStream,
			FrameArea = frameAreaStream,
			TimelineLength = timelineLengthStream,
			ScrollOffset = scrollOffsetStream,
			Zoom = zoomStream,
		},
		Output = {
			Position = outputPositionStream,
			LeftMousePress = leftMousePressStream,
			LeftMouseRelease = leftMouseReleaseStream,
			RightMousePress = rightMousePressStream,
			MiddleMousePress = middleMousePressStream,
			MiddleMouseRelease = middleMouseReleaseStream,
		}
	};
end

return Create;
