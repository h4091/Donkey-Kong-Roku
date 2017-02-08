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

Function CreateSpring(x as integer, y as integer, ox = 0 as integer) as object
    this = {}
    'Constants
    this.const = m.const
    'Properties
    print "Launch a new Spring!"
    this.name = "spring"
    this.animation = "spring"
    this.frameName = this.name + "-1"
    this.frame = 0
    this.blockX = x
    this.blockY = y
    this.offsetX = ox
    this.offsetY = GetFloorOffset(x, y)
    this.z = m.const.OBJECTS_Z - 2
    this.collide = true
    this.visible = true
    this.step = 0
    this.bounce = {floor: y, on: true}
    'Methods
    this.update = update_spring
    return this
End Function

Sub update_spring()
    if m.bounce.on
        stepX = [ 8,  8,  8, 8, 8, 4, 4, 8, 8, 8,  8, 8]
        stepY = [-8,-16,-16,-8,-8,-4, 0, 4, 8, 8, 16, 8]
        m.offsetX += stepX[m.step]
        if m.offsetX >= m.const.BLOCK_WIDTH / 4
            m.blockX++
            m.offsetX -= m.const.BLOCK_WIDTH
        end if
        m.offsetY += stepY[m.step]
        if m.offsetY >= m.const.BLOCK_HEIGHT
            m.blockY++
            m.offsetY -= m.const.BLOCK_HEIGHT
            if m.offsetY < 2 then m.offsetY = 0
        end if
        curFloor = GetFloorOffset(m.blockX, m.blocky)
        if m.step < stepX.Count() - 1
            m.step++
        else if m.blockY = m.bounce.floor
            if curFloor > 0 and Abs(curFloor - m.offsetY) <= 2
                PlaySound("spring")
                m.offsetY = curFloor
                m.step = 0
            else if curFloor = -1
                m.bounce.on = false
                PlaySound("fall")
            end if
        end if
    else
        m.offsetY += 8
        if m.offsetY >= m.const.BLOCK_HEIGHT
            m.blockY++
            m.offsetY -= m.const.BLOCK_HEIGHT
        end if
    end if
End Sub
