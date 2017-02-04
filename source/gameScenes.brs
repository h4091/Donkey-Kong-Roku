' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Donkey Kong Channel - http://github.com/lvcabral/Donkey-Kong-Roku
' **
' **  Created: December 2016
' **  Updated: February 2017
' **
' **  Remake in BrigthScript developed by Marcelo Lv Cabral - http://lvcabral.com
' ********************************************************************************************************
' ********************************************************************************************************

Sub IntroScene()
    print "intro scene"
    intro1 = CreateObject("roBitmap", "pkg:/assets/images/intro-1.png")
    intro2 = CreateObject("roBitmap", "pkg:/assets/images/intro-2.png")
    intro3 = CreateObject("roBitmap", "pkg:/assets/images/intro-3.png")
    w = intro1.GetWidth()
    h = intro1.GetHeight()
    m.mainScreen.Clear(0)
    m.gameScreen.DrawObject(0, m.yOff, intro2)
    DrawScore(false)
    m.mainScreen.SwapBuffers()
    Sleep(500)
    PlaySound("intro-scene")
    'Kong climbing ladder
    m.mainScreen.Clear(0)
    DrawScore(false)
    action = 0
    x = 205
    for i = 0 to 62
        m.gameScreen.DrawObject(0, m.yOff, intro1)
        rgn = CreateObject("roRegion", intro2, 0, 0, w, h - i * 4)
        m.gameScreen.DrawObject(0, m.yOff, rgn)
        if not IsOdd(i)
            y = 366 - i * 4
            if action = 5 or action = 15 then action = 6 else action = 5
            if rnd(4) = 1 then action += 10
            kong = m.regions.kong.Lookup("kong-" + itostr(action))
        end if
        m.gameScreen.DrawObject(x, y, kong)
        m.mainScreen.SwapBuffers()
        Sleep(65)
    next
    'Kong jumps to platform
    Sleep(500)
    for i = 1 to 22
        m.gameScreen.DrawObject(0, m.yOff, intro1)
        if y >= 24 + m.yOff and i < 20
            y -= 4
        else if y <= 32 + m.yOff
            y += 4
        end if
        m.gameScreen.DrawObject(x, y, kong)
        m.mainScreen.SwapBuffers()
        Sleep(40)
    next
    cutArray = [128, 194, 260, 327, 392, 448]
    x = 202
    y = 40 + m.yOff
    m.gameScreen.DrawObject(0, m.yOff, intro1)
    rgn = CreateObject("roRegion", intro3, 0, 0, w, cutArray[0])
    m.gameScreen.DrawObject(0, m.yOff, rgn)
    ladyRegion = m.regions.lady.Lookup("pauline-1")
    ladyX = m.lady.blockX * m.const.BLOCK_WIDTH
    ladyY = ((m.lady.blockY * m.const.BLOCK_HEIGHT) + m.lady.offsetY) - ladyRegion.GetHeight()
    m.gameScreen.DrawObject(ladyX, ladyY + m.yOff, ladyRegion)
    kong = m.regions.kong.Lookup("kong-1")
    m.gameScreen.DrawObject(x, y, kong)
    m.mainScreen.SwapBuffers()
    Sleep(500)
    'Kong jump left 5 times
    for c = 1 to cutArray.Count() - 1
        for i = 1 to 10
            x -= 3.2
            if i <= 5 then y -= 3 else y += 3
            m.gameScreen.DrawObject(0, m.yOff, intro1)
            rgn = CreateObject("roRegion", intro3, 0, 0, w, cutArray[c - 1])
            m.gameScreen.DrawObject(0, m.yOff, rgn)
            m.gameScreen.DrawObject(ladyX, ladyY + m.yOff, ladyRegion)
            m.gameScreen.DrawObject(x, y, kong)
            m.mainScreen.SwapBuffers()
            Sleep(50)
        next
        rgn = CreateObject("roRegion", intro3, 0, 0, w, cutArray[c])
        m.gameScreen.DrawObject(0, m.yOff, rgn)
        m.gameScreen.DrawObject(ladyX, ladyY + m.yOff, ladyRegion)
        m.gameScreen.DrawObject(x, y, kong)
        m.mainScreen.SwapBuffers()
    next
    'Kong shout 3 times
    Sleep(500)
    kong = m.regions.kong.Lookup("kong-17")
    m.gameScreen.DrawObject(0, m.yOff, rgn)
    m.gameScreen.DrawObject(ladyX, ladyY + m.yOff, ladyRegion)
    m.gameScreen.DrawObject(x, y, kong)
    m.mainScreen.SwapBuffers()
    Sleep(2000)
    kong = m.regions.kong.Lookup("kong-1")
    m.gameScreen.DrawObject(x, y, kong)
    m.mainScreen.SwapBuffers()
    Sleep(500)
    StopSound()
End Sub

Sub BoardCompleteScene()
    print "board complete scene"
    StopAudio()
    StopSound()
    x = m.lady.sprite.GetX()
    if m.lady.face = m.const.FACE_LEFT
        m.lady.frameName = "pauline-8"
        m.jumpman.frameName = "mario-52"
        x -= 32
    else
        m.lady.frameName = "pauline-3"
        m.jumpman.frameName = "mario-7"
        x += 34
    end if
    ticks = m.clock.TotalMilliseconds()
    m.jumpman.sprite.SetRegion(m.regions.jumpman.Lookup(m.jumpman.frameName))
    m.jumpman.sprite.MoveOffset(0, -2)
    m.lady.sprite.SetRegion(m.regions.lady.Lookup(m.lady.frameName))
    m.lady.help.sprite.SetDrawableFlag(false)
    rgn = m.regions.lady.Lookup("heart-1")
    m.heart = m.compositor.NewSprite(x, 4, rgn, m.const.CHARS_Z)
    m.compositor.AnimationTick(ticks)
    m.compositor.DrawAll()
    DrawScore()
    m.mainScreen.SwapBuffers()
    PlaySound("finish-board")
    'Kong break jumpman's heart
    if m.kong.belt = invalid
        m.kong.charAction = "kidnapLady"
    else
        m.kong.charAction = "kidnapConv"
        m.kong.frameName = "kong-1"
    end if
    m.kong.frame = 0
    x = m.kong.sprite.GetX()
    y = m.kong.sprite.GetY()
    m.kong.sprite.Remove()
    m.kong.sprite = invalid
    m.clock.Mark()
    while true
        ticks = m.clock.TotalMilliseconds()
        if ticks > m.speed
            if x <> 110 and m.kong.belt <> invalid
                if x > 110
                    x -= 4
                    if x < 110 then x = 110
                else if x < 110
                    x += 4
                    if x > 110 then x = 110
                end if
            else
                m.kong.update()
            end if
            if m.kong.frameName = "kong-16" and m.kong.frameOffset.y <> 0
                m.lady.sprite.SetDrawableFlag(false)
                m.heart.SetRegion(m.regions.lady.Lookup("heart-2"))
            end if
            region = m.regions.kong.Lookup(m.kong.frameName)
            if m.kong.sprite = invalid
                m.kong.sprite = m.compositor.NewSprite(x, y, region, m.const.CHARS_Z)
                m.kong.sprite.SetData("kong")
            else
                m.kong.sprite.SetRegion(region)
            end if
            if m.kong.frameName = "kong-1"
                m.kong.sprite.MoveTo(x, y)
            else
                m.kong.sprite.MoveOffset(m.kong.frameOffset.x, m.kong.frameOffset.y)
            end if
            SoundUpdate()
            'Paint Screen
            m.compositor.AnimationTick(ticks)
            m.compositor.DrawAll()
            m.gameScreen.DrawRect(110, 0, 96, 20, m.colors.black)
            DrawScore()
            m.mainScreen.SwapBuffers()
            m.clock.Mark()
            if m.sounds.wav.cycles = 0
                StopAudio()
                DestroyChars()
                DestroyStage()
                exit while
            end if
        end if
    end while
End Sub

Sub FinishLevelScene()
    print "finish level scene"
    StopAudio()
    StopSound()
    DestroyStage()
    m.speed = 50
    if IsOdd(m.currentLevel)
        PlaySound("finish-level-1")
    else
        PlaySound("finish-level-2")
    end if
    ticks = m.clock.TotalMilliseconds()
    bmp = CreateObject("roBitmap", "pkg:/assets/images/finish-1.png")
    rgn = CreateObject("roRegion", bmp, 0, 0, bmp.GetWidth(), bmp.GetHeight())
    m.board.sprite = m.compositor.NewSprite(0, m.yOff, rgn, m.const.BOARD_Z)
    m.board.sprite.SetData("finish-1")
    m.board.sprite.SetMemberFlags(0)
    if m.jumpman.blockX < 14
        m.lady.sprite.SetRegion(m.regions.lady.Lookup("pauline-8"))
    else
        m.lady.sprite.SetRegion(m.regions.lady.Lookup("pauline-3"))
    end if
    if m.lady.help.sprite <> invalid then m.lady.help.sprite.SetDrawableFlag(false)
    'Kong falls
    m.kong.charAction = "lostFloor"
    m.kong.frame = 0
    x = m.kong.sprite.GetX()
    y = m.kong.sprite.GetY()
    m.kong.sprite.Remove()
    m.kong.sprite = invalid
    m.clock.Mark()
    while true
        ticks = m.clock.TotalMilliseconds()
        if ticks > m.speed
            m.kong.update()
            if m.kong.frameName = "kong-18" and m.board.sprite.GetData() <> "finish-2"
                bmp = CreateObject("roBitmap", "pkg:/assets/images/finish-2.png")
                rgn = CreateObject("roRegion", bmp, 0, 0, bmp.GetWidth(), bmp.GetHeight())
                m.board.sprite.SetRegion(rgn)
                m.board.sprite.SetData("finish-2")
                m.board.sprite.SetMemberFlags(0)
                m.lady.sprite.MoveOffset(0, 80)
            end if
            region = m.regions.kong.Lookup(m.kong.frameName)
            if m.kong.sprite = invalid
                m.kong.sprite = m.compositor.NewSprite(x, y, region, m.const.CHARS_Z)
                m.kong.sprite.SetData("kong")
            else
                m.kong.sprite.SetRegion(region)
            end if
            m.kong.sprite.MoveOffset(m.kong.frameOffset.x, m.kong.frameOffset.y)
            if m.kong.frameEvent = "mario"
                if m.jumpman.blockX < 14
                    m.jumpman.sprite.SetRegion(m.regions.jumpman.Lookup("mario-52"))
                    m.jumpman.sprite.MoveTo(m.lady.sprite.GetX() - 64, m.lady.sprite.GetY() + 12)
                    heartX = m.lady.sprite.GetX() - 34
                else
                    m.jumpman.sprite.SetRegion(m.regions.jumpman.Lookup("mario-7"))
                    m.jumpman.sprite.MoveTo(m.lady.sprite.GetX() + 64, m.lady.sprite.GetY() + 12)
                    heartX = m.lady.sprite.GetX() + 34
                end if
            else if m.kong.frameEvent = "heart"
                rgn = m.regions.lady.Lookup("heart-1")
                m.heart = m.compositor.NewSprite(heartX, m.lady.sprite.GetY() - 16, rgn, m.const.CHARS_Z)
            end if
            SoundUpdate()
            'Paint Screen
            m.compositor.AnimationTick(ticks)
            m.compositor.DrawAll()
            DrawScore()
            m.mainScreen.SwapBuffers()
            m.clock.Mark()
            if m.sounds.wav.cycles = 0
                StopAudio()
                DestroyChars()
                DestroyStage()
                exit while
            end if
        end if
    end while
    m.speed = m.const.GAME_SPEED
End Sub
