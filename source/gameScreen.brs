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

Function PlayGame() as boolean
    'Clear screen (needed for non-OpenGL devices)
    m.mainScreen.Clear(0)
    m.mainScreen.SwapBuffers()
    m.mainScreen.Clear(0)
    'Initialize flags and aux variables
    m.gameOver = false
    m.speed = 30
    m.yOff = 20
    'Game Loop
    m.clock.Mark()
    while true
        event = m.port.GetMessage()
        if type(event) = "roUniversalControlEvent"
            'Handle Remote Control events
            id = event.GetInt()
            if id = m.code.BUTTON_BACK_PRESSED
                'StopAudio()
                DestroyChars()
                DestroyStage()
                exit while
            else if id = m.code.BUTTON_INSTANT_REPLAY_PRESSED
                m.jumpman.alive = false
            else if id = m.code.BUTTON_PLAY_PRESSED
                PauseGame()
            else if id = m.code.BUTTON_INFO_PRESSED
                if m.jumpman.lives < m.const.START_LIVES + 1
                    m.jumpman.lives++
                    m.jumpman.usedCheat = true
                end if
            else if ControlNext(id)
                NextBoard()
                m.jumpman.usedCheat = true
            else
                m.jumpman.cursors.update(id)
            end if
        else if event = invalid
            'Game screen process
            ticks = m.clock.TotalMilliseconds()
            if ticks > m.speed
                'Update sprites
                if m.board.redraw
                    DrawBoard()
                    DrawObjects()
                end if
                KongUpdate()
                LadyUpdate()
                ObjectsUpdate()
                if m.startup then BoardStartup()
                JumpmanUpdate()
                'SoundUpdate()
                'Paint Screen
                m.mainScreen.Clear(0)
                m.compositor.AnimationTick(ticks)
                m.compositor.DrawAll()
                DrawScore()
                m.mainScreen.SwapBuffers()
                m.clock.Mark()
                'Check jumpman death
                if not m.gameOver
                    if not m.jumpman.alive
                        'PlaySound("dead")
                        if m.jumpman.lives = 0
                            m.gameOver = true
                        else
                            ResetGame()
                        end if
                    else
                        m.gameOver = CheckLevelSuccess()
                    end if
                end if
                if m.gameOver
                    changed = false
                    'StopAudio()
                    GameOver()
                    changed = CheckHighScores()
                    DestroyChars()
                    DestroyStage()
                    m.jumpman = invalid
                    return changed
                end if
            end if
        end if
    end while
    return false
End Function

Sub DrawBoard()
    bmp = CreateObject("roBitmap", "pkg:/assets/images/board-" + m.board.name + ".png")
    rgn = CreateObject("roRegion", bmp, 0, 0, bmp.GetWidth(), bmp.GetHeight())
    if m.board.sprite = invalid
        m.board.sprite = m.compositor.NewSprite(0, m.yOff, rgn, m.const.BOARD_Z)
    else
        m.board.sprite.SetRegion(rgn)
    end if
    m.board.sprite.SetMemberFlags(0)
    m.board.redraw = false
End Sub

Sub DrawObjects()
    for i = 0 to m.objects.Count() - 1
        obj = m.objects[i]
        region = m.regions.objects.Lookup(obj.frameName)
        if region <> invalid
            x = (obj.blockX * m.const.BLOCK_WIDTH) + obj.offsetX
            y = ((obj.blockY * m.const.BLOCK_HEIGHT) + obj.offsetY) - region.GetHeight()
            if obj.sprite = invalid
                obj.sprite = m.compositor.NewSprite(x, y + m.yOff, region, m.const.OBJECTS_Z)
                obj.sprite.SetData(obj.name)
            else
                obj.sprite.SetRegion(region)
                obj.sprite.MoveTo(x, y + m.yOff)
            end if
        end if
    next
End Sub

Sub DrawScore()
    'Paint lifes
    life = m.regions.objects.Lookup("life")
    for t = 1 to m.jumpman.lives
        m.gameScreen.DrawObject(16 * t, 12, life)
    next
    'Paint score
    leftOff = ((m.mainWidth - 640) / 2)
    m.gameLeft.DrawText("1UP", leftOff + 24, 12, m.colors.red, m.gameFont)
    m.gameLeft.DrawText(zeroPad(m.gameScore, 6), leftOff, 28, m.colors.white, m.gameFont)
    m.gameRight.DrawText("HIGH", 16, 12, m.colors.red, m.gameFont)
    m.gameRight.DrawText(zeroPad(m.highScore, 6), 0, 28, m.colors.white, m.gameFont)
    m.gameScreen.DrawText("L=" + zeroPad(m.currentLevel), 340 , 12, m.colors.blue, m.gameFont)
    m.gameScreen.DrawText(zeroPad(m.const.SCORE_BONUS), 354, m.yOff + 32, Val(m.board.fontColor, 0), m.gameFont)
End Sub

Sub JumpmanUpdate()
    m.jumpman.update()
    region = m.regions.jumpman.Lookup(m.jumpman.frameName)
    if region <> invalid
        x = (m.jumpman.blockX * m.const.BLOCK_WIDTH) + m.jumpman.offsetX
        y = ((m.jumpman.blockY * m.const.BLOCK_HEIGHT) + m.jumpman.offsetY) - region.GetHeight()
        if m.jumpman.sprite = invalid
            m.jumpman.sprite = m.compositor.NewSprite(x, y + m.yOff, region, m.const.CHARS_Z)
            m.jumpman.sprite.SetData("jumpman")
        else
            m.jumpman.sprite.SetRegion(region)
            m.jumpman.sprite.MoveTo(x, y + m.yOff)
            'Check collision with objects
            objSprite = m.jumpman.sprite.CheckCollision()
            if objSprite <> invalid
                objName = objSprite.GetData()
                if objName = "hat" or objName = "parasol" or objName = "purse"
                    print "collected pauline item: " + objName
                    objSprite.Remove()
                    if m.currentLevel = 1
                        AddScore(300)
                    else if m.currentLevel = 2
                        AddScore(500)
                    else
                        AddScore(800)
                    end if
                else if objName = "lady"
                    print "kiss pauline!"
                else if objName = "hammer"
                    print "got hammer!"
                else if objName = "oil"
                    'ignore
                else if not m.immortal
                    m.jumpman.alive = false
                end if
            end if
        end if
    else
        print "invalid region: ";m.jumpman.frameName
    end if
End Sub

Sub KongUpdate()
    'm.kong.update()
    region = m.regions.kong.Lookup(m.kong.frameName)
    if region <> invalid
        x = (m.kong.blockX * m.const.BLOCK_WIDTH) + m.kong.offsetX
        y = ((m.kong.blockY * m.const.BLOCK_HEIGHT) + m.kong.offsetY) - region.GetHeight()
        if m.kong.sprite = invalid
            m.kong.sprite = m.compositor.NewSprite(x, y + m.yOff, region, m.const.CHARS_Z)
            m.kong.sprite.SetData("kong")
        else
            m.kong.sprite.SetRegion(region)
            m.kong.sprite.MoveTo(x, y + m.yOff)
        end if
    end if
End Sub

Sub LadyUpdate()
    'm.lady.update()
    region = m.regions.lady.Lookup(m.lady.frameName)
    if region <> invalid
        x = (m.lady.blockX * m.const.BLOCK_WIDTH) + m.lady.offsetX
        y = ((m.lady.blockY * m.const.BLOCK_HEIGHT) + m.lady.offsetY) - region.GetHeight()
        if m.lady.sprite = invalid
            m.lady.sprite = m.compositor.NewSprite(x, y + m.yOff, region, m.const.CHARS_Z)
            m.lady.sprite.SetData("lady")
        else
            m.lady.sprite.SetRegion(region)
            m.lady.sprite.MoveTo(x, y + m.yOff)
        end if
    end if
End Sub

Sub ObjectsUpdate()

End Sub

Sub BoardStartup()
    m.compositor.DrawAll()
    DrawScore()
    m.mainScreen.SwapBuffers()
    Sleep(1000)
    if not m.jumpman.alive
        m.jumpman.alive = true
        m.jumpman.lives--
    end if
    m.startup = false
End Sub

Function CheckLevelSuccess() as boolean
    return false
End Function

Sub DestroyChars()
    if m.kong <> invalid
        if m.kong.sprite <> invalid
            m.kong.sprite.Remove()
            m.kong.sprite = invalid
        end if
        m.kong = invalid
    end if
    if m.lady <> invalid
        if m.lady.sprite <> invalid
            m.lady.sprite.Remove()
            m.lady.sprite = invalid
        end if
        m.lady = invalid
    end if
    if m.jumpman <> invalid
        if m.jumpman.sprite <> invalid
            m.jumpman.sprite.Remove()
            m.jumpman.sprite = invalid
        end if
    end if
    if m.objects <> invalid
        for i = 0 to m.objects.Count()
            if m.objects[i] <> invalid
                if m.objects[i].sprite <> invalid
                    m.objects[i].sprite.Remove()
                    m.objects[i].sprite = invalid
                end if
            end if
        next
        m.objects = invalid
    end if
End Sub

Sub DestroyStage()
    if m.board.sprite <> invalid
        m.board.sprite.Remove()
        m.board.sprite = invalid
    end if
End Sub

Sub PauseGame()
    text = "GAME  PAUSED"
    textWidth = m.gameFont.GetOneLineWidth(text, m.gameWidth)
    textHeight = m.gameFont.GetOneLineHeight()
    x = Cint((m.gameWidth - textWidth) / 2)
    y = 308
    m.gameScreen.DrawRect(x - 32, y - 32, textWidth + 64, textHeight + 64, m.colors.black)
    m.gameScreen.DrawText(text, x, y, Val(m.board.fontColor, 0), m.gameFont)
    m.mainScreen.SwapBuffers()
    while true
        key = wait(0, m.port)
        if key = m.code.BUTTON_PLAY_PRESSED then exit while
    end while
End Sub

Sub GameOver()
    text = "GAME  OVER"
    textWidth = m.gameFont.GetOneLineWidth(text, m.gameWidth)
    textHeight = m.gameFont.GetOneLineHeight()
    x = Cint((m.gameWidth - textWidth) / 2)
    y = 308
    m.gameScreen.DrawRect(x - 32, y - 32, textWidth + 64, textHeight + 64, m.colors.black)
    m.gameScreen.DrawText(text, x, y, Val(m.board.fontColor, 0), m.gameFont)
    m.mainScreen.SwapBuffers()
    while true
        key = wait(3000, m.port)
        if key = invalid or key < 100 then exit while
    end while
    'ClearSavedGame()
End Sub

Function ControlNext(id as integer) as boolean
    vStatus = m.settings.controlMode = m.const.CONTROL_VERTICAL and id = m.code.BUTTON_A_PRESSED
    hStatus = m.settings.controlMode = m.const.CONTROL_HORIZONTAL and id = m.code.BUTTON_FAST_FORWARD_PRESSED
    return vStatus or hStatus
End Function
