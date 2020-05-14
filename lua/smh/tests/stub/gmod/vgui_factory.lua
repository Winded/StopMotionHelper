local VGUI_MOCK = {}
VGUI_MOCK.__index = VGUI_MOCK

function VGUI_MOCK:GetWide()
    if self.vgui_size == nil then
        return 0
    end

    return self.vgui_size[1]
end

function VGUI_MOCK:GetTall()
    if self.vgui_size == nil then
        return 0
    end

    return self.vgui_size[2]
end

function VGUI_MOCK:SetPos(x, y)
    self.vgui_pos = {x, y}
end

function VGUI_MOCK:SetSize(width, height)
    self.vgui_size = {width, height}
end

function VGUI_MOCK:MouseCapture(capture)
    self.vgui_mouseCaptured = capture
end

function VGUI_MOCK:SetParent(parent)
    self.vgui_parent = parent
end

local ctr = function()
    return {
        registeredElements = {},

        create = function(self, name)
            local element = {}
            local metatable = self.registeredElements[name][1]
            setmetatable(element, metatable)
            return element
        end,
        register = function(self, name, metatable, type)
            metatable.__index = function(self, key)
                local r = rawget(metatable, key)
                if r == nil then
                    return VGUI_MOCK[key]
                end
                return r
            end
            self.registeredElements[name] = {metatable, type}
            return metatable
        end
    }
end

return {ctr}