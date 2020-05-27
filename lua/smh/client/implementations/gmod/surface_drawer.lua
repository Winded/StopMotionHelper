return function()
    return {
        setDrawColor = function(self, r, g, b, a)
            surface.SetDrawColor(r, g, b, a)
        end,
        
        drawLine = function(self, x, y, x2, y2)
            surface.DrawLine(x, y, x2, y2)
        end,
        drawRect = function(self, x, y, width, height)
            surface.DrawRect(x, y, width, height)
        end,
        drawPoly = function(self, points)
            surface.DrawPoly(points)
        end,

        noTexture = function(self)
            draw.NoTexture()
        end
    }
end