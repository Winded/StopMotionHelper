
include("derma/frame_panel.lua");
include("derma/frame_pointer.lua");
include("derma/smh_menu.lua");
include("derma/world_clicker.lua");

function SMH.SetupMenu()

	SMH.WorldClicker = vgui.Create("SMHWorldClicker");
	SMH.WorldClicker:MakePopup();
	SMH.WorldClicker:SetVisible(false);
	SMH.WorldClicker:Bind(SMH.Data, "Entity", "WorldClicker");

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
	if SMH.Menu:Focused() then
		return;
	end
	RememberCursorPosition();
	SMH.WorldClicker:SetVisible(false);
	SMH.HighlightEntity = false;
end

concommand.Add("+smh_menu", SMH.ShowMenu);
concommand.Add("-smh_menu", SMH.HideMenu);