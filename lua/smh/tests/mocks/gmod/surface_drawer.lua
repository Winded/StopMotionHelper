local ctr = function()
    return {
        drawColor = {0, 0, 0, 0},
        noTextureCalled = false,
        drawEvents = {},

        setDrawColor = function(self, r, g, b, a)
            self.drawColor = {r, g, b, a}
        end,
        
        drawLine = function(self, x, y, x2, y2)
            table.insert(self.drawEvents, {"drawLine", {x, y, x2, y2}, self.drawColor})
        end,
        drawRect = function(self, x, y, width, height)
            table.insert(self.drawEvents, {"drawRect", {x, y, width, height}, self.drawColor})
        end,
        drawPoly = function(self, points)
            table.insert(self.drawEvents, {"drawPoly", {points}, self.drawColor})
        end,

        noTexture = function(self)
            self.noTextureCalled = true
        end
    }
end

return {ctr}