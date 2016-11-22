' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Donkey Kong Channel - http://github.com/lvcabral/Donkey-Kong-Roku
' **
' **  Created: October 2016
' **  Updated: November 2016
' **
' **  Remake in BrigthScript developed by Marcelo Lv Cabral - http://lvcabral.com
' ********************************************************************************************************
' ********************************************************************************************************

Function StartMenu(focus as integer) as integer
    this = {
            screen: CreateObject("roListScreen")
            port: CreateObject("roMessagePort")
           }
    this.screen.SetMessagePort(this.port)
    this.screen.SetHeader("Game Menu")
    this.controlModes = ["Vertical Mode", "Horizontal Mode"]
    this.controlHelp  = ["", ""]
    this.controlImage = ["pkg:/images/control_vertical.png", "pkg:/images/control_horizontal.png"]
    listItems = GetMenuItems(this)
    this.screen.SetContent(listItems)
    this.screen.SetFocusedListItem(focus)
    this.screen.Show()
    startGame = false
    listIndex = 0
    oldIndex = 0
    selection = -1
    while true
        msg = wait(0,this.port)
        if msg.isScreenClosed() then exit while
        if type(msg) = "roListScreenEvent"
            if msg.isListItemFocused()
                listIndex = msg.GetIndex()
            else if msg.isListItemSelected()
                selection = msg.GetIndex()
                if selection = m.const.MENU_START
                    SaveSettings(m.settings)
                    exit while
                else if selection >= m.const.MENU_HISCORES
                    exit while
                end if
            else if msg.isRemoteKeyPressed()
                remoteKey = msg.GetIndex()
                update = (remoteKey = m.code.BUTTON_LEFT_PRESSED or remoteKey = m.code.BUTTON_RIGHT_PRESSED)
                if remoteKey = m.code.BUTTON_REWIND_PRESSED
                    this.screen.SetFocusedListItem(m.const.MENU_START)
                else if remoteKey = m.code.BUTTON_FAST_FORWARD_PRESSED
                    this.screen.SetFocusedListItem(m.const.MENU_CREDITS)
                    else if listIndex = m.const.MENU_CONTROL
                    if remoteKey = m.code.BUTTON_LEFT_PRESSED
                        m.settings.controlMode--
                        if m.settings.controlMode < 0 then m.settings.controlMode = this.controlModes.Count() - 1
                    else if remoteKey = m.code.BUTTON_RIGHT_PRESSED
                        m.settings.controlMode++
                        if m.settings.controlMode = this.controlModes.Count() then m.settings.controlMode = 0
                    end if
                    if update
                        listItems[listIndex].Title = "Control: " + this.controlModes[m.settings.controlMode]
                        listItems[listIndex].ShortDescriptionLine1 = this.controlHelp[m.settings.controlMode]
                        listItems[listIndex].HDPosterUrl = this.controlImage[m.settings.controlMode]
                        listItems[listIndex].SDPosterUrl = this.controlImage[m.settings.controlMode]
                        this.screen.SetItem(listIndex, listItems[listIndex])
                        m.sounds.navSingle.Trigger(50)
                    end if
                end if
            end if
        end if
    end while
    return selection
End Function

Function GetMenuItems(menu as object)
    listItems = []
    listItems.Push({
                Title: "Start the Game"
                HDSmallIconUrl: "pkg:/images/icon_start.png"
                SDSmallIconUrl: "pkg:/images/icon_start.png"
                HDPosterUrl: "pkg:/images/arcade_machine.png"
                SDPosterUrl: "pkg:/images/arcade_machine.png"
                ShortDescriptionLine1: ""
                ShortDescriptionLine2: "Press OK to start the game"
                })
    listItems.Push({
                Title: "Control: " + menu.controlModes[m.settings.controlMode]
                HDSmallIconUrl: "pkg:/images/icon_arrows.png"
                SDSmallIconUrl: "pkg:/images/icon_arrows.png"
                HDPosterUrl: menu.controlImage[m.settings.controlMode]
                SDPosterUrl: menu.controlImage[m.settings.controlMode]
                ShortDescriptionLine1: menu.controlHelp[m.settings.controlMode]
                ShortDescriptionLine2: "Use Left and Right to set the control mode"
                })
    listItems.Push({
                Title: "High Scores"
                HDSmallIconUrl: "pkg:/images/icon_hiscores.png"
                SDSmallIconUrl: "pkg:/images/icon_hiscores.png"
                HDPosterUrl: "pkg:/images/menu_high_scores.png"
                SDPosterUrl: "pkg:/images/menu_high_scores.png"
                ShortDescriptionLine1: "Use of cheat keys during the game disables high score record"
                ShortDescriptionLine2: "Press OK to open High Scores"
                })
    listItems.Push({
                Title: "Game Credits"
                HDSmallIconUrl: "pkg:/images/icon_info.png"
                SDSmallIconUrl: "pkg:/images/icon_info.png"
                HDPosterUrl: "pkg:/images/menu_credits.png"
                SDPosterUrl: "pkg:/images/menu_credits.png"
                ShortDescriptionLine1: "Alpha v" + m.manifest.major_version + "." + m.manifest.minor_version + "." + m.manifest.build_version
                ShortDescriptionLine2: "Press OK to read game credits"
                })
    return listItems
End Function

Sub ShowHighScores(waitTime = 0 as integer)
    screen = m.mainScreen
    Sleep(250) ' Give time to Roku clear list screen from memory
    if m.isOpenGL
        screen.Clear(m.colors.black)
        screen.SwapBuffers()
    end if
    'Draw Screen
    bmp = CreateObject("roBitmap", "pkg:/images/frame_high_scores.png")
    centerX = Cint((bmp.GetWidth() - m.gameFont.GetOneLineWidth("HIGH SCORES", bmp.GetWidth())) / 2)
    bmp.DrawText("HIGH SCORES", centerX, 90, m.colors.red, m.gameFont)
    centerX = Cint((bmp.GetWidth() - m.gameFont.GetOneLineWidth("RANK  SCORE  NAME", bmp.GetWidth())) / 2)
    hs = m.settings.highScores
    bmp.DrawText("RANK  SCORE  NAME", centerX, 140, m.colors.cyan, m.gameFont)
    bmp.DrawText("1ST  " + zeroPad(hs[0].score, 6) + "  " + hs[0].name, centerX, 170, m.colors.red, m.gameFont)
    bmp.DrawText("2ND  " + zeroPad(hs[1].score, 6) + "  " + hs[1].name, centerX, 200, m.colors.red, m.gameFont)
    bmp.DrawText("3RD  " + zeroPad(hs[2].score, 6) + "  " + hs[2].name, centerX, 230, m.colors.red, m.gameFont)
    bmp.DrawText("4TH  " + zeroPad(hs[3].score, 6) + "  " + hs[3].name, centerX, 260, m.colors.yellow, m.gameFont)
    bmp.DrawText("5TH  " + zeroPad(hs[4].score, 6) + "  " + hs[4].name, centerX, 290, m.colors.yellow, m.gameFont)
    centerX = Cint((bmp.GetWidth() - m.gameFont.GetOneLineWidth("ANY KEY TO RETURN", bmp.GetWidth())) / 2)
    bmp.DrawText("ANY KEY TO RETURN", centerX, 340, m.colors.green, m.gameFont)
    'Paint screen
    centerX = Cint((screen.GetWidth() - bmp.GetWidth()) / 2)
    centerY = Cint((screen.GetHeight() - bmp.GetHeight()) / 2)
    screen.Clear(m.colors.black)
    screen.DrawObject(centerX, centerY, bmp)
    screen.SwapBuffers()
    while true
        key = wait(waitTime, m.port)
        if key = invalid or key < 100 then exit while
    end while
End Sub

Sub ShowCredits(waitTime = 0 as integer)
    screen = m.mainScreen
    Sleep(250) ' Give time to Roku clear list screen from memory
    if m.isOpenGL
        screen.Clear(m.colors.black)
        screen.SwapBuffers()
    end if
    imgIntro = "pkg:/images/game_credits.png"
    bmp = CreateObject("roBitmap", imgIntro)
    centerX = Cint((screen.GetWidth() - bmp.GetWidth()) / 2)
    centerY = Cint((screen.GetHeight() - bmp.GetHeight()) / 2)
    screen.Clear(m.colors.black)
    screen.DrawObject(centerX, centerY, bmp)
    screen.SwapBuffers()
	while true
    	key = wait(waitTime, m.port)
		if key = invalid or key < 100 then exit while
	end while
End Sub
