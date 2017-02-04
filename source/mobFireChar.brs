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

Function CreateFire(charType as integer, x as integer, y as integer, ox as integer, oy as integer, dir as integer, spawn = false as boolean) as object
    this = {}
    'Constants
    this.const = m.const
    this.MOVE_STOP   = 0
    this.MOVE_LEFT   = 1
    this.MOVE_RIGHT  = 2
    this.MOVE_DOWN   = 3
    this.MOVE_UP     = 4
    this.MOVE_LSPAWN = 5
    this.MOVE_RSPAWN = 6
    'Properties
    this.board = m.board
    this.type = charType
    if charType = m.const.FIRE_BALL
        print "Launch a new fire ball!"
        this.name = "fireball-red"
        this.cx = 10
        this.cy = 16
        this.cw = 12
        this.ch = 12
    else
        print "Launch a new fire fox!"
        this.name = "firefox-red"
        this.cx = 12
        this.cy = 14
        this.cw = 12
        this.ch = 14
    end if
    if dir = m.const.FACE_RIGHT
        if spawn then this.move = this.MOVE_RSPAWN else this.move = this.MOVE_RIGHT
        this.animation = "fireRight"
        this.frameName = this.name + "-3"
    else
        if spawn then this.move = this.MOVE_LSPAWN else this.move = this.MOVE_LEFT
        this.animation = "fireLeft"
        this.frameName = this.name + "-1"
    end if
    this.frame = 0
    this.blockX = x
    this.blockY = y
    this.offsetX = ox
    this.offsetY = oy
    this.step = 0
    this.stepMax = 16
    this.bounce = 0
    this.z = m.const.OBJECTS_Z - 1
    this.collide = true
    this.visible = true
    this.takeLadder = false
    'Methods
    this.update = update_fire
    this.changePath = change_path_fire
    return this
End Function

Sub update_fire(jumpmanX as integer, jumpmanY as integer)
    curBlock = GetBlockType(m.blockX, m.blockY)
    curFloor = GetFloorOffset(m.blockX, m.blockY)
    upBlock = invalid
    downBlock = invalid
    if m.blockY > 0 then upBlock = GetBlockType(m.blockX, m.blockY - 1)
    if m.blockY < m.const.BLOCKS_Y - 1 then downBlock = GetBlockType(m.blockX, m.blockY + 1)
    if m.move >= m.MOVE_LSPAWN
        stepX = [-2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2]
        stepY = [-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-4,-4,-4, 0, 0, 0, 0, 2]
        if m.move = m.MOVE_LSPAWN then m.offsetX -= stepX[m.step] else m.offsetX += stepX[m.step]
        if m.offsetX >= m.const.BLOCK_WIDTH / 4
            m.blockX++
            m.offsetX -= m.const.BLOCK_WIDTH
        else if m.blockX > 0 and m.offsetX <= -(m.const.BLOCK_WIDTH)
            m.blockX--
            m.offsetX += m.const.BLOCK_WIDTH
        end if
        m.offsetY += stepY[m.step]
        if m.offsetY >= m.const.BLOCK_HEIGHT
            m.blockY++
            m.offsetY -= m.const.BLOCK_HEIGHT
            if m.offsetY < 2 then m.offsetY = 0
        end if
        if m.step < stepX.Count() - 1 then m.step++
        curFloor = GetFloorOffset(m.blockX, m.blockY)
        if IsFloorDown(curBlock) and m.offsetY >= curFloor and m.offsetY-curFloor <= 4
            m.frame = 0
            m.offsetY = curFloor
            m.changePath()
        end if
    else
        canClimbUp = IsAnyTopLadder(curBlock) or (curFloor = m.offsetY and IsAnyLadder(upBlock))
        canClimbDn = (IsAnyLadder(curBlock) or IsAnyLadder(downBlock)) and jumpmanY > m.blockY
        if m.move = m.MOVE_UP or (canClimbUp and m.takeLadder and m.move <> m.MOVE_DOWN)
            m.move = m.MOVE_UP
            m.offsetX = -7
            m.offsetY -= 1
            if m.offsetY < 0
                m.blockY--
                m.offsetY += m.const.BLOCK_HEIGHT
            end if
            if (IsFloor(curBlock) or not IsAnyLadder(upBlock)) and m.offsetY <= GetFloorOffset(m.blockX, m.blockY)
                m.offsetY = GetFloorOffset(m.blockX, m.blockY)
                m.changePath()
            end if
        else if m.move = m.MOVE_DOWN or (canClimbDn and m.takeLadder and m.move <> m.MOVE_UP)
            m.move = m.MOVE_DOWN
            m.offsetX = -7
            m.offsetY += 1
            if m.offsetY >= m.const.BLOCK_HEIGHT
                m.blockY++
                m.offsetY -= m.const.BLOCK_HEIGHT
            end if
            if not IsAnyLadder(downBlock) and m.offsetY > GetFloorOffset(m.blockX, m.blockY)
                m.offsetY = GetFloorOffset(m.blockX, m.blockY)
                m.changePath()
            end if
        else if m.offsetY = GetFloorOffset(m.blockX, m.blockY)
            if m.move = m.MOVE_RIGHT
                sideBlock = GetBlockType(m.blockX + 1, m.blockY)
                sideOffset = GetFloorOffset(m.blockX + 1, m.blockY)
                if (m.blockX < m.const.BLOCKS_X - 1 or m.offsetX < -(m.const.BLOCK_WIDTH / 4)) and sideOffset <> -1 and not IsTileEmpty(sideBlock)
                    m.offsetX += 2
                    if m.offsetX >= m.const.BLOCK_WIDTH / 4
                        m.blockX++
                        m.offsetX -= m.const.BLOCK_WIDTH
                    end if
                else
                    m.move = m.MOVE_LEFT
                end if
            else if m.move = m.MOVE_LEFT
                sideBlock = GetBlockType(m.blockX - 1, m.blockY)
                sideOffset = GetFloorOffset(m.blockX - 1, m.blockY)
                if (sideBlock <> m.const.MAP_INV_WALL or m.offsetX > 0) and sideOffset <> -1 and not IsTileEmpty(sideBlock)
                    m.offsetX -= 2
                    if m.blockX > 0 and m.offsetX <= -(m.const.BLOCK_WIDTH)
                        m.blockX--
                        m.offsetX += m.const.BLOCK_WIDTH
                    end if
                else
                    m.move = m.MOVE_RIGHT
                end if
            end if
            if m.offsetY <> GetFloorOffset(m.blockX, m.blockY)
                m.offsetY = GetFloorOffset(m.blockX, m.blockY)
            end if
            m.step++
            if m.step = m.stepMax then m.changePath()
            if m.move = m.MOVE_RIGHT
                m.animation = "fireRight"
            else if m.move = m.MOVE_LEFT
                m.animation = "fireLeft"
            end if
        end if
    end if
End Sub

Sub change_path_fire()
    if m.moves = invalid then m.moves = [0, 1, 1, 1, 2, 2, 2]
    m.move = m.moves[Rnd(7) - 1]
    m.step = 0
    if m.move = m.MOVE_STOP
        m.stepMax = 16
        m.takeLadder = false
    else
        if m.steps = invalid then m.steps = [4, 8, 16, 32, 64, 128]
        m.stepMax = m.steps[Rnd(6) - 1]
        m.takeLadder = (Rnd(4) = 4 and not m.takeLadder)
    end if
End Sub
