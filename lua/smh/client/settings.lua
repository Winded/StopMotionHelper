local ConVarType = {
    Bool = 1,
    Int = 2,
    Float = 3,
}

local TYPED_CV = {}
TYPED_CV.__index = TYPED_CV

function TYPED_CV:GetValue()
    if self.Type == ConVarType.Bool then
        return self.ConVar:GetBool()
    elseif self.Type == ConVarType.Int then
        return self.ConVar:GetInt()
    elseif self.Type == ConVarType.Float then
        return self.ConVar:GetFloat()
    end
end

function TYPED_CV:SetValue(value)
    if self.Type == ConVarType.Bool then
        return self.ConVar:SetBool(value)
    elseif self.Type == ConVarType.Int then
        return self.ConVar:SetInt(value)
    elseif self.Type == ConVarType.Float then
        return self.ConVar:SetFloat(value)
    end
end

local function CreateTypedConVar(type, name, defaultValue, helptext)
    if type == ConVarType.Bool then
        defaultValue = tostring(defaultValue and 1 or 0)
    elseif type == ConVarType.Int then
        defaultValue = tostring(defaultValue)
    elseif type == ConVarType.Float then
        defaultValue = tostring(defaultValue)
    end

    local cv = {
        Type = type,
        ConVar = CreateClientConVar(name, defaultValue, true, false, helptext, nil, nil),
    }
    setmetatable(cv, TYPED_CV)

    return cv
end

local ConVars = {
    FreezeAll = CreateTypedConVar(ConVarType.Bool, "smh_freezeall", false),
    LocalizePhysBones = CreateTypedConVar(ConVarType.Bool, "smh_localizephysbones", false),
    IgnorePhysBones = CreateTypedConVar(ConVarType.Bool, "smh_ignorephysbones", false),
    GhostPrevFrame = CreateTypedConVar(ConVarType.Bool, "smh_ghostprevframe", false),
    GhostNextFrame = CreateTypedConVar(ConVarType.Bool, "smh_ghostnextframe", false),
    GhostAllEntities = CreateTypedConVar(ConVarType.Bool, "smh_ghostallentities", false),
    GhostTransparency = CreateTypedConVar(ConVarType.Float, "smh_ghosttransparency", 0.5),
    OnionSkin = CreateTypedConVar(ConVarType.Bool, "smh_onionskin", false),
    TweenDisable = CreateTypedConVar(ConVarType.Bool, "smh_tweendisable", false),
    SmoothPlayback = CreateTypedConVar(ConVarType.Bool, "smh_smoothplayback", false)
}

local MGR = {}

function MGR.GetAll()
    local settings = {}

    for name, convar in pairs(ConVars) do
        settings[name] = convar:GetValue()
    end

    return settings
end

function MGR.Update(newSettings)
    for name, value in pairs(newSettings) do
        if not ConVars[name] then
            continue
        end
        ConVars[name]:SetValue(value)
    end
end

SMH.Settings = MGR
