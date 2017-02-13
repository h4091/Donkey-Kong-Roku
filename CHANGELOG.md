#Donkey Kong for Roku - Changelog

#####v0.12 - 12-Fev-2017 - Audio improvements and bug fixes
* Add: Support dual audio channels for sound effects #37
* Fix: Bonus timer on slower devices is not proportional to the game speed #34
* Fix: Jumping over cement trays is not counting 100 points #35
* Fix: Sometimes stepping over a rivet the jumpman will fall right away #36

#####v0.11 - 09-Fev-2017 - Bouncing Springs, Moving Ladders and Elevator platform fix
* Add: Random Obstacle: Jumping spring (Elevators board) #9
* Add: Object Animation: Moving ladders (Conveyors board) #3
* Add: Settings: Starting Lives #20
* Add: The label 1UP must be flashing during the game #33
* Fix: Jumping over elevator platform is not consistent #22
* Fix: Stick 3600X: The score numbers blink during initial scene #31
* Fix: Jumpman is falling too early when walking to the left towards an edge #32

#####v0.10 - 04-Fev-2017 - Fire Ball, Fire Fox, Cement Tray, Set Boards Order
* Add: Random Obstacle: Fireball AI (barrels, elevators, conveyors) #6
* Add: Random Obstacle: Firefox AI (rivets) #7
* Add: Random Obstacle: Cement tray #8
* Add: Settings: Select level board order (USA or Japan) #29
* Change: Updated game credits and start screens
* Fix: OK button is not working for standing jump on horizontal control mode #25
* Fix: Bonus life is not being added if the score is exactly 7000 #26
* Fix: Jumpman cannot climb down some ladders on conveyors board #18
* Fix: At the end of the climb up if go down and up again repeat the animation #16
* Fix: Fireballs are not climbing all way down on long ladders (conveyors board) #28
* Fix: Jumpman is moved out of the screen on conveyors board second floor #27

#####v0.9 - 29-Jan-2017 - Rolling and Wild Barrels, Get and Use Hammer, bug fixes
* Add: Jumpman Animation: get and use the hammer #10
* Add: Random Obstacle: Rolling barrel #4
* Add: Random Obstacle: Wild barrel #5
* Add: Jumpman animation: climb down #11
* Fix: Can't jump over elevator platform close to the bottom engine #13
* Fix: Jumpman is falling before or during remove a rivet when landing or walking on it #14
* Fix: Jumpman is not falling when walking over hole (or right edge) in rivets board #15
* Fix: Can't get one of the hammers on rivets board #21
* Change: Updated project credit screen

#####v0.8 - 04-Dec-2016 - Game Intro, Board and Level Complete scenes
* Add: Game Introduction cut scene - #1
* Add: End of level animation - #2
* Add: Board Complete scene - #19

#####v0.7 - 25-Nov-2016 - Invisible walls, Conveyor Belts, Oil Flames and Kong animations
* Add: Support for the invisible walls (jump bounces back)
* Add: Jumpman dies at 4283 millisecons after bonus countdown is zero
* Add: Oil flames animation on conveyor board
* Add: Kong animations: shakeArms, rollOrangeBarrel, rollBlueBarrel
* Add: Conveyor animations
* Add: Conveyor belt affects Jumpman and Kong position
* Add: Some conveyors changes direction based on Kong's position
* Fix: Pause game is not pausing background sound effect

#####v0.6 - 22-Nov-2016 - Sound effects, High Scores and Bonus counter
* Add: Sound effects: start board, background, walk, jump, death, get item, menu
* Add: Show high scores screen
* Add: Register high score screen
* Add: Bonus: countdown and add to score when board is complete
* Fix: Jumpman do not die with long jumps

#####v0.5 - 15-Nov-2016 - Jumpman Death, Use Elevator, Jump Rivets
* Add: Remove rivets by jumping over it
* Add: Jumpman animation: death
* Add: Stay over Elevator platforms
* Add: Ladders objects on Conveyor board
* Fix: Jumpman is falling too early when facing left
* Fix: Rivets map had some wrong blocks on the right side

#####v0.4 - 10-Nov-2016 - Lady, Progress Screen, Object Points, Fall and Elevator
* Add: Lady animation
* Add: Debug grid (press B in vertical mode or REW in horizontal)
* Add: Show Points numbers over the board
* Add: Fill holes with Rivets images
+ Add: Rivets removal by stepping on it
* Add: Board completion (basic verification and show heart for non rivets boards)
* Add: Show progress (height) screen before each board
* Add: Jumpman animation: fall
* Add: Elevator animation
* Fix: Horizontal control is not working properly
* Fix: Jump up over a ladder makes jumpman fall to lower level

#####v0.3 - 30-Oct-2016 - Lives, Game Over, Pause, Jumpman climb and jump
* Add: Paint jumpman lives
* Add: Game Over message
* Add: Game Paused message
* Add: Jumpman Animation: jump left and right
* Add: Improved control of Jumpman (walk, climb, jump)
* Add: Startup lives
* Add: Get bonus life when get more than 7000 points
* Fix: Several small issues on board maps

#####v0.2 - 15-Oct-2016 - Board maps done, Jumpman Basic control, Paint Chars, Objects and Score
* Add: Paint chars on start position
* Add: Paint objects on position
* Add: Paint Score
* Add: Paint Level indicator
* Add: Paint Bonus
* Add: Jumpman Animations (run left, run right, climb ladder)
* Add: Basic control of Jumpman (still preliminar)
* Add: Finish Arcade board maps definitions on json
* Add: Collect lady objects and get points
* Change: Game start screen now flashes like original Arcade
* Fix: Sprites needs to be resized 2X
* Fix: Control help images are wrong

#####v0.1 - 09-Oct-2016 - Menu, Credits, Graphics and Level Navigation
* Add: Splash screen and icons
* Add: Game Menu
* Add: Credits screen
* Add: Sprites and boards of the original Arcade version
* Add: Game Start screen
* Add: Level navigation
* Add: First draft of Barrels board map
