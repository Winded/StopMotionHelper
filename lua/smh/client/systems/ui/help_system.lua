local SYS = {}

function SYS:Init()
end

function SYS:EventShowHelp()
    gui.OpenURL("https://github.com/Winded/StopMotionHelper/blob/master/TUTORIAL.md")
end

SMH.Systems.Register("HelpSystem", SYS)