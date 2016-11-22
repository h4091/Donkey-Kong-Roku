' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Donkey Kong Channel - http://github.com/lvcabral/Donkey-Kong-Roku
' **
' **  Created: November 2016
' **  Updated: November 2016
' **
' **  Remake in BrigthScript developed by Marcelo Lv Cabral - http://lvcabral.com
' ********************************************************************************************************
' ********************************************************************************************************

Function CheckHighScores() as boolean
    if m.jumpman.usedCheat then return false
    counter = 0
    index = -1
    max = 5
    newScores = []
    for each oldHs in m.settings.highScores
        if m.gameScore > oldHs.score and index < 0
            index = counter
            newScores.Push({score: m.gameScore, name: ""})
            counter++
            if counter = max then exit for
        end if
        newScores.Push(oldHs)
        counter++
        if counter = max then exit for
    next
    if index < 0 then return false
    'Get initials for new high score
    newScores[index].name = NewHighScore(newScores, index)
    m.settings.highScores = newScores
    SaveSettings(m.settings)
    return true
End Function

Function NewHighScore(newScores as object, index as integer) as string
    playerName = ""
    key = 0
    moveCursor = false
    curButton = 0 'letter A
    curTimer = 30 'in seconds
    counter = 1
    flash = true
    while true
        event = m.port.GetMessage()
        if type(event) = "roUniversalControlEvent"
            'Handle Remote Control events
            key = event.GetInt()
            if key = m.code.BUTTON_SELECT_PRESSED and curTimer > 0
                'Select keyboard letter/button
                if curButton < 26 'letter
                    if Len(playerName) < 3 then playerName += Chr(65 + curButton)
                else if curButton = 26 'dot
                    if Len(playerName) < 3 then playerName += "."
                else if curButton = 27 'dash
                    if Len(playerName) < 3 then playerName += "-"
                else if curButton = 28 'delete
                    if Len(playerName) > 0 then playerName = Left(playerName, Len(playerName) - 1)
                else if curButton = 29 'end
                    curTimer = -3
                end if
            else if key = m.code.BUTTON_LEFT_PRESSED
                moveCursor = true
            else if key = m.code.BUTTON_RIGH_PRESSED
                moveCursor = true
            else if key = m.code.BUTTON_UP_PRESSED
                moveCursor = true
            else if key = m.code.BUTTON_DOWN_PRESSED
                moveCursor = true
            end if
        else if event = invalid
            ticks = m.clock.TotalMilliseconds()
            if ticks > 100
                DrawNameRegistration(newScores, index, playerName, curTimer, flash)
                if counter mod 5 = 0 then flash = not flash
                if curTimer = 0 then exit while
                curButton = UpdateCursor(curButton, key)
                if counter mod 10 = 0
                    if curTimer > 0 curTimer-- else curTimer++
                end if
                m.mainScreen.SwapBuffers()
                m.clock.Mark()
                counter++
            end if
        end if
	end while
    return playerName
End Function

Sub DrawNameRegistration(newScores as object, index as integer, playerName as string, curTimer as integer, flash as boolean)
    m.gameScreen.Clear(m.colors.black)
    width = m.gameScreen.GetWidth()
    'Draw static text
    DrawScore(false)
    m.gameScreen.DrawText("NAME REGISTRATION", CenterText("NAME REGISTRATION", width), m.yOff + 62, m.colors.red, m.gameFont)
    m.gameScreen.DrawText("NAME:" + playerName, CenterText("NAME:___", width), m.yOff + 92, m.colors.cyan, m.gameFont)
    m.gameScreen.DrawText("     ___", CenterText("NAME:___", width), m.yOff + 95, m.colors.cyan, m.gameFont)
    keybX = CenterText("A B C D E F G H I J", width)
    m.gameScreen.DrawText("A B C D E F G H I J", keybX, m.yOff + 132, m.colors.green, m.gameFont)
    m.gameScreen.DrawText("K L M N O P Q R S T", keybX, m.yOff + 162, m.colors.green, m.gameFont)
    m.gameScreen.DrawText("U V W X Y Z . - ", keybX, m.yOff + 192, m.colors.green, m.gameFont)
    buttons = CreateObject("roBitmap", "pkg:/images/keyboard_buttons.png")
    m.gameScreen.DrawObject(keybX + 250, m.yOff + 192, buttons)
    if curTimer > 0
        text = "REGI TIME (" + zeroPad(curTimer) + ")"
    else
        text = "YOUR NAME WAS REGISTERED"
    end if
    m.gameScreen.DrawText(text, CenterText(text, width), m.yOff + 232, m.colors.cyan, m.gameFont)
    scoresX = CenterText("RANK  SCORE  NAME       ", width)
    scoresY = m.yOff + 262
    m.gameScreen.DrawText("1ST  ", scoresX, scoresY, m.colors.red, m.gameFont)
    m.gameScreen.DrawText("2ND  ", scoresX, scoresY + 30, m.colors.red, m.gameFont)
    m.gameScreen.DrawText("3RD  ", scoresX, scoresY + 60, m.colors.red, m.gameFont)
    m.gameScreen.DrawText("4TH  ", scoresX, scoresY + 90, m.colors.yellow, m.gameFont)
    m.gameScreen.DrawText("5TH  ", scoresX, scoresY + 120, m.colors.yellow, m.gameFont)
    'Draw dynamic text
    x = scoresX + 64
    for i = 0 to 4
        y = scoresY + i * 30
        score = newScores[i].score
        if i = index and curTimer < 0
            name = playerName
        else
            name = newScores[i].name
        end if
        if i < 3 then color = m.colors.red else color = m.colors.yellow
        if i <> index or flash or curTimer < 0
            m.gameScreen.DrawText(zeroPad(score, 6) + "  " + name, x, y, color, m.gameFont)
        end if
    next
End Sub

Function UpdateCursor(curButton as integer, key as integer) as integer
    width = m.gameScreen.GetWidth()
    if key = m.code.BUTTON_LEFT_PRESSED or key = m.code.BUTTON_UP_PRESSED
        if curButton = 0 then curButton = 29 else curButton--
    else if key = m.code.BUTTON_RIGHT_PRESSED or key = m.code.BUTTON_DOWN_PRESSED
        if curButton >= 29 then curButton = 0 else curButton++
    end if
    x = CenterText("A B C D E F G H I J", width) - 6 + (curButton - Int(curButton / 10) * 10) * 32
    y = m.yOff + 126 + Int(curButton / 10) * 30
    cursor = CreateObject("roBitmap", "pkg:/images/keyboard_cursor.png")
    m.gameScreen.DrawObject(x, y, cursor)
    return curButton
End Function
