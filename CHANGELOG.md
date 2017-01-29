#Donkey Kong for Roku - Changelog

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
