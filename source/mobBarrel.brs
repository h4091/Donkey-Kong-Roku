' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Donkey Kong Channel - http://github.com/lvcabral/Donkey-Kong-Roku
' **
' **  Created: January 2017
' **  Updated: January 2017
' **
' **  Remake in BrigthScript developed by Marcelo Lv Cabral - http://lvcabral.com
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateBarrel(color as string, action as integer) as object
    this = {}
    'Constants
    this.const = m.const
    this.MOVE_LEFT  = 0
    this.MOVE_RIGHT = 1
    this.MOVE_FALL  = 2
    'Properties
    this.name = color + "b-rolling"
    this.board = m.board
    this.blockX = m.board.kong.blockX + 4.5
    this.blockY = m.board.kong.blockY
    this.offsetX = m.const.BLOCK_WIDTH / 2
    this.offsetY = m.board.map[this.blockY][Int(this.blockX / 2)].o - 1
    this.z = m.const.OBJECTS_Z - 1
    'collision box
    this.cx = 6
    this.cy = 4
    this.cw = 12
    this.ch = 12
    this.collide = true
    this.move = this.MOVE_RIGHT
    if action = m.const.BARREL_ROLL
        this.animation = "barrel-roll-" + color
        this.frameName = this.name + "-1"
    else
        this.animation = "barrel-fall-" + color
        this.frameName = this.name + "-5"
    end if
    this.frame = 0
    this.visible = true
    this.onLadder = false
    'Methods
    this.update = update_barrel
    this.takeLadder = take_ladder
    return this
End Function

Sub update_barrel(jumpmanY as integer)
    curBlock = GetBlockType(m.blockX, m.blockY)
    downBlock = invalid
    if m.blockY < m.const.BLOCKS_Y - 1 then downBlock = GetBlockType(m.blockX, m.blockY + 1)
    if m.move < m.MOVE_FALL
        if (IsAnyLadder(curBlock) and m.offsetY < GetFloorOffset(m.blockX, m.blockY)) or (IsAnyLadder(downBlock) and m.takeLadder())
            if Left(m.animation, 11) = "barrel-roll"
                m.animation = m.animation.Replace("roll", "fall")
                m.frameName = m.name + "-5"
                m.frame = 0
                if m.move = m.MOVE_LEFT then m.move = m.MOVE_RIGHT else m.move = m.MOVE_LEFT
                m.onLadder = true
            end if
            m.offsetX = -8
            m.offsetY += 4
            if m.offsetY >= m.const.BLOCK_HEIGHT
                m.blockY++
                m.offsetY -= m.const.BLOCK_HEIGHT
            end if
            if not IsAnyLadder(downBlock) and m.offsetY > GetFloorOffset(m.blockX, m.blockY)
                m.offsetY = GetFloorOffset(m.blockX, m.blockY)
            end if
        else if m.offsetY = GetFloorOffset(m.blockX, m.blockY)
            if Left(m.animation, 11) = "barrel-fall"
                m.animation = m.animation.Replace("fall", "roll")
                m.frameName = m.name + "-1"
                m.frame = 0
                m.onLadder = false
            end if
            if m.move = m.MOVE_RIGHT
                m.offsetX += 4
                if m.offsetX >= m.const.BLOCK_WIDTH / 4
                    m.blockX++
                    m.offsetX -= m.const.BLOCK_WIDTH
                end if
            else
                m.offsetX -= 4
                if m.blockX > 0 and m.offsetX <= -(m.const.BLOCK_WIDTH)
                    m.blockX--
                    m.offsetX += m.const.BLOCK_WIDTH
                end if
            end if
            if downBlock <> invalid then downBlock = GetBlockType(m.blockX, m.blockY + 1)
            if GetFloorOffset(m.blockX, m.blockY) = -1 or IsTileEmpty(GetBlockType(m.blockX, m.blockY))
                if IsTileEmpty(downBlock)
                    m.move = m.MOVE_FALL
                else if downBlock <> invalid
                    newFloor = GetFloorOffset(m.blockX, m.blockY + 1)
                    if m.offsetY + newFloor > m.const.BLOCK_HEIGHT
                        m.move = m.MOVE_FALL
                    else
                        m.blockY++
                        m.offsetY = newFloor
                    end if
                end if
            else if m.offsetY <> GetFloorOffset(m.blockX, m.blockY)
                m.offsetY = GetFloorOffset(m.blockX, m.blockY)
            end if
        end if
    end if
    if m.move = m.MOVE_FALL
        curFloor = GetFloorOffset(m.blockX, m.blockY)
        if IsFloorDown(curBlock) and m.offsetY >= curFloor and m.offsetY-curFloor <= 4
            m.frame = 0
            if jumpmanY >= m.blockY - 1 or m.name.left(1) = "b"
                if m.blockX > m.const.BLOCKS_X / 2
                    m.move = m.MOVE_LEFT
                else
                    m.move = m.MOVE_RIGHT
                end if
            else
                if m.blockX > m.const.BLOCKS_X / 2
                    m.move = m.MOVE_RIGHT
                else
                    m.move = m.MOVE_LEFT
                end if
            end if
            m.offsetY = curFloor
            m.bounce = 0
        else
            if m.blockX > m.const.BLOCKS_X / 2
                m.offsetX += 2
            else
                m.offsetX -= 2
            end if
            m.offsetY += 4
            if m.offsetY >= m.const.BLOCK_HEIGHT
                m.blockY++
                m.offsetY -= m.const.BLOCK_HEIGHT
                if m.offsetY < 2 then m.offsetY = 0
            end if
        end if
    end if
End Sub

Function take_ladder() as boolean
    g = GetGlobalAA()
    if m.OnLadder then return true
    if not g.oilOnFire then return true
    if g.jumpman.blockY < m.blockY then return false
    R = rnd(256) - 1 'random number between 0 and 255 inclusive
    R2 = R mod 3 'random number between 0 and 3 inclusive, based on R
    if R2 >= ((g.difficulty.level \ 2 ) + 1) then return false
    if m.blockX = g.jumpman.blockX then return true
    if m.blockX < g.jumpman.blockX and g.jumpman.keyL() then return true
    if m.blockX > g.jumpman.blockX and g.jumpman.keyR() then return true
    '75% chance of return without ladder
    if (R and &H18) <> 0 return false
    '25% chance of taking ladder
    return true
End Function
