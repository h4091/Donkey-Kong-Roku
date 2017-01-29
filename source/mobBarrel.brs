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
    this.board = m.board
    this.name = color + "b-rolling"
    this.action = action
    if action = m.const.BARREL_ROLL
        print "Roll a new barrel!"
        this.animation = "barrel-roll-" + color
        this.frameName = this.name + "-1"
        this.blockX = m.board.kong.blockX + 4.5
        this.blockY = m.board.kong.blockY
        this.offsetX = m.const.BLOCK_WIDTH / 2
        this.offsetY = m.board.map[this.blockY][Int(this.blockX / 2)].o - 1
        this.cx = 6
        this.cy = 4
        this.cw = 12
        this.ch = 12
        this.move = this.MOVE_RIGHT
        this.wild = 0
    else
        print "Drop a new wild barrel!"
        this.animation = "barrel-fall-" + color
        this.frameName = this.name + "-5"
        this.blockX = m.board.kong.blockX + 1.5
        this.blockY = m.board.kong.blockY
        this.offsetX = m.const.BLOCK_WIDTH / 2 + 2
        this.offsetY = m.board.map[this.blockY][Int(this.blockX / 2)].o - 11
        this.cx = 6
        this.cy = 4
        this.cw = 20
        this.ch = 12
        this.move = this.MOVE_FALL
        if m.kong.barrels = 0
            if m.currentLevel = 1 then this.wx = 0 else this.wx = 3
            this.wild = 0 'first barrel of each level
        else if m.difficulty.level <= 2
            this.wild = 1
        else if m.difficulty.level <= 4
            this.wild = 2
        else
            this.wild = 3
        end if
    end if
    this.z = m.const.OBJECTS_Z - 1
    this.collide = true
    this.frame = 0
    this.visible = true
    this.onLadder = false
    this.lastY = 0
    'Methods
    this.update = update_barrel
    this.takeLadder = take_ladder
    this.setWildOffset = set_wild_offset
    return this
End Function

Sub update_barrel(jumpmanX as integer, jumpmanY as integer)
    curBlock = GetBlockType(m.blockX, m.blockY)
    downBlock = invalid
    if m.blockY < m.const.BLOCKS_Y - 1 then downBlock = GetBlockType(m.blockX, m.blockY + 1)
    if m.move < m.MOVE_FALL
        if (IsAnyLadder(curBlock) and m.offsetY < GetFloorOffset(m.blockX, m.blockY)) or (IsAnyLadder(downBlock) and m.takeLadder())
            if Left(m.animation, 11) = "barrel-roll"
                m.animation = m.animation.Replace("roll", "fall")
                m.frameName = m.name + "-5"
                m.cw = 20
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
                m.cw = 12
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
    if m.action = m.const.BARREL_WILD and m.move = m.MOVE_FALL
        curFloor = GetFloorOffset(m.blockX, m.blockY)
        if m.blockY < m.const.BLOCKS_Y - 1 or m.offsetY < curFloor
            'Vertical velocity
            if IsFloorDown(curBlock) and m.offsetY >= curFloor
                if m.wild > 0 and m.blockY > m.lastY
                    m.setWildOffset(jumpmanX)
                    m.lastY = m.blockY
                    print "new wx="; m.wx
                end if
                m.offsetY += 2
            else
                m.offsetY += 6
            end if
            if m.offsetY >= m.const.BLOCK_HEIGHT
                m.blockY++
                m.offsetY -= m.const.BLOCK_HEIGHT
                if m.offsetY < 2 then m.offsetY = 0
            end if
            'Horizontal velocity
            if m.wx = invalid then m.setWildOffset(jumpmanX)
            m.offsetX += m.wx
            if m.offsetX >= m.const.BLOCK_WIDTH / 4
                m.blockX++
                m.offsetX -= m.const.BLOCK_WIDTH
            else if m.blockX > 0 and m.offsetX <= -(m.const.BLOCK_WIDTH)
                m.blockX--
                m.offsetX += m.const.BLOCK_WIDTH
            end if
        else
            m.move = m.MOVE_LEFT
            m.offsetY = curFloor
            m.bounce = 0
        end if
    else if m.move = m.MOVE_FALL
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
    if g.jumpman.blockY <= m.blockY then return false
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

Sub set_wild_offset(jumpmanX as integer)
    if m.wild = 1
        m.wx = Rnd(2)
        if Rnd(4) = 4 then m.wx *= -1
    else if m.wild = 2
        dif = Abs(jumpmanX - m.blockX)
        if m.blockX < jumpmanX
            if dif > 9
                m.wx = 4
            else if dif > 3
                m.wx = 3
            else
                m.wx = 2
            end if
        else
            if dif > 3 then m.wx = -2 else m.wx = -1
        end if
    else if m.wild = 3
        if m.blockX < jumpmanX
            m.wx = Rnd(2)
        else
            m.wx = Rnd(2) * -1
        end if
    end if
End Sub
