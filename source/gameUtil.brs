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

Function GetConstants() as object
    const = {}

    const.TILE_WIDTH    = 20
    const.TILE_HEIGHT   = 22
    const.GROUND_HEIGHT = 10

    const.MOVE_X = 4
    const.MOVE_Y = 4

    const.START_HEALTH = 3
    const.LIMIT_HEALTH = 5

    const.MENU_START    = 0
    const.MENU_CONTROL  = 1
    const.MENU_HISCORES = 2
    const.MENU_CREDITS  = 3

    const.MAP_EMPTY = 0
    const.MAP_BLOCK = 1
    const.MAP_SOLID = 2
    const.MAP_LADDR = 3
    const.MAP_BAR   = 4
    const.MAP_TRAP  = 5
    const.MAP_HLADR = 6
    const.MAP_GOLD  = 7
    const.MAP_RUNNR = 8
    const.MAP_GUARD = 9

    const.SCORE_COMPLETE = 1500
    const.SCORE_JUMP     = 100

    const.CONTROL_VERTICAL   = 0
    const.CONTROL_HORIZONTAL = 1

    const.BOARD_Z = 20
    const.CHARS_Z = 30

    const.MESSAGEBOX_YES = 1
    const.MESSAGEBOX_NO = 2
    const.MESSAGEBOX_CANCEL = 3

    return const
End Function

Function LoadBitmapRegions(path as string, jsonFile as string, pngFile = "" as string) as object
    if pngFile = ""
        pngFile = jsonFile
    end if
    print "loading ";path + jsonFile + ".json"
    json = ParseJson(ReadAsciiFile(path + jsonFile + ".json"))
    regions = {}
    if json <> invalid
        bitmap = CreateObject("roBitmap", path + pngFile + ".png")
        for each name in json.frames
            frame = json.frames.Lookup(name).frame
            regions.AddReplace(name, CreateObject("roRegion", bitmap, frame.x, frame.y, frame.w, frame.h))
        next
    end if
    return regions
End Function

Function GetManifestArray() as Object
    manifest = ReadAsciiFile("pkg:/manifest")
    lines = manifest.Tokenize(chr(10))
    aa = {}
    for each line in lines
        entry = line.Tokenize("=")
        aa.AddReplace(entry[0],entry[1].Trim())
    end for
    print aa
    return aa
End Function

'------- String Functions -------

Function itostr(i as integer) as string
    str = Stri(i)
    return strTrim(str)
End Function

Function strTrim(str as String) as string
    st = CreateObject("roString")
    st.SetString(str)
    return st.Trim()
End Function

Function zeroPad(number as integer, length = invalid) as string
    text = itostr(number)
    if length = invalid then length = 2
    if text.Len() < length
        for i = 1 to length-text.Len()
            text = "0" + text
        next
    end if
    return text
End Function

Function padCenter(text as string, size as integer) as string
    if Len(text) > size then text.Left(text, size)
    if Len(text) < size
        left = ""
        right = ""
        for c = 1 to size - Len(text)
            if c mod 2 = 0
                left += " "
            else
                right += " "
            end if
        next
        text = left + text + right
    end if
    return text
End Function

Function padLeft(text as string, size as integer) as string
    if Len(text) > size then text.Left(text, size)
    if Len(text) < size
        for c = 1 to size - Len(text)
            text += " "
        next
    end if
    return text
End Function

'------- Device Check Functions -------

Function IsHD()
    di = CreateObject("roDeviceInfo")
    return (di.GetUIResolution().name <> "sd")
End Function

Function IsfHD()
    di = CreateObject("roDeviceInfo")
    return(di.GetUIResolution() = "fhd")
End Function

Function IsOpenGL() as Boolean
    di = CreateObject("roDeviceInfo")
    model = Val(Left(di.GetModel(),1))
    return (model = 3 or model = 4 or model = 6)
End Function

'------- Roku Screens Functions ----

Function MessageDialog(title, text, port = invalid, buttons = 3 as integer) as integer
    if port = invalid then port = CreateObject("roMessagePort")
    d = CreateObject("roMessageDialog")
    d.SetTitle(title)
    d.SetText(text)
    d.SetMessagePort(port)
    if buttons = 1
        d.AddButton(1, "OK")
    else
        d.AddButton(1, "Yes")
        d.AddButton(2, "No")
        if buttons = 3 then d.AddButton(3, "Cancel")
    end if
    d.EnableOverlay(true)
    d.Show()
    result = 0
    while true
        msg = wait(0, port)
        if msg.isScreenClosed()
            exit while
        else if msg.isButtonPressed()
            result = msg.GetIndex()
            exit while
        end if
    end while
    return result
End Function

Function KeyboardScreen(title = "", prompt = "", text = "", button1 = "Okay", button2= "Cancel", secure = false, port = invalid) as string
    if port = invalid then port = CreateObject("roMessagePort")
    result = ""
    port = CreateObject("roMessagePort")
    screen = CreateObject("roKeyboardScreen")
    screen.SetMessagePort(port)
    screen.SetTitle(title)
    screen.SetDisplayText(prompt)
    screen.SetText(text)
    screen.AddButton(1, button1)
    screen.AddButton(2, button2)
    screen.SetSecureText(secure)
    screen.Show()
    while true
        msg = wait(0, port)

        if type(msg) = "roKeyboardScreenEvent" then
            if msg.isScreenClosed()
                exit while
            else if msg.isButtonPressed()
                if msg.GetIndex() = 1 and screen.GetText().Trim() <> "" 'Ok
                    result = screen.GetText()
                    exit while
                else if msg.GetIndex() = 2 'Cancel
                    result = ""
                    exit while
                end if
            end if
        end if
    end while
    screen.Close()
    return result
End function

'------- Registry Functions -------
Function GetRegistryString(key as String, default = "") As String
    sec = CreateObject("roRegistrySection", "DonkeyKong")
    if sec.Exists(key)
        return sec.Read(key)
    end if
    return default
End Function

Sub SaveRegistryString(key as string, value as string)
    sec = CreateObject("roRegistrySection", "DonkeyKong")
    sec.Write(key, value)
    sec.Flush()
End Sub

Sub SaveSettings(settings as object)
    SaveRegistryString("Settings", FormatJSON({settings: settings}, 1))
End Sub

Function LoadSettings() as dynamic
    settings = invalid
    json = GetRegistryString("Settings")
    if json <> ""
        obj = ParseJSON(json)
        if obj <> invalid
            settings = obj.settings
        end if
    end if
    if settings = invalid then settings = {}
    if settings.controlMode = invalid then settings.controlMode = m.const.CONTROL_VERTICAL
    if settings.startLevel = invalid then settings.startLevel = 1
    return settings
End Function

'------- Remote Control Functions -------

Function GetControl(controlMode as integer) as object
    this = {
            code: bslUniversalControlEventCodes()
            up: false
            down: false
            left: false
            right: false
            dig: false
            digLeft: false
            digRight: false
           }
    if controlMode = m.const.CONTROL_VERTICAL
        this.update = update_control_vertical
    else
        this.update = update_control_horizontal
    end if
    this.reset = reset_control
    return this
End Function

Sub update_control_vertical(id as integer)
    if id = m.code.BUTTON_UP_PRESSED
        m.up = true
        m.down = false
    else if id = m.code.BUTTON_DOWN_PRESSED
        m.up = false
        m.down = true
    else if id = m.code.BUTTON_LEFT_PRESSED
        m.left = true
        m.right = false
    else if id = m.code.BUTTON_RIGHT_PRESSED
        m.left = false
        m.right = true
    else if id = m.code.BUTTON_SELECT_PRESSED
        m.dig = true
    else if id = m.code.BUTTON_REWIND_PRESSED
        m.digLeft = true
        m.dig = true
    else if id = m.code.BUTTON_FAST_FORWARD_PRESSED
        m.digRight = true
        m.dig = true
    else if id = m.code.BUTTON_UP_RELEASED
        m.up = false
    else if id = m.code.BUTTON_DOWN_RELEASED
        m.down = false
    else if id = m.code.BUTTON_LEFT_RELEASED
        m.left = false
    else if id = m.code.BUTTON_RIGHT_RELEASED
        m.right = false
    else if id = m.code.BUTTON_SELECT_RELEASED
        m.dig = false
    else if id = m.code.BUTTON_REWIND_RELEASED
        m.digLeft = false
        m.dig = false
    else if id = m.code.BUTTON_FAST_FORWARD_RELEASED
        m.digRight = false
        m.dig = false
    end if
End Sub

Sub update_control_horizontal(id as integer)
    if id = m.code.BUTTON_RIGHT_PRESSED
        m.up = true
    else if id = m.code.BUTTON_LEFT_PRESSED
        m.down = true
    else if id = m.code.BUTTON_UP_PRESSED
        m.left = true
    else if id = m.code.BUTTON_DOWN_PRESSED
        m.right = true
    else if id = m.code.BUTTON_SELECT_PRESSED
        m.dig = true
    else if id = m.code.BUTTON_A_PRESSED
        m.digLeft = true
        m.dig = true
    else if id = m.code.BUTTON_B_PRESSED
        m.digRight = true
        m.dig = true
    else if id = m.code.BUTTON_RIGHT_RELEASED
        m.up = false
    else if id = m.code.BUTTON_LEFT_RELEASED
        m.down = false
    else if id = m.code.BUTTON_UP_RELEASED
        m.left = false
    else if id = m.code.BUTTON_DOWN_RELEASED
        m.right = false
    else if id = m.code.BUTTON_SELECT_RELEASED
        m.dig = false
    else if id = m.code.BUTTON_A_RELEASED
        m.digLeft = false
        m.dig = false
    else if id = m.code.BUTTON_B_RELEASED
        m.digRight = false
        m.dig = false
    end if
End Sub

Sub reset_control()
    m.up = false
    m.down = false
    m.left = false
    m.right = false
    m.dig = false
    m.digLeft = false
    m.digRight = false
End Sub
