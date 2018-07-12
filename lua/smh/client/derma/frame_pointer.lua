
local Rx = include("../../rxlua/rx.lua");

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

	local mousePressStream = Rx.Subject.create();
	panel.OnMousePressed = function(self, mousecode) mousePressStream(mousecode) end

	local mouseReleaseStream = Rx.Subject.create();
	panel.OnMouseReleased = function(self, mousecode) mouseReleaseStream(mousecode) end

	local cursorMoveStream = Rx.Subject.create();
	panel.OnCursorMoved = function(self, cursorX, cursorY) cursorMoveStream(cursorX, cursorY) end
	
	local paintStream = Rx.Subject.create();
	panel.Paint = function(self, width, height) paintStream(width, height) end

	local leftMousePressStream = mousePressStream:filter(function(mousecode) return mousecode == MOUSE_LEFT end);
	local leftMouseReleaseStream = mouseReleaseStream:filter(function(mousecode) return mousecode == MOUSE_LEFT end);
	local rightMousePressStream = mousePressStream
		:filter(function(mousecode) return mousecode == MOUSE_RIGHT and not input.IsKeyDown(KEY_LCONTROL) end);
	local middleMousePressStream = mousePressStream
		:filter(function(mousecode) return mousecode == MOUSE_MIDDLE or (mousecode == MOUSE_RIGHT and input.IsKeyDown(KEY_LCONTROL)) end);
	local middleMouseReleaseStream = mouseReleaseStream
		:filter(function(mousecode) return mousecode == MOUSE_MIDDLE or (mousecode == MOUSE_RIGHT and input.IsKeyDown(KEY_LCONTROL)) end);

	local startDragStream = Rx.Subject.create();

	local timelineLengthStream = Rx.BehaviorSubject.create(0);
	
	leftMousePressStream
		:map(function(mousecode) return leftMouseReleaseStream end)
		:subscribe(startDragStream);

	leftMousePressStream:subscribe(function(mousecode) panel:MouseCapture(true) end);
	leftMouseReleaseStream:subscribe(function(mousecode) panel:MouseCapture(false) end);

	local inputPositionStream = Rx.BehaviorSubject.create(0);
	local outputPositionStream = Rx.Subject.create();
	
	local combinedPositionStream = inputPositionStream:merge(outputPositionStream);
	
	local frameAreaStream = Rx.BehaviorSubject.create({0, 0});

	Rx.Observable.combineLatest(inputPositionStream, frameAreaStream, timelineLengthStream)
		:subscribe(function(position, frameArea, timelineLength)
			local startX, endX = frameArea[1], frameArea[2];
			local height = panel.VerticalPosition;
		
			local x = startX + (endX - startX) / timelineLength * position;
		
			panel:SetPos(x - panel:GetWide() / 2, height - panel:GetTall() / 2);
		end);

	local outlineColorStream = Rx.BehaviorSubject.create({0, 0, 0});
	leftMousePressStream:subscribe(function() outlineColorStream({255, 255, 255}) end);
	leftMouseReleaseStream:subscribe(function() outlineColorStream({0, 0, 0}) end);

	local filteredPaintStream = paintStream:map(function(width, height) return {width, height} end)
		:with(outlineColorStream, combinedPositionStream, timelineLengthStream)
		:filter(function(size, outlineColor, position, timelineLength) return position <= timelineLength end)
		:map(function(size, outlineColor, arg4, arg5) return size[1], size[2], outlineColor end);
	if pointyBottom then
		filteredPaintStream:subscribe(paintFuncPointy);
	else
		filteredPaintStream:subscribe(paintFunc);
	end

	startDragStream:subscribe(function(observable)
		cursorMoveStream:map(function(cursorX, cursorY) return {cursorX, cursorY} end)
			:with(frameAreaStream, timelineLengthStream)
			:takeUntil(observable)
			:subscribe(handleMovement);
	end);

	local distinctOutputPositionStream = Rx.Subject.create();
	distinctOutputPositionStream:distinctUntilChanged():subscribe(outputPositionStream);
	
	handleMovement = function(cursorPos, frameArea, totalFrames)
	
		local cursorX, cursorY = unpack(cursorPos);
		local startX, endX = unpack(frameArea);
		local posX, posY = panel:GetPos();
	
		local targetX = (posX + panel:GetWide() / 2) + cursorX - startX;
		local width = endX - startX;
		local frameWidth = width / totalFrames;
	
		local targetPos = 0;
		for i = 0, totalFrames do
			local x = frameWidth * i;
			local diff = math.abs(x - targetX);
			if diff <= frameWidth / 2 then
				targetPos = i;
				break;
			elseif i == totalFrames and targetX > x then
				targetPos = totalFrames;
			end
		end

		inputPositionStream(targetPos);
		distinctOutputPositionStream(targetPos);
	
	end

	return panel, {
		Input = {
			Position = inputPositionStream,
			StartDrag = startDragStream,
			FrameArea = frameAreaStream,
			TimelineLength = timelineLengthStream,
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