local KeyboardKeys = {}
do
    local Keys = {"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","Numpad_0","Numpad_1","Numpad_2","Numpad_3","Numpad_4","Numpad_5","Numpad_6","Numpad_7","Numpad_8","Numpad_9","Numpad_/","Numpad_*","Numpad_-","Numpad_+","Numpad_Enter","Numpad_.","[","]","SEMICOLON","'","`",",",".","/","\\","-","=","ENTER","SPACE","BACKSPACE","TAB","CAPSLOCK","NUMLOCK","ESCAPE","SCROLLLOCK","INS","DEL","HOME","END","PGUP","PGDN","PAUSE","SHIFT","RSHIFT","ALT","RALT","CTRL","RCTRL","LWIN","RWIN","APP","UPARROW","LEFTARROW","DOWNARROW","RIGHTARROW","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12","CAPSLOCKTOGGLE","NUMLOCKTOGGLE","SCROLLLOCKTOGGLE"}
    for id, key in ipairs(Keys) do
        KeyboardKeys[key] = id
    end
end

local LastFrame = -1

local function GetKeys(str)
    local split = string.Split(str, " ")
    local result = {}

    for _, key in ipairs(split) do
        if KeyboardKeys[key] then
            table.insert(result, KeyboardKeys[key])
        end
    end

    return result
end

local MGR = {}

function MGR.Load(player, frame, keyframes)
    if LastFrame == frame then return end

    for _, keyframe in pairs(keyframes) do
        if keyframe.Frame == frame then
            if keyframe.Modifiers["world"].Console ~= "" then
                player:ConCommand(keyframe.Modifiers["world"].Console)
            end

            local PushKeys = GetKeys(keyframe.Modifiers["world"].Push)
            for _, key in ipairs(PushKeys) do
                numpad.Activate(player, key, true)
            end

            local ReleaseKeys = GetKeys(keyframe.Modifiers["world"].Release)
            for _, key in ipairs(ReleaseKeys) do
                numpad.Deactivate(player, key, true)
            end
            break
        end
    end
end

SMH.WorldKeyframesManager = MGR
