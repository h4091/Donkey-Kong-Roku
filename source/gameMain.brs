' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Donkey Kong Channel - http://github.com/lvcabral/Donkey-Kong-Roku
' **
' **  Created: October 2016
' **  Updated: February 2017
' **
' **  Remake in BrigthScript developed by Marcelo Lv Cabral - http://lvcabral.com
' ********************************************************************************************************
' ********************************************************************************************************
Library "v30/bslDefender.brs"

Sub Main()
    'Constants
    m.code = bslUniversalControlEventCodes()
    m.const = GetConstants()
    m.colors = {black: &hFF, white: &hFFFFFFFF, darkgray: &h0F0F0FFF, red: &hFF0000FF, green: &h00FF00FF, blue: &h0000FFFF, cyan: &h00FFFFFF, yellow: &hFFD800FF}
    'Util objects
    app = CreateObject("roAppManager")
    app.SetTheme(GetTheme())
    m.port = CreateObject("roMessagePort")
    m.clock = CreateObject("roTimespan")
    m.timer = CreateObject("roTimespan")
    m.audioPlayer = CreateObject("roAudioPlayer")
    m.audioPort = CreateObject("roMessagePort")
    m.audioPlayer.SetMessagePort(m.audioPort)
    m.sounds = LoadSounds(true)
    m.files = CreateObject("roFileSystem")
    m.fonts = CreateObject("roFontRegistry")
    m.fonts.Register("pkg:/assets/fonts/PressStart2P.ttf")
    m.gameFont = m.fonts.getFont("Press Start 2P", 16, false, false)
    m.manifest = GetManifestArray()
    m.settings = LoadSettings()
    m.isOpenGL = isOpenGL()
    selection = m.const.MENU_START
    LoadGameSprites()
    LoadAnimations()
    'Main Menu Loop
    while true
        'Configure screen/game areas based on the configuration
        SetupGameScreen()
        'print "Starting menu..."
        selection = StartMenu(selection)
        if selection = m.const.MENU_START
            print "Starting game..."
            m.gameScore = 0
            m.highScore = m.settings.highScores[0].score
            m.currentLevel = 1
            m.currentBoard = 1
            m.speed = m.const.GAME_SPEED
            m.yOff = 20
            ResetGame()
            GameLogo(3000)
            IntroScene()
            LevelHeightScreen()
            PlayGame()
        else if selection = m.const.MENU_CREDITS
            ShowCredits()
        else if selection = m.const.MENU_HISCORES
            ShowHighScores()
        end if
    end while
End Sub

Sub GameLogo(waitTime as integer)
    screen = m.mainScreen
    Sleep(500) ' Give time to Roku clear list screen from memory
    screen.Clear(m.colors.black)
    screen.SwapBuffers()
    imgIntro1 = "pkg:/assets/images/start-screen-1.png"
    imgIntro2 = "pkg:/assets/images/start-screen-2.png"
    bmp1 = CreateObject("roBitmap", imgIntro1)
    bmp2 = CreateObject("roBitmap", imgIntro2)
    centerX = Cint((screen.GetWidth() - bmp1.GetWidth()) / 2)
    centerY = Cint((screen.GetHeight() - bmp1.GetHeight()) / 2)
    screen.Clear(m.colors.black)
    for s = 0 to 31
        if IsOdd(s)
            screen.DrawObject(centerX, centerY, bmp1)
        else
            screen.DrawObject(centerX, centerY, bmp2)
        end if
        screen.SwapBuffers()
        sleep(30)
    next
	while true
    	key = wait(waitTime, m.port)
		if key = invalid or key < 100 then exit while
	end while
End Sub

Sub ResetGame()
    g = GetGlobalAA()
    print "Reseting Level "; itostr(g.currentLevel)
    if g.board <> invalid
        DestroyChars()
        DestroyStage()
    end if
    'Update board map
    if g.maps = invalid
        path = "pkg:/assets/maps/"
        g.maps = ParseJson(ReadAsciiFile(path + "arcade.json"))
    end if
    order = g.settings.levelsOrder
    if m.currentLevel <= g.maps.levels[order].Count()
        g.level = g.maps.levels[order].Lookup("level-" + itostr(m.currentLevel))
    end if
    if m.currentLevel <= g.maps.bonus.Count()
        g.bonus = g.maps.bonus.Lookup("level-" + itostr(m.currentLevel))
    end if
    if m.currentLevel < 5
        g.difficulty = {timer: 0, level: m.currentLevel}
    else
        g.difficulty = {timer: 0, level: 5}
    end if
    g.currentBonus = g.bonus.value
    g.board = g.maps.boards.Lookup("board-" + itostr(g.level[m.currentBoard-1]))
    g.board.redraw = true
    g.board.timer = 0
    g.rivets = 0
    g.elevators = []
    g.belts = []
    g.fireChars = 0
    'Create Objects
    if g.objects = invalid
        g.objects = []
        for i = 0 to g.board.objects.Count() - 1
            obj = g.board.objects[i]
            g.objects.Push({name: obj.name})
            g.objects[i].blockX = obj.blockX
            g.objects[i].blockY = obj.blockY
            g.objects[i].offsetX = 0
            if g.board.map.Count() > 0
                g.objects[i].offsetY = obj.offsetY - 1
            else
                g.objects[i].offsetY = 0
            end if
            'Setup object sprite
            if obj.animation <> invalid
                g.objects[i].animation = obj.animation
                g.objects[i].frameName = obj.name + "-1"
            else if obj.side <> invalid
                g.objects[i].side = obj.side
                g.objects[i].frameName = obj.name + "-1"
            else if obj.image <> invalid
                g.objects[i].frameName = obj.image
            else
                g.objects[i].frameName = obj.name
            end if
            g.objects[i].frame = 0
            'Setup collision mask
            if obj.cx <> invalid
                g.objects[i].cx = obj.cx
                g.objects[i].cy = obj.cy
                g.objects[i].cw = obj.cw
                g.objects[i].ch = obj.ch
            end if
            g.objects[i].collide = (obj.collide = invalid or obj.collide)
            'Setup sprite Z coordinate
            if obj.z <> invalid
                g.objects[i].z = obj.z
            else
                g.objects[i].z = g.const.OBJECTS_Z
            end if
            g.objects[i].visible = (obj.visible = invalid or obj.visible)
            'Setup special objects
            if obj.name = "rivet"
                g.rivets++
                g.board.map[obj.blockY][Int(obj.blockX / 2)].rivet = true
            else if obj.name = "ladder"
                g.objects[i].state = m.const.LADDER_AT_TOP
                g.objects[i].step = 0
                g.objects[i].timer = 0
                g.objects[i].delay = Rnd(5) * 1000 'from 1s to 5s to start moving
            else if obj.name = "conveyor"
                if g.belts.Count() < obj.belt + 1
                    g.belts.Push({xl: 0, xr: 27, y: obj.blockY, conveyors: []})
                    g.belts[obj.belt].direction = obj.direction
                    g.belts[obj.belt].cement = (obj.cement = invalid or obj.cement)
                    if g.belts[obj.belt].cement
                        g.belts[obj.belt].timer = 0
                        g.belts[obj.belt].launch = Rnd(8) * 1000 'cement launch time
                    end if
                end if
                g.objects[i].belt = obj.belt
                g.belts[obj.belt].conveyors.Push(i)
                if obj.side = "L" and obj.blockX > g.belts[obj.belt].xl
                    g.belts[obj.belt].xl = CInt(obj.blockX)
                else if obj.side = "R" and obj.blockX < g.belts[obj.belt].xr
                    g.belts[obj.belt].xr = CInt(obj.blockX)
                end if
            else if obj.name = "elevator-1"
                g.objects[i].z = g.const.OBJECTS_Z + 1
                elevator = {up: obj.up, t: obj.blockY, ot: obj.offsetY, p:[]}
            else if obj.name = "platform"
                g.objects[i].elevator = g.elevators.Count()
                g.objects[i].platform = elevator.p.Count()
                elevator.p.Push({y: obj.blockY, o: obj.offsetY})
            else if obj.name = "elevator-2"
                g.objects[i].z = g.const.OBJECTS_Z + 1
                elevator.b  = obj.blockY
                elevator.ob = obj.offsetY
                g.elevators.Push(elevator)
            end if
        next
    end if
    'Create Jumpman
    if g.jumpman = invalid
        g.jumpman = CreateJumpman()
    else
        g.jumpman.startBoard(g.board)
    end if
    'Create Kong
    g.kong = CreateKong()
    'Create Lady
    if g.lady = invalid
        g.lady = {}
        g.lady.blockX = g.board.lady.blockX
        g.lady.blockY = g.board.lady.blockY
        g.lady.offsetX = 0
        g.lady.offsetY = g.board.map[g.lady.blockY][Int(g.lady.blockX / 2)].o - 1
        g.lady.face = g.board.lady.face
        g.lady.frame = 0
        g.lady.help = {color: g.board.lady.help}
    end if
    m.startup = true
    StopAudio()
    StopSound()
End Sub

Sub AddScore(points as integer)
    g = GetGlobalAA()
    if g.gameScore < m.const.POINTS_LIFE and g.gameScore + points >= m.const.POINTS_LIFE
        g.jumpman.lives++
    end if
    g.gameScore += points
    if g.gameScore > m.highScore then g.highScore = g.gameScore
End Sub

Sub LoadGameSprites()
    if m.regions = invalid then m.regions = {}
    path = "pkg:/assets/sprites/"
    'Load Regions
    if m.regions.kong = invalid
        m.regions.kong = LoadBitmapRegions(path, "kong")
        m.regions.jumpman = LoadBitmapRegions(path, "mario")
        m.regions.lady = LoadBitmapRegions(path, "pauline")
        m.regions.objects = LoadBitmapRegions(path, "objects")
    end if
End Sub

Sub LoadAnimations()
    if m.anims = invalid then m.anims = {}
    if m.anims.kong = invalid
        m.anims.kong = ParseJson(ReadAsciiFile("pkg:/assets/anims/kong.json"))
        m.anims.jumpman = ParseJson(ReadAsciiFile("pkg:/assets/anims/mario.json"))
        m.anims.lady = ParseJson(ReadAsciiFile("pkg:/assets/anims/pauline.json"))
        m.anims.objects = ParseJson(ReadAsciiFile("pkg:/assets/anims/objects.json"))
    end if
End Sub

Sub SetupGameScreen()
	if IsHD()
		m.mainWidth = 854
		m.mainHeight = 480
	else
		m.mainWidth = 640
		m.mainHeight = 480
	end if
    m.gameWidth = 448
    m.gameHeight = 480
    ResetScreen(m.mainWidth, m.mainHeight, m.gameWidth, m.gameHeight)
End Sub

Sub ResetScreen(mainWidth as integer, mainHeight as integer, gameWidth as integer, gameHeight as integer)
    g = GetGlobalAA()
    g.mainScreen = CreateObject("roScreen", true, mainWidth, mainHeight)
    g.mainScreen.SetMessagePort(g.port)
    xOff = Cint((mainWidth-gameWidth) / 2)
    drwRegions = dfSetupDisplayRegions(g.mainScreen, xOff, 0, gameWidth, gameHeight)
    g.gameScreen = drwRegions.main
    g.gameLeft = drwRegions.left
    g.gameRight = drwRegions.right
    g.gameScreen.SetAlphaEnable(true)
    g.compositor = CreateObject("roCompositor")
    g.compositor.SetDrawTo(g.gameScreen, g.colors.black)
End Sub

Function GetTheme() as object
    theme = {
            BackgroundColor: "#000000",
            OverhangSliceSD: "pkg:/images/overhang_sd.jpg",
            OverhangSliceHD: "pkg:/images/overhang_hd.jpg",
            ListScreenHeaderText: "#FFFFFF",
            ListScreenDescriptionText: "#FFFFFF",
            ListItemHighlightText: "#FFD801"
            }
    return theme
End Function

Sub Freeze(switch = true as boolean)
    g = GetGlobalAA()
    g.freeze = switch
End Sub
