
include("world_clicker.lua");
include("frame_item.lua");
include("pointer.lua");
include("frame_panel.lua");
include("smh_menu.lua");

hook.Add("Initialize", "SMHMenuInit", function()

SMH.WorldClicker = vgui.Create("SMHWorldClicker");
SMH.WorldClicker:MakePopup();
SMH.WorldClicker:SetVisible(false);

SMH.Menu = vgui.Create("SMHMenu", SMH.WorldClicker);

SMH.HelpMenu = vgui.Create('DFrame');
SMH.HelpMenu:SetSize(650, 650);
SMH.HelpMenu:Center();
SMH.HelpMenu:SetTitle('Help');
SMH.HelpMenu:SetSizable(false);
SMH.HelpMenu:ShowCloseButton(true);
SMH.HelpMenu:SetDeleteOnClose(false);
SMH.HelpMenu:SetBackgroundBlur(true);
SMH.HelpMenu:MakePopup();

SMH.HelpMenu.Body = vgui.Create("DHTML", SMH.HelpMenu);
SMH.HelpMenu.Body:SetPos(5, 25);
SMH.HelpMenu.Body:SetSize(640, 620);
SMH.HelpMenu.Body:SetBGColor(Color(255,255,255,255));
SMH.HelpMenu.Body:SetHTML(file.Read("lua/smh_help.lua","GAME"));

SMH.HelpMenu:SetVisible(false);


end)

function SMH.OpenHelp()
	SMH.HelpMenu:SetVisible(true);
end

function ShowMenu()
	SMH.WorldClicker:SetVisible(true);
	RestoreCursorPosition();
	SMH.HighlightEntity = true;
end

function HideMenu()
	if SMH.Menu:Focused() then
		return;
	end
	RememberCursorPosition();
	SMH.WorldClicker:SetVisible(false);
	SMH.HighlightEntity = false;
end

concommand.Add("+smh_menu", ShowMenu);
concommand.Add("-smh_menu", HideMenu);