
if !SMH or !SMH.PanelFrames then return end

-- What would anyone do without DermaDesigner? Credits to the maker of it.

local MenuFrame
local PFrames
local BClearFrame
local BRecFrame
local BRemFrame
local BAddFrame
local NWPicsBetween
local NWEndSlow
local NWStartSlow
local BWFColor
local BHelp
local CBAddSave
local CBFreezeAll
local CBGhost
local BMoveFrameUp
local BMoveFrameDown

local HelpMenu
local HelpPage

local ColorMenu
local SBlue
local SGreen
local SRed
local CBDisco
local CBEnable

local MenuFrameS = {w = 145, h = 230}

hook.Add("Initialize","smhClientLoad",function()

-- Menu setup

MenuFrame = vgui.Create('DFrame')
MenuFrame:SetSize(MenuFrameS.w, MenuFrameS.h)
MenuFrame:SetPos((-MenuFrameS.w)-5, ScrH() - (MenuFrameS.h + 5))
MenuFrame:SetTitle('SMH Menu')
MenuFrame:SetDraggable(false)
MenuFrame:SetSizable(false)
MenuFrame:SetDeleteOnClose(false)
MenuFrame:ShowCloseButton(false)
MenuFrame:MakePopup()

CBFreezeAll = vgui.Create('DCheckBoxLabel')
CBFreezeAll:SetParent(MenuFrame)
CBFreezeAll:SetPos(45, 170)
CBFreezeAll:SetText('Freeze All')
CBFreezeAll:SetToolTip("Enable this to freeze all bones when setting frame.")
CBFreezeAll:SetConVar("smh_freezeall")
CBFreezeAll:SizeToContents()

PFrames = vgui.Create('DPanelList')
PFrames:SetParent(MenuFrame)
PFrames:SetSize(35, 200)
PFrames:SetPos(5, 25)
PFrames:SetPadding(2)
PFrames:SetSpacing(2)
PFrames:EnableHorizontal(false)
PFrames:EnableVerticalScrollbar(true)
PFrames.Paint = function()
	surface.SetDrawColor(180,180,180,255);
	surface.DrawRect(0,0,100,250);
end

SMH.PFrames = PFrames;

-- Adding the first frame to the list
SMH.PanelFrames[1] = vgui.Create("DButton")
SMH.PanelFrames[1]:SetHeight(10)
SMH.PanelFrames[1]:SetText("-")
SMH.PanelFrames[1]:SetTooltip(tostring(1))
SMH.PanelFrames[1].FrameID = 1
SMH.PanelFrames[1].DoClick = function(self)
	SMH.CurFrame = self.FrameID
	SMH.SetFrame()
end
PFrames:AddItem(SMH.PanelFrames[1])


BAddFrame = vgui.Create('DButton')
BAddFrame:SetParent(MenuFrame)
BAddFrame:SetSize(20, 20)
BAddFrame:SetPos(45, 25)
BAddFrame:SetText('+')
BAddFrame:SetToolTip("Add frame.")
BAddFrame.DoClick = function() SMH.AddFrame() end

BRemFrame = vgui.Create('DButton')
BRemFrame:SetParent(MenuFrame)
BRemFrame:SetSize(20, 20)
BRemFrame:SetPos(70, 25)
BRemFrame:SetText('-')
BRemFrame:SetToolTip("Remove frame.")
BRemFrame.DoClick = function() SMH.RemFrame() end

BRecFrame = vgui.Create('DButton')
BRecFrame:SetParent(MenuFrame)
BRecFrame:SetSize(20, 20)
BRecFrame:SetPos(95, 25)
BRecFrame:SetText('R')
BRecFrame:SetToolTip("Record frame.")
BRecFrame.DoClick = function() SMH.RecFrame() end

BClearFrame = vgui.Create('DButton')
BClearFrame:SetParent(MenuFrame)
BClearFrame:SetSize(20, 20)
BClearFrame:SetPos(120, 25)
BClearFrame:SetText('X')
BClearFrame:SetToolTip("Clear frame.")
BClearFrame.DoClick = function() SMH.ClearFrame() end

BMoveFrameUp = vgui.Create('DButton')
BMoveFrameUp:SetParent(MenuFrame)
BMoveFrameUp:SetSize(45, 15)
BMoveFrameUp:SetPos(45, 205)
BMoveFrameUp:SetToolTip("Moves the current frame up one level.")
BMoveFrameUp:SetText('up')
BMoveFrameUp.DoClick = function() SMH.MoveFrameUp() end

BMoveFrameDown = vgui.Create('DButton')
BMoveFrameDown:SetParent(MenuFrame)
BMoveFrameDown:SetSize(45, 15)
BMoveFrameDown:SetPos(95, 205)
BMoveFrameDown:SetToolTip("Moves the current frame down one level.")
BMoveFrameDown:SetText('down')
BMoveFrameDown.DoClick = function() SMH.MoveFrameDown() end

NWPicsBetween = vgui.Create('DNumberWang')
NWPicsBetween:SetParent(MenuFrame)
NWPicsBetween:SetPos(45, 50)
NWPicsBetween:SetDecimals(0)
NWPicsBetween:SetConVar("smh_picsadd")
NWPicsBetween:SetToolTip("Pics between this and next frame.")
NWPicsBetween.OnValueChanged = function(self,val) SMH.svSetFramePB(SMH.CurFrame,tonumber(val)) end
NWPicsBetween:SetMinMax( 0, 100)

NWEndSlow = vgui.Create('DNumberWang')
NWEndSlow:SetParent(MenuFrame)
NWEndSlow:SetPos(45, 95)
NWEndSlow:SetDecimals(2)
NWEndSlow:SetConVar("smh_endslow")
NWEndSlow:SetToolTip("Easing on end.")
NWEndSlow.OnValueChanged = function(self,val) SMH.svSetES(SMH.CurFrame,tonumber(val)) end
NWEndSlow:SetMinMax( 0, 1)

NWStartSlow = vgui.Create('DNumberWang')
NWStartSlow:SetParent(MenuFrame)
NWStartSlow:SetPos(45, 75)
NWStartSlow:SetDecimals(2)
NWStartSlow:SetConVar("smh_startslow")
NWStartSlow:SetToolTip("Easing on start.")
NWStartSlow.OnValueChanged = function(self,val) SMH.svSetSS(SMH.CurFrame,tonumber(val)) end
NWStartSlow:SetMinMax( 0, 1)

CBLocalized = vgui.Create('DCheckBoxLabel')
CBLocalized:SetParent(MenuFrame)
CBLocalized:SetPos(45, 140)
CBLocalized:SetText('Localized')
CBLocalized:SetConVar("smh_localized")
CBLocalized.DoClick = function() end
CBLocalized:SizeToContents()

-- BWFColor = vgui.Create('DButton')
-- BWFColor:SetParent(MenuFrame)
-- BWFColor:SetSize(95, 20)
-- BWFColor:SetPos(45, 120)
-- BWFColor:SetText('Wireframe color')
-- BWFColor.DoClick = function()
	-- SMH.OpenWFC()
-- end

BHelp = vgui.Create('DButton');
BHelp:SetParent(MenuFrame)
BHelp:SetSize(95, 20)
BHelp:SetPos(45, 120)
BHelp:SetText('Help')
BHelp.DoClick = function()
	SMH.OpenHelp()
end

CBAddSave = vgui.Create('DCheckBoxLabel')
CBAddSave:SetParent(MenuFrame)
CBAddSave:SetPos(45, 155)
CBAddSave:SetText('Save on Add')
CBAddSave:SetConVar("smh_saveonadd")
CBAddSave.DoClick = function() end
CBAddSave:SizeToContents()

CBGhost = vgui.Create('DCheckBoxLabel')
CBGhost:SetParent(MenuFrame)
CBGhost:SetPos(45, 185)
CBGhost:SetText('Ghosts')
CBGhost:SetConVar("smh_ghost_enable")
CBGhost.OnChange = function(self,val)
	if tobool(val) then
		SMH.svEnableGhosts()
	else
		SMH.svDisableGhosts()
	end
end
CBGhost:SizeToContents()

-- Help menu
HelpMenu = vgui.Create('DFrame')
HelpMenu:SetSize(650, 650)
HelpMenu:Center()
HelpMenu:SetTitle('Help')
HelpMenu:SetSizable(false)
HelpMenu:ShowCloseButton(true)
HelpMenu:SetDeleteOnClose(false)
HelpMenu:SetBackgroundBlur(true)
HelpMenu:MakePopup()

HelpPage = vgui.Create("DHTML");
HelpPage:SetParent(HelpMenu);
HelpPage:SetPos(5, 20);
HelpPage:SetSize(640, 625);
HelpPage:SetBGColor(Color(255,255,255,255));
HelpPage:SetHTML(file.Read("lua/smh_help.lua","GAME"));

-- Color menu
-- ColorMenu = vgui.Create('DFrame')
-- ColorMenu:SetSize(169, 169)
-- ColorMenu:Center()
-- ColorMenu:SetTitle('Wireframe Color')
-- ColorMenu:SetSizable(false)
-- ColorMenu:ShowCloseButton(true)
-- ColorMenu:SetDeleteOnClose(false)
-- ColorMenu:SetBackgroundBlur(true)
-- ColorMenu:MakePopup()

-- local boo = vgui.Create("DLabel");
-- boo:SetParent(ColorMenu);
-- boo:SetPos(5, 25);
-- boo:SetText("Disabled, use smh_wf convars.");
-- boo:SizeToContents();

-- SRed = vgui.Create('DNumSlider')
-- SRed:SetSize(154, 40)
-- SRed:SetParent(ColorMenu)
-- SRed:SetPos(5, 25)
-- SRed:SetDecimals(2)
-- SRed:SetConVar("smh_wf_r")
-- SRed:SetText('Red')
-- SRed:SetMinMax( 0, 1)

-- SGreen = vgui.Create('DNumSlider')
-- SGreen:SetSize(154, 40)
-- SGreen:SetParent(ColorMenu)
-- SGreen:SetPos(5, 65)
-- SGreen:SetDecimals(2)
-- SGreen:SetConVar("smh_wf_g")
-- SGreen:SetText('Green')
-- SGreen:SetMinMax( 0, 1)

-- SBlue = vgui.Create('DNumSlider')
-- SBlue:SetSize(154, 40)
-- SBlue:SetParent(ColorMenu)
-- SBlue:SetPos(5, 105)
-- SBlue:SetDecimals(2)
-- SBlue:SetConVar("smh_wf_b")
-- SBlue:SetText('Blue')
-- SBlue:SetMinMax( 0, 1)

-- CBEnable = vgui.Create('DCheckBoxLabel')
-- CBEnable:SetParent(ColorMenu)
-- CBEnable:SetPos(9, 149)
-- CBEnable:SetConVar("smh_wf_enable")
-- CBEnable:SetText('Enable wireframe')
-- CBEnable:SizeToContents()

MenuFrame:SetVisible(false)
-- ColorMenu:SetVisible(false)
HelpMenu:SetVisible(false)


end)

local MenuMoving = false -- Only for moving out
local function MoveMenuIn()
	MenuFrame:SetVisible(true)
	RestoreCursorPosition()
	MenuFrame:MoveTo(5,ScrH() - (MenuFrameS.h + 5),0.1,0,2)
end
local function MoveMenuOut()
	MenuFrame:MoveTo((-MenuFrameS.w)-5,ScrH() - (MenuFrameS.h + 5),0.1,0,2)
	MenuMoving = true
end
local function MoveOutThink()
	if MenuMoving then
		local _x,_y = MenuFrame:GetPos()
		if _x == (-MenuFrameS.w)-5 then
			MenuMoving = false
			RememberCursorPosition()
			MenuFrame:SetVisible(false)
		end
	end
end
hook.Add("Think","smh_MoveMenuThink",MoveOutThink)

function SMH.OpenHelp()
	HelpMenu:SetVisible(true)
end

function SMH.OpenWFC()
	ColorMenu:SetVisible(true)
end

function cmdShowMenu(pl,cmd,args)
	MoveMenuIn()
	SMH.ShowEnts = true
end

function cmdHideMenu()
	MoveMenuOut()
	SMH.ShowEnts = false
end

concommand.Add("+smh_menu",cmdShowMenu)
concommand.Add("-smh_menu",cmdHideMenu)