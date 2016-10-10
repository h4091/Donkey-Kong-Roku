' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Donkey Kong Channel - http://github.com/lvcabral/Donkey-Kong-Roku
' **
' **  Created: October 2016
' **  Updated: October 2016
' **
' **  Remake in Brightscropt developed by Marcelo Lv Cabral - http://lvcabral.com
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
                ShortDescriptionLine1: "Use of cheat keys disables high score record"
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

Function CheckHighScores() as boolean
    if m.runner.usedCheat then return false
    counter = 0
    index = -1
    max = 10
    changed = false
    ' oldScores = m.highScores[m.settings.version]
    ' newScores = []
    ' if oldScores.Count() = 0
    '     index = 0
    '     newScores.Push({name: "", level: m.currentLevel, points: m.runner.score})
    ' else
    '     for each score in oldScores
    '         if m.runner.score > score.points and index < 0
    '             index = counter
    '             newScores.Push({name: "", level: m.currentLevel, points: m.runner.score})
    '             counter++
    '             if counter = max then exit for
    '         end if
    '         newScores.Push(score)
    '         counter++
    '         if counter = max then exit for
    '     next
	' 	if counter < max and index < 0
	' 		index = counter
	' 		newScores.Push({name: "", level: m.currentLevel, points: m.runner.score})
	' 	end if
    ' end if
    ' if index >= 0
    '     playerName = KeyboardScreen("", "Please type your name (max 13 letters)")
    '     if playerName = "" then playerName = "< NO NAME >"
    '     playerName = padLeft(UCase(playerName), 13)
    '     newScores[index].name = playerName
    '     m.highScores[m.settings.version] = newScores
    '     SaveHighScores(m.highScores)
    '     changed = true
    ' end if
    return changed
End Function

Sub ShowHighScores(waitTime = 0 as integer)
    version = m.settings.version
    ' if m.regions = invalid then LoadGameSprites(m.settings.spriteMode)
    ' screen = m.mainScreen
    ' Sleep(250) ' Give time to Roku clear list screen from memory
    ' if m.isOpenGL
    '     screen.Clear(m.colors.black)
    '     screen.SwapBuffers()
    ' end if
    ' 'Draw Screen
    ' bmp = CreateObject("roBitmap", {width:640, height:480, alphaenable:true})
    ' border = 10
    ' columns = m.const.TILES_X + 3
    ' lineSpacing = (m.const.TILE_HEIGHT + 10)
    ' x = border
    ' y = m.const.TILE_HEIGHT
    ' WriteText(bmp, padCenter(GetVersionMap(version) + " Donkey Kong", columns), x, y)
    ' y += lineSpacing
    ' WriteText(bmp, padCenter("HIGH SCORES", columns), x, y)
    ' y += lineSpacing
    ' WriteText(bmp, "NO      NAME      LEVEL  SCORE", x, y)
    ' y += lineSpacing
    ' ground = m.regions.tiles.Lookup("ground")
    ' for i = 0 to columns - 1
    '     bmp.DrawObject(x + i * m.const.TILE_WIDTH, y, ground)
    ' next
    ' y += (m.const.GROUND_HEIGHT + 7)
    ' scores = m.highScores[version]
    ' for h = 1 to 10
    '     x = WriteText(bmp, zeroPad(h) + ". ", x, y)
    '     if h <= scores.Count()
    '         x = WriteText(bmp, scores[h - 1].name + " ", x, y)
    '         x = WriteText(bmp, " " + zeroPad(scores[h - 1].level, 3) + "  ", x, y)
    '         x = WriteText(bmp, zeroPad(scores[h - 1].points, 7), x, y)
    '     end if
    '     x = border
    '     y += lineSpacing
    ' next
    ' 'Paint screen
    ' centerX = Cint((screen.GetWidth() - bmp.GetWidth()) / 2)
    ' centerY = Cint((screen.GetHeight() - bmp.GetHeight()) / 2)
    ' screen.Clear(m.colors.black)
    ' screen.DrawObject(centerX, centerY, bmp)
    ' screen.SwapBuffers()
    ' while true
    '     key = wait(waitTime, m.port)
    '     if key = invalid or key < 100 then exit while
    ' end while
End Sub
