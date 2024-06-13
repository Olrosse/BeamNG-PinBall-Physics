# Wreckfest like PinBall physics for BeamNG
it works by taking the difference in the velocity between the colliding vehicles and applies that as a force in the direction away from each cars bounding box centre

## BeamMP Installation
1. Download the newest version from the release page
1. Open the zip and put what's in the Client folder into your server's "Recources/Client" folder and Server files into "Recources/Server"
1. Then to activate the PinBall physics you can type /pinball enable into the in game chat and hit enter
1. A full list of commands can be found with /pinball help

### Server Chat Commands
1. /pinball help : displays List of commands  
1. /pinball enable : enables PinBall Physics, can also be used as /pinball enable true, or /pinball enable false  
1. /pinball disable : disables PinBall Physics, can also be used as /pinball disable true, or /pinball disable false  
1. /pinball toggle : toggles if the PinBall Physics is enabled or not  
1. /pinball multiplier 1 : sets the Multiplier for the forces  

## Single Player Installation
1. Download the newest version from the release page
1. Open the zip and put what's in the Client folder into the game's Mods folder,  
    By default it is in "C:\Users\"yourusername"\AppData\Local\BeamNG.drive\"gameverison"\mods",  
1. Then to activate you open the ingame console and then enter pinBallPhysicsControl.enablePinBallPhysics(),
1. To disable again you can either do pinBallPhysicsControl.disablePinBallPhysics() or pinBallPhysicsControl.enablePinBallPhysics(false)

### GE Console Commands
1. pinBallPhysicsControl.enablePinBallPhysics(true) Enables PinBall if argument is true or blank, Disables if false  
1. pinBallPhysicsControl.disablePinBallPhysics(true) Disables PinBall if argument is true or blank, Enables if false  
1. pinBallPhysicsControl.PinBallPhysics_multiplier(1) Multiplier for the forces
