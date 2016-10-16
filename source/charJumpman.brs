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

Function CreateJumpman(board as object) as object
    this = {}
    'Constants
    this.const = m.const
    this.STATE_STOP = 0
    this.STATE_MOVE = 1
    this.STATE_FALL = 2
	'Controller
	this.cursors = GetControl(m.settings.controlMode)
    this.sounds = m.sounds
    'Properties
    this.anims = m.anims
    this.charType = "jumpman"
    this.usedCheat = false
    this.health = m.const.START_HEALTH
    'Methods
    this.startBoard = start_board_jumpman
    this.update = update_jumpman
    this.move = move_jumpman
    this.frameUpdate = frame_update_jumpman
    this.frameOffsetX = frame_offset_x
    this.frameOffsetY = frame_offset_y
    this.keyU = key_u
    this.keyD = key_d
    this.keyL = key_l
    this.keyR = key_r
    this.keyJ = key_j
    'Initialize board variables
    this.startBoard(board)
    return this
End Function

Sub start_board_jumpman(board as object)
    m.alive = true
    m.board = board
    m.blockX = board.jumpman.blockX
    m.blockY = board.jumpman.blockY
    m.offsetX = 0
    m.offsetY = board.map[m.blockY][Int(m.blockX / 2)].o - 1
    m.charAction = "runRight"
    m.frameName = "mario-52"
    m.frame = 0
    m.state = m.STATE_STOP
    m.success = false
    m.cursors.reset()
    print m.board.name
End Sub

Sub update_jumpman()
    'Check level complete
    if m.blockY = 0 and m.offsetY = 0
        m.success = true
        return
    end if
    'Update jumpman position
    if m.state = m.STATE_FALL
        m.move(m.const.ACT_NONE)
    else if m.keyJ()
        m.move(m.const.ACT_JUMP)
    else if m.keyU()
        m.move(m.const.ACT_UP)
    else if m.keyD()
        m.move(m.const.ACT_DOWN)
    else if m.keyL()
        m.move(m.const.ACT_LEFT)
    else if m.keyR()
        m.move(m.const.ACT_RIGHT)
    else
        m.move(m.const.ACT_NONE)
    end if
    'Falling sound
    ' if m.state = m.STATE_FALL and m.level.status <> m.const.LEVEL_STARTUP
    '     if m.sounds.wav.clip <> "fall" or m.sounds.wav.cycles = 0
    '         PlaySound("fall")
    '     end if
    ' else if m.sounds.wav.clip = "fall"
    '     StopSound()
    ' end if
    'Update animation frame
    m.frameUpdate()
End Sub

Sub frame_update_jumpman()
    'Update animation frame
    if m.state <> m.STATE_STOP
        actionArray = m.anims.jumpman.sequence.Lookup(m.charAction)
        m.frameName = "mario-" + itostr(actionArray[m.frame].id)
        m.frame++
        if m.frame >= actionArray.Count() then m.frame = 0
    end if
End Sub

Sub move_jumpman(action)
    upBlock = invalid
    downBlock = invalid
    curBlock = GetBlockType(m.blockX, m.blockY)
    if m.blockY > 0 then upBlock = GetBlockType(m.blockX, m.blockY - 1)
    if m.blockY < m.const.BLOCKS_Y - 1 then downBlock = GetBlockType(m.blockX, m.blockY + 1)
    'Update char position
    m.state = m.STATE_STOP
    if action = m.const.ACT_JUMP
        'PlaySound("jump")
    else if action = m.const.ACT_UP
        if m.charAction = "standUp" and m.frame = 3
            m.offsetY = GetFloorOffset(m.blockX, m.blockY)
            m.state = m.STATE_STOP
        else if IsLadder(curBlock) or (IsLadder(downBlock) and m.offsetY > GetFloorOffset(m.blockX, m.blockY))
            if m.charAction <> "runUpDown" and m.charAction <> "standUp"
                m.charAction = "runUpDown"
                m.frame = 0
            end if
            m.state = m.STATE_MOVE
            m.offsetX = -7
            m.offsetY -= m.const.MOVE_Y
            if m.offsetY < 0
                m.blockY--
                m.offsetY += m.const.BLOCK_HEIGHT
                if m.offsetY <= GetFloorOffset(m.blockX, m.blockY)
                    m.charAction = "standUp"
                    m.frame = 0
                end if
            end if
        end if
    else if action = m.const.ACT_DOWN
        if (IsLadder(curBlock) and m.offsetY <= GetFloorOffset(m.blockX, m.blockY)) or IsLadder(downBlock)
            if m.charAction <> "runUpDown"
                m.charAction = "runUpDown"
                m.frame = 0
            end if
            m.state = m.STATE_MOVE
            m.offsetX = -7
            m.offsetY += m.const.MOVE_Y
            if m.offsetY >= m.const.BLOCK_HEIGHT
                m.blockY++
                m.offsetY -= m.const.BLOCK_HEIGHT
                if m.offsetY < m.const.MOVE_Y then m.offsetY = 0
            end if
        end if
    else if action = m.const.ACT_LEFT
        if m.charAction <> "runLeft"
             m.charAction = "runLeft"
             m.frame = 0
        end if
        if m.blockX > 0 or m.offsetX > 0
            m.state = m.STATE_MOVE
            m.offsetX -= m.frameOffsetX()
            if m.blockX > 0 and m.offsetX <= 0
                m.blockX--
                m.offsetX += m.const.BLOCK_WIDTH
            end if
            m.offsetY = GetFloorOffset(m.blockX, m.blockY)
        end if
    else if action = m.const.ACT_RIGHT
        if m.charAction <> "runRight"
            m.charAction = "runRight"
            m.frame = 0
        end if
        if m.blockX < m.const.BLOCKS_X-2 or m.offsetX < 0
            m.state = m.STATE_MOVE
            m.offsetX += m.frameOffsetX()
            if m.offsetX >= m.const.BLOCK_WIDTH / 4
                m.blockX++
                m.offsetX -= m.const.BLOCK_WIDTH
            end if
            m.offsetY = GetFloorOffset(m.blockX, m.blockY)
        else if m.offsetX < 0
            m.state = m.STATE_MOVE
            m.offsetX += m.const.MOVE_X
            m.offsetY = GetFloorOffset(m.blockX, m.blockY)
        end if
    end if
    'Update fall
    ' if m.state = m.STATE_FALL
    '     m.offsetX = 0
    '     m.offsetY += m.const.MOVE_Y
    '     if m.offsetY >= m.const.BLOCK_HEIGHT
    '         m.blockY++
    '         m.offsetY -= m.const.BLOCK_HEIGHT
    '         if m.offsetY < m.const.MOVE_Y then m.offsetY = 0
    '         if m.charType = "guard" then m.tryDropGold()
    '     end if
    ' end if
    if action <> m.const.ACT_NONE
        print "position: "; m.blockX; ","; m.blockY; " - offsetX="; m.offsetX; " - offsetY="; m.offsetY
    end if
End Sub

Function frame_offset_x() as integer
    actionArray = m.anims.jumpman.sequence.Lookup(m.charAction)
    return actionArray[m.frame].x
End Function

Function frame_offset_y() as integer
    actionArray = m.anims.jumpman.sequence.Lookup(m.charAction)
    return actionArray[m.frame].x
End Function

'------------ Remote Control Methods ------------
Function key_u() as boolean
    return m.cursors.up
End Function

Function key_d() as boolean
    return m.cursors.down
End Function

Function key_l() as boolean
    return m.cursors.left
End Function

Function key_r() as boolean
    return m.cursors.right
End Function

Function key_j() as boolean
    return m.cursors.jump
End Function
