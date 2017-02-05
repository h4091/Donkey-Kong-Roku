' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Donkey Kong Channel - http://github.com/lvcabral/Donkey-Kong-Roku
' **
' **  Created: February 2017
' **  Updated: February 2017
' **
' **  Remake in BrigthScript developed by Marcelo Lv Cabral - http://lvcabral.com
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateCement(x as integer, y as integer, ox = 0 as integer) as object
    this = {}
    'Constants
    this.const = m.const
    'Properties
    print "Launch a new cement tray!"
    this.name = "cement"
    this.cx = 2
    this.cy = 6
    this.cw = 28
    this.ch = 8
    this.frameName = this.name + "-1"
    this.frame = 0
    this.blockX = x
    this.blockY = y
    this.offsetX = ox
    this.offsetY = GetFloorOffset(x, y)
    this.z = m.const.OBJECTS_Z - 1
    this.collide = true
    this.visible = true
    'Methods
    this.update = update_cement
    return this
End Function

Sub update_cement()
    direction = GetConveyorDirection(m.blockX, m.blockY)
    if direction <> "" then m.direction = direction
    if m.direction = "R"
        m.offsetX += 2
        if m.blockX < m.const.BLOCKS_X-1 and m.offsetX >= m.const.BLOCK_WIDTH / 4
            m.blockX++
            m.offsetX -= m.const.BLOCK_WIDTH
        end if
    else if m.direction = "L"
        m.offsetX -= 2
        if m.blockX > 0 and m.offsetX <= -(m.const.BLOCK_WIDTH / 2)
            m.blockX--
            m.offsetX += m.const.BLOCK_WIDTH
        end if
    end if
End Sub
