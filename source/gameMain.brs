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
Library "v30/bslDefender.brs"

Sub Main()
    'Constants
    m.code = bslUniversalControlEventCodes()
    m.const = GetConstants()
    m.colors = {black: &hFF, white: &hFFFFFFFF, darkgray: &h0F0F0FFF}
    'Util objects
    app = CreateObject("roAppManager")
    app.SetTheme(GetTheme())
    m.port = CreateObject("roMessagePort")
    m.clock = CreateObject("roTimespan")
    m.audioPlayer = CreateObject("roAudioPlayer")
    m.audioPort = CreateObject("roMessagePort")
    m.audioPlayer.SetMessagePort(m.audioPort)
    'm.sounds = LoadSounds(true)
    m.files = CreateObject("roFileSystem")
    m.fonts = CreateObject("roFontRegistry")
    m.fonts.Register("pkg:/assets/fonts/PressStart2P.ttf")
    m.manifest = GetManifestArray()
    m.settings = LoadSettings()
    'm.highScores = LoadHighScores()
    m.immortal = false 'flag to enable/disable jumpman immortality
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
            m.currentLevel = 1
            m.currentBoard = 1
            m.newLevel = true
            ResetGame()
            PlayIntro(3000)
            if PlayGame() then ShowHighScores(5000)
        else if selection = m.const.MENU_CREDITS
            ShowCredits()
        else if selection = m.const.MENU_HISCORES
            ShowHighScores()
        end if
    end while
End Sub

Sub PlayIntro(waitTime as integer)
    screen = m.mainScreen
    Sleep(250) ' Give time to Roku clear list screen from memory
    if m.isOpenGL
        screen.Clear(m.colors.black)
        screen.SwapBuffers()
    end if
    imgIntro = "pkg:/assets/images/start-screen.png"
    bmp = CreateObject("roBitmap", imgIntro)
    centerX = Cint((screen.GetWidth() - bmp.GetWidth()) / 2)
    centerY = Cint((screen.GetHeight() - bmp.GetHeight()) / 2)
    screen.Clear(m.colors.black)
    screen.DrawObject(centerX, centerY, bmp)
    screen.SwapBuffers()
	while true
    	key = wait(waitTime, m.port)
        print "intro"
		if key = invalid or key < 100 then exit while
	end while
End Sub

Sub NextLevel()
    g = GetGlobalAA()
    if g.currentBoard = g.level.Count()
        g.currentBoard = 1
        g.currentLevel++
        g.newLevel = true
    else
        g.currentBoard++
    end if
    ResetGame()
End Sub

Sub PreviousLevel()
    g = GetGlobalAA()
    if g.currentBoard = 1
        g.currentBoard = g.level.Count()
        g.currentLevel--
    else
        g.currentBoard--
    end if
    ResetGame()
End Sub

Sub ResetGame()
    g = GetGlobalAA()
    print "Reseting Level "; itostr(g.currentLevel)
    if g.board <> invalid
        DestroyStage()
        if g.jumpman <> invalid and g.jumpman.sprite <> invalid
            g.jumpman.sprite.Remove()
            g.jumpman.sprite = invalid
        end if
    end if
    'Update board map
    if g.maps = invalid
        path = "pkg:/assets/maps/"
        g.maps = ParseJson(ReadAsciiFile(path + "arcade.json"))
    end if
    if m.currentLevel <= g.maps.levels.Count()
        g.level = g.maps.levels.Lookup("level-" + itostr(m.currentLevel))
    end if
    g.board = g.maps.boards.Lookup("board-" + itostr(g.level[m.currentBoard-1]))
    g.board.redraw = true
    'Create Jumpman
    if g.jumpman = invalid
        g.jumpman = {alive: true, health: 3} 'CreateJumpman(g.level)
    ' else
    '     g.jumpman.startLevel(g.level)
    end if
    'StopAudio()
    'StopSound()
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
        m.anims.jumpman = ParseJson(ReadAsciiFile("pkg:/assets/anims/jumpman.json"))
        m.anims.lady = ParseJson(ReadAsciiFile("pkg:/assets/anims/lady.json"))
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
    m.gameHeight = 448
    ResetScreen(m.mainWidth, m.mainHeight, m.gameWidth, m.gameHeight)
End Sub

Sub ResetScreen(mainWidth as integer, mainHeight as integer, gameWidth as integer, gameHeight as integer)
    g = GetGlobalAA()
    g.mainScreen = CreateObject("roScreen", true, mainWidth, mainHeight)
    g.mainScreen.SetMessagePort(g.port)
    xOff = Cint((mainWidth-gameWidth) / 2)
    yOff = Cint((mainHeight-gameHeight) / 2)
    drwRegions = dfSetupDisplayRegions(g.mainScreen, xOff, yOff, gameWidth, gameHeight)
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
