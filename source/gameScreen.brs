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

Function PlayGame(testMode = false as boolean) as boolean
    'Clear screen (needed for non-OpenGL devices)
    m.mainScreen.Clear(0)
    m.mainScreen.SwapBuffers()
    m.mainScreen.Clear(0)
    'Initialize flags and aux variables
    m.gameOver = false
    m.speed = 80
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
                if m.jumpman.health < m.const.LIMIT_HEALTH
                    m.jumpman.health++
                    m.jumpman.usedCheat = true
                end if
            else if ControlNextLevel(id)
                NextLevel()
                m.jumpman.usedCheat = true
            else if ControlPreviousLevel(id)
                PreviousLevel()
                m.jumpman.usedCheat = true
            else
                'm.jumpman.cursors.update(id)
            end if
        else if event = invalid
            'Game screen process
            ticks = m.clock.TotalMilliseconds()
            if ticks > m.speed
                if m.newLevel then LevelStartup()
                'Update sprites
                if m.board.redraw then DrawBoard()
                JumpmanUpdate()
                KongUpdate()
                ObjectsUpdate()
                'SoundUpdate()
                'Paint Screen
                m.compositor.AnimationTick(ticks)
                m.compositor.DrawAll()
                DrawScore()
                m.mainScreen.SwapBuffers()
                m.clock.Mark()
                'Check jumpman death
                if not m.gameOver
                    if not m.jumpman.alive
                        'PlaySound("dead")
                        m.jumpman.health--
                        if m.jumpman.health > 0
                            ResetGame()
                        else
                            m.gameOver = true
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
    m.board.sprite = m.compositor.NewSprite(0, 0, rgn, m.const.BOARD_Z)
    m.board.sprite.SetMemberFlags(0)
    m.board.redraw = false
End Sub

Sub DrawScore()

End Sub

Sub JumpmanUpdate()

End Sub

Sub KongUpdate()

End Sub

Sub ObjectsUpdate()

End Sub

Sub LevelStartup()
    m.newLevel = false
End Sub

Function CheckLevelSuccess() as boolean
    return false
End Function

Sub DestroyChars()

End Sub

Sub DestroyStage()
    if m.board.sprite <> invalid
        m.board.sprite.Remove()
        m.board.sprite = invalid
    end if
End Sub

Sub GameOver()

End Sub

Function ControlNextLevel(id as integer) as boolean
    vStatus = m.settings.controlMode = m.const.CONTROL_VERTICAL and id = m.code.BUTTON_A_PRESSED
    hStatus = m.settings.controlMode = m.const.CONTROL_HORIZONTAL and id = m.code.BUTTON_FAST_FORWARD_PRESSED
    return vStatus or hStatus
End Function

Function ControlPreviousLevel(id as integer) as boolean
    vStatus = m.settings.controlMode = m.const.CONTROL_VERTICAL and id = m.code.BUTTON_B_PRESSED
    hStatus = m.settings.controlMode = m.const.CONTROL_HORIZONTAL and id = m.code.BUTTON_REWIND_PRESSED
    return vStatus or hStatus
End Function
