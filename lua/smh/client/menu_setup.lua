
include("derma/frame_panel.lua");
include("derma/frame_pointer.lua");
include("derma/save.lua");
include("derma/load.lua");
include("derma/settings.lua");
include("derma/smh_menu.lua");
include("derma/world_clicker.lua");

function SMH.SetupMenu()

	SMH.WorldClicker = vgui.Create("SMHWorldClicker");
	SMH.WorldClicker:MakePopup();
	SMH.WorldClicker:SetVisible(false);
	SMH.WorldClicker:Bind(SMH.Data, "Entity", "WorldClicker");

	SMH.Menu = vgui.Create("SMHMenu", SMH.WorldClicker);

	SMH.SettingsMenu = vgui.Create("SMHSettings", SMH.WorldClicker);
	SMH.SettingsMenu:SetPos(ScrW() - 150, ScrH() - 205);
	SMH.SettingsMenu:SetVisible(false);
	SMH.SettingsMenu:Bind(SMH.Data, "ShowSettings", "Visibility");

	SMH.SaveMenu = vgui.Create("SMHSave");
	SMH.SaveMenu:MakePopup();
	SMH.SaveMenu:SetVisible(false);
	SMH.SaveMenu:Bind(SMH.Data, "ShowSave", "Visibility");

	SMH.LoadMenu = vgui.Create("SMHLoad");
	SMH.LoadMenu:MakePopup();
	SMH.LoadMenu:SetVisible(false);
	SMH.LoadMenu:Bind(SMH.Data, "ShowLoad", "Visibility");

	SMH.HelpMenu = vgui.Create("DFrame");
	SMH.HelpMenu:SetSize(650, 650);
	SMH.HelpMenu:Center();
	SMH.HelpMenu:SetTitle('Help');
	SMH.HelpMenu:SetSizable(false);
	SMH.HelpMenu:ShowCloseButton(true);
	SMH.HelpMenu:SetDeleteOnClose(false);
	SMH.HelpMenu:SetBackgroundBlur(true);
	SMH.HelpMenu:MakePopup();
	SMH.HelpMenu:Bind(SMH.Data, "ShowHelp", "Visibility");

	SMH.HelpMenu.Body = vgui.Create("HTML", SMH.HelpMenu);
	SMH.HelpMenu.Body:SetPos(5, 25);
	SMH.HelpMenu.Body:SetSize(640, 620);
	SMH.HelpMenu.Body:OpenURL("http://winded.org/gmod/smh_help.html");

	SMH.HelpMenu:SetVisible(false);

end

function SMH.OpenHelp()
	SMH.HelpMenu:SetVisible(true);
end

function SMH.ShowMenu()
	SMH.WorldClicker:SetVisible(true);
	RestoreCursorPosition();
	SMH.HighlightEntity = true;
end

function SMH.HideMenu()
	RememberCursorPosition();
	SMH.WorldClicker:SetVisible(false);
	SMH.HighlightEntity = false;
end

concommand.Add("+smh_menu", SMH.ShowMenu);
concommand.Add("-smh_menu", SMH.HideMenu);