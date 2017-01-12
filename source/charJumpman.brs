' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Donkey Kong Channel - http://github.com/lvcabral/Donkey-Kong-Roku
' **
' **  Created: October 2016
' **  Updated: January 2017
' **
' **  Remake in BrigthScript developed by Marcelo Lv Cabral - http://lvcabral.com
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateJumpman() as object
    this = {}
    'Constants
    this.const = m.const
    this.STATE_STOP = 0
    this.STATE_MOVE = 1
    this.STATE_JUMP = 2
    this.STATE_FALL = 3
	'Controller
	this.cursors = GetControl(m.settings.controlMode)
    'Properties
    this.charType = "jumpman"
    this.anims = m.anims
    this.alive = false
    this.usedCheat = false
    this.lives = m.const.START_LIVES
    this.immortal = false 'flag to enable/disable jumpman immortality
    'Methods
    this.startBoard = start_board_jumpman
    this.update = update_jumpman
    this.move = move_jumpman
    this.startFall = start_fall_jumpman
    this.frameUpdate = frame_update_jumpman
    this.getFrameName = get_frame_name_jumpman
    this.frameOffsetX = frame_offset_x
    this.frameOffsetY = frame_offset_y
    this.keyU = key_u
    this.keyD = key_d
    this.keyL = key_l
    this.keyR = key_r
    this.keyJ = key_j
    'Initialize board variables
    this.startBoard(m.board)
    return this
End Function

Sub start_board_jumpman(board as object)
    m.board = board
    m.blockX = board.jumpman.blockX
    m.blockY = board.jumpman.blockY
    m.offsetX = 0
    m.offsetY = board.map[m.blockY][Int(m.blockX / 2)].o - 1
    m.charAction = "runRight"
    m.frameName = "mario-52"
    m.frame = 0
    m.state = m.STATE_STOP
    m.platform = invalid
    m.cursors.reset()
    print m.board.name
End Sub

Sub update_jumpman()
    'Update jumpman position
    if m.state > m.STATE_MOVE
        m.move(m.const.ACT_NONE)
    else if m.keyJ() and m.keyR() and m.hammer = invalid
        m.move(m.const.ACT_JUMP_RIGHT)
    else if m.keyJ() and m.keyL() and m.hammer = invalid
        m.move(m.const.ACT_JUMP_LEFT)
    else if m.keyJ() and m.hammer = invalid
        m.move(m.const.ACT_JUMP_UP)
    else if m.keyU() and m.hammer = invalid
        m.move(m.const.ACT_CLIMB_UP)
    else if m.keyD() and m.hammer = invalid
        m.move(m.const.ACT_CLIMB_DOWN)
    else if m.keyL()
        m.move(m.const.ACT_RUN_LEFT)
    else if m.keyR()
        m.move(m.const.ACT_RUN_RIGHT)
    else
        m.move(m.const.ACT_NONE)
    end if
    'Update animation frame
    m.frameUpdate()
End Sub

Sub frame_update_jumpman()
    'Update animation frame
    if Left(m.charAction, 3) = "hit"
        if m.hammer.up then ps = "Up" else ps = "Dn"
        actionArray = m.anims.jumpman.sequence.Lookup(m.charAction + ps)
        if m.state <> m.STATE_STOP
            m.frameName = "mario-" + itostr(actionArray[m.frame].id)
        else
            m.frameName = "mario-" + itostr(actionArray[2].id)
        end if
        m.frame++
        if ((m.frame + 1) mod 4) = 0 then m.hammer.up = not m.hammer.up
        if m.frame >= actionArray.Count() then m.frame = 0
    else if m.state <> m.STATE_STOP and m.state <> m.STATE_FALL
        actionArray = m.anims.jumpman.sequence.Lookup(m.charAction)
        m.frameName = "mario-" + itostr(actionArray[m.frame].id)
        m.frame++
        if m.frame >= actionArray.Count()
            if m.state = m.STATE_MOVE
                m.frame = 0
            else
                m.frame = actionArray.Count() - 1
            end if
        end if
    end if
End Sub

Function get_frame_name_jumpman(action as string, frame as integer) as string
    actionArray = m.anims.jumpman.sequence.Lookup(action)
    return "mario-" + itostr(actionArray[frame].id)
End Function

Sub move_jumpman(action)
    upBlock = invalid
    downBlock = invalid
    curBlock = GetBlockType(m.blockX, m.blockY)
    if m.blockY > 0 then upBlock = GetBlockType(m.blockX, m.blockY - 1)
    if m.blockY < m.const.BLOCKS_Y - 1 then downBlock = GetBlockType(m.blockX, m.blockY + 1)
    'Update char position
    if m.state < m.STATE_JUMP then m.state = m.STATE_STOP
    if action = m.const.ACT_CLIMB_UP
        curFloor = GetFloorOffset(m.blockX, m.blockY)
        if m.charAction = "climbUp" and m.frame = 11
            m.offsetY = GetFloorOffset(m.blockX, m.blockY)
            m.charAction = "stand"
            m.state = m.STATE_STOP
        else if IsTopLadder(curBlock) or (IsBottomLadder(curBlock) and curFloor <> m.offsetY) or (IsLadder(downBlock) and m.offsetY > curFloor and not IsTileEmpty(curBlock)) or (curFloor = 0 and IsLadder(upBlock))
            if m.charAction <> "runUpDown" and m.charAction <> "climbUp"
                m.charAction = "runUpDown"
                m.frame = 0
            end if
            m.state = m.STATE_MOVE
            m.offsetX = -7
            m.offsetY -= m.frameOffsetY()
            if m.offsetY < 0
                m.blockY--
                m.offsetY += m.const.BLOCK_HEIGHT
            end if
            upFloor = GetFloorOffset(m.blockX, m.blockY - 1)
            if m.charAction <> "climbUp" and ((IsFloorUp(upblock) and upFloor > 0) or (IsFloorUp(curBlock) and curFloor = 0))
                if curFloor = 0
                    limitY = m.const.BLOCK_HEIGHT - 6
                else
                    limitY = upFloor - 6
                end if
                print "limitY="; limitY
                if m.offsetY <= limitY
                    print "standing up"
                    m.charAction = "climbUp"
                    m.frame = 0
                end if
            end if
        end if
    else if action = m.const.ACT_CLIMB_DOWN
        if (IsLadder(curBlock) and m.offsetY < GetFloorOffset(m.blockX, m.blockY)) or IsLadder(downBlock)
            if m.charAction <> "climbDown" and m.charAction <> "runUpDown"
                m.charAction = "climbDown"
                m.frame = 0
            else if m.charAction = "climbDown" and m.frame = 11
                m.charAction = "runUpDown"
                m.frame = 0
            end if
            m.state = m.STATE_MOVE
            m.offsetX = -7
            m.offsetY += m.frameOffsetY()
            if m.offsetY >= m.const.BLOCK_HEIGHT
                m.blockY++
                m.offsetY -= m.const.BLOCK_HEIGHT
            end if
        end if
    else if action = m.const.ACT_RUN_LEFT
        if m.offsetY = GetFloorOffset(m.blockX, m.blockY)
            if m.charAction <> "runLeft" and m.hammer = invalid
                 m.charAction = "runLeft"
                 m.frame = 0
            else if m.charAction <> "hitLeft" and m.hammer <> invalid
                m.charAction = "hitLeft"
                m.frame = 0
            end if
            if GetBlockType(m.blockX - 1, m.blockY) <> m.const.MAP_INV_WALL or m.offsetX > 0
                m.state = m.STATE_MOVE
                m.offsetX -= m.frameOffsetX()
                if m.blockX > 0 and m.offsetX <= -(m.const.BLOCK_WIDTH / 2)
                    m.blockX--
                    m.offsetX += m.const.BLOCK_WIDTH
                end if
                if downBlock <> invalid then downBlock = GetBlockType(m.blockX, m.blockY + 1)
                if GetFloorOffset(m.blockX, m.blockY) = -1
                    if IsTileEmpty(downBlock)
                        m.startFall()
                    else if downBlock <> invalid
                        newFloor = GetFloorOffset(m.blockX, m.blockY + 1)
                        if m.offsetY + newFloor > m.const.BLOCK_HEIGHT
                            m.startFall()
                        else
                            m.blockY++
                            m.offsetY = newFloor
                        end if
                    end if
                else
                    m.offsetY = GetFloorOffset(m.blockX, m.blockY)
                    if m.offsetY < 0 and m.blockY > 0
                        print "up"
                        m.blockY--
                        m.offsetY = GetFloorOffset(m.blockX, m.blockY)
                    end if
                end if
            end if
        end if
    else if action = m.const.ACT_RUN_RIGHT
        if m.offsetY = GetFloorOffset(m.blockX, m.blockY)
            if m.charAction <> "runRight" and m.hammer = invalid
                m.charAction = "runRight"
                m.frame = 0
            else if m.charAction <> "hitRight" and m.hammer <> invalid
                m.charAction = "hitRight"
                m.frame = 0
            end if
            if m.blockX < m.const.BLOCKS_X-2 or m.offsetX < 0
                m.state = m.STATE_MOVE
                m.offsetX += m.frameOffsetX()
                if m.offsetX >= m.const.BLOCK_WIDTH / 4
                    m.blockX++
                    m.offsetX -= m.const.BLOCK_WIDTH
                end if
                if downBlock <> invalid then downBlock = GetBlockType(m.blockX, m.blockY + 1)
                if GetFloorOffset(m.blockX, m.blockY) = -1 or IsTileEmpty(GetBlockType(m.blockX, m.blockY))
                    if IsTileEmpty(downBlock)
                        m.startFall()
                    else if downBlock <> invalid
                        newFloor = GetFloorOffset(m.blockX, m.blockY + 1)
                        if m.offsetY + newFloor > m.const.BLOCK_HEIGHT
                            m.startFall()
                        else
                            m.blockY++
                            m.offsetY = newFloor
                        end if
                    end if
                else
                    m.offsetY = GetFloorOffset(m.blockX, m.blockY)
                    if m.offsetY < 0 and m.blockY > 0
                        m.blockY--
                        m.offsetY = GetFloorOffset(m.blockX, m.blockY)
                    end if
                end if
            end if
        end if
    else if action = m.const.ACT_JUMP_UP
        if m.offsetY = GetFloorOffset(m.blockX, m.blockY)
            if Left(m.charAction, 4) <> "jump"
                if m.charAction = "runLeft"
                    m.charAction = "jumpLeft"
                else
                    m.charAction = "jumpRight"
                end if
                m.frame = 0
            end if
            m.jump = action
            m.state = m.STATE_JUMP
            m.startY = ((m.blockY * m.const.BLOCK_HEIGHT) + m.offsetY)
        end if
    else if action = m.const.ACT_JUMP_LEFT
        if m.offsetY = GetFloorOffset(m.blockX, m.blockY)
            if m.blockX > 0 or m.offsetX >= 0
                if Left(m.charAction, 4) <> "jump"
                    if m.charAction = "runLeft"
                        m.charAction = "jumpLeft"
                    else
                        m.charAction = "jumpRight"
                    end if
                    m.frame = 0
                end if
                m.jump = action
                m.state = m.STATE_JUMP
                m.startY = ((m.blockY * m.const.BLOCK_HEIGHT) + m.offsetY)
            end if
        end if
    else if action = m.const.ACT_JUMP_RIGHT
        if m.offsetY = GetFloorOffset(m.blockX, m.blockY)
            if Left(m.charAction, 4) <> "jump"
                if m.charAction = "runLeft"
                    m.charAction = "jumpLeft"
                else
                    m.charAction = "jumpRight"
                end if
                m.frame = 0
            end if
            m.jump = action
            m.state = m.STATE_JUMP
            m.startY = ((m.blockY * m.const.BLOCK_HEIGHT) + m.offsetY)
        end if
    end if
    'Update jump
    if m.state = m.STATE_JUMP
        curFloor = GetFloorOffset(m.blockX, m.blockY)
        if m.frame > 0 and (IsFloorDown(curBlock) or (IsElevator(curBlock) and curFloor >= 0)) and m.offsetY >= curFloor and m.offsetY-curFloor <= 4
            if m.charAction = "jumpLeft"
                m.charAction = "runLeft"
            else
                m.charAction = "runRight"
            end if
            m.frame = 2
            m.state = m.STATE_MOVE
            if IsElevator(curBlock)
                m.platform = GetPlatform(m.blockX, m.blockY)
            else
                m.platform = invalid
            end if
            m.offsetY = curFloor
            fallHeight = ((m.blockY * m.const.BLOCK_HEIGHT) + m.offsetY) - m.startY
            if fallHeight  >= m.const.BLOCK_HEIGHT
                m.alive = m.immortal
                print "landed dead "; fallHeight
            else
                print "landed safe "; fallHeight
            end if
            if m.alive and m.hammer <> invalid
                m.charAction = m.charAction.Replace("run", "hit")
                m.frame = 0
            end if
        else
            if m.jump <> m.const.ACT_JUMP_UP
                if m.jump = m.const.ACT_JUMP_LEFT
                    m.offsetX -= m.frameOffsetX()
                else
                    m.offsetX += m.frameOffsetX()
                end if
                if m.offsetX <= -1
                    m.blockX--
                    m.offsetX += m.const.BLOCK_WIDTH
                else if m.offsetX >= 1
                    m.blockX++
                    m.offsetX -= m.const.BLOCK_WIDTH
                end if
                actionArray = m.anims.jumpman.sequence.Lookup(m.charAction)
                if m.jump = m.const.ACT_JUMP_LEFT and GetBlockType(m.blockX, m.blockY) = m.const.MAP_INV_WALL
                    m.jump = m.const.ACT_JUMP_RIGHT
                    m.frame = (actionArray.Count()-1) - m.frame
                else if m.jump = m.const.ACT_JUMP_RIGHT and GetBlockType(m.blockX + 1, m.blockY) = m.const.MAP_INV_WALL
                    m.jump = m.const.ACT_JUMP_LEFT
                    m.frame = (actionArray.Count()-1) - m.frame
                end if
            end if
            m.offsetY -= m.frameOffsetY()
            if m.offsetY < 0
                m.blockY--
                m.offsetY += m.const.BLOCK_HEIGHT
            else if m.offsetY >= m.const.BLOCK_HEIGHT
                m.blockY++
                m.offsetY -= m.const.BLOCK_HEIGHT
            end if
        end if
    else if m.state = m.STATE_FALL 'Update fall
        curFloor = GetFloorOffset(m.blockX, m.blockY)
        if IsFloorDown(curBlock) and m.offsetY >= curFloor and m.offsetY-curFloor <= 4
            m.frame = 0
            m.state = m.STATE_MOVE
            m.offsetY = curFloor
            fallHeight = ((m.blockY * m.const.BLOCK_HEIGHT) + m.offsetY) - m.startY
            if fallHeight  >= m.const.BLOCK_HEIGHT
                m.alive = m.immortal
                if Right(m.charAction,4) = "Left"
                    m.charAction = "landLeft"
                else
                    m.charAction = "landRight"
                end if
                print "landed dead "; fallHeight
            else
                print "landed safe "; fallHeight
            end if
        else
            m.offsetX = -8
            m.offsetY += 2
            if m.offsetY >= m.const.BLOCK_HEIGHT
                m.blockY++
                m.offsetY -= m.const.BLOCK_HEIGHT
                if m.offsetY < 2 then m.offsetY = 0
            end if
        end if
    else if GetBlockType(m.blockX, m.blockY) = m.const.MAP_CONV_BELT
        if m.offsetY = GetFloorOffset(m.blockX, m.blockY)
            direction = GetConveyorDirection(m.blockX, m.blockY)
            if direction = "R"
                m.offsetX += 2
                if m.offsetX >= m.const.BLOCK_WIDTH / 4
                    m.blockX++
                    m.offsetX -= m.const.BLOCK_WIDTH
                end if
            else if direction = "L"
                m.offsetX -= 2
                if m.blockX > 0 and m.offsetX <= -(m.const.BLOCK_WIDTH / 2)
                    m.blockX--
                    m.offsetX += m.const.BLOCK_WIDTH
                end if
            end if
        end if
    end if
    if action <> m.const.ACT_NONE
        print "position: "; m.blockX; ","; m.blockY; " - offsetX="; m.offsetX; " - offsetY="; m.offsetY; " - Floor=";GetFloorOffset(m.blockX, m.blockY)
    else if m.state = m.STATE_JUMP
        print "jump:"; m.frame
    end if
End Sub

Sub start_fall_jumpman()
    print "start fall"
    m.startY = ((m.blockY * m.const.BLOCK_HEIGHT) + m.offsetY)
    m.state = m.STATE_FALL
End Sub

Function frame_offset_x() as integer
    if Left(m.charAction, 3) = "hit"
        if m.hammer.up then ps = "Up" else ps = "Dn"
    else
        ps = ""
    end if
    actionArray = m.anims.jumpman.sequence.Lookup(m.charAction + ps)
    return actionArray[m.frame].x
End Function

Function frame_offset_y() as integer
    if Left(m.charAction, 3) = "hit"
        if m.hammer.up then ps = "Up" else ps = "Dn"
    else
        ps = ""
    end if
    actionArray = m.anims.jumpman.sequence.Lookup(m.charAction + ps)
    return actionArray[m.frame].y
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
