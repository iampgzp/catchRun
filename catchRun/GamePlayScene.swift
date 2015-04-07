//
//  GameScene.swift
//  catchRun
//
//  Created by Ji Pei on 12/16/14.
//  Copyright (c) 2014 LUSS. All rights reserved.
//
// it contains 5 method. moveplayeratindex api helps one of the player in the game to get the information of another player's move information. Such as P1 get the info of P2's current position

import SpriteKit
import GameKit

class GamePlayScene: SKScene, GADInterstitialDelegate, MultiplayerProtocol {
    // the map we gonna use for this game
    var tiledMap:JSTileMap?
    var timer:NSTimer!
    var countDown:SKLabelNode?
    var preGameTimer:NSTimer!
    var preGameCountDown:SKLabelNode?
    var isPreGame = true
    var physicEngine:CollisionCheck?
    
    
    // network layer var
    var isSinglePlayer = true
    var networkEngine: Multiplayer!
    var currentIndex: Int! // which player
    var localPlayer : PlayerNode!
    var capacityOfPlayerInGame: Int! = 2
    var remote_players = Dictionary<String, PlayerNode>()
    var ghostkey: String!
    
    override func didMoveToView(view: SKView) {
        // Create game map
        tiledMap = JSTileMap(named:"map.tmx")
        let map = tiledMap!
        self.anchorPoint = CGPoint(x: 0, y: 0)
        map.xScale = 1.9
        map.yScale = 1.5
        map.position = CGPoint(x: 0, y: 0)
        self.addChild(map)
        
        // Create Physic Engine
        physicEngine = CollisionCheck(tiledMap:map)
        
        // remove all background trap for tmx
        var background = map.layerNamed("Background")
        background.removeTileAtCoord(CGPoint(x: 8, y: 11))
        background.removeTileAtCoord(CGPoint(x: 8, y: 7))
        background.removeTileAtCoord(CGPoint(x: 8, y: 3))
        background.removeTileAtCoord(CGPoint(x: 5, y: 1))
        background.removeTileAtCoord(CGPoint(x: 11, y: 1))
        background.removeTileAtCoord(CGPoint(x: 5, y: 7))
        background.removeTileAtCoord(CGPoint(x: 11, y: 7))
        background.removeTileAtCoord(CGPoint(x: 4, y: 4))
        background.removeTileAtCoord(CGPoint(x: 1, y: 4))
        background.removeTileAtCoord(CGPoint(x: 13, y: 4))
        background.removeTileAtCoord(CGPoint(x: 15, y: 5))
        background.removeTileAtCoord(CGPoint(x: 1, y: 8))
        background.removeTileAtCoord(CGPoint(x: 4, y: 10))
        background.removeTileAtCoord(CGPoint(x: 13, y: 9))
        background.removeTileAtCoord(CGPoint(x: 1, y: 12))
        background.removeTileAtCoord(CGPoint(x: 12, y: 12))
        
        if isSinglePlayer {
            // single player Create local player as ghost
            localPlayer = PlayerNode(playerTextureName: "ghost")
            localPlayer.xScale = 1.0
            localPlayer.yScale = 1.0
            localPlayer.position = CGPoint(x: self.size.width * 0.5, y: 50)
            localPlayer.playerRole = "Ghost"
            self.addChild(localPlayer)
            
            
            // create a dumb ghost for test
            var ghost = PlayerNode(playerTextureName: "player")
            ghost.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.70)
            ghost.playerRole = "Ghostbuster"
            self.addChild(ghost)
        }else{
            // multi player get how man players
            var gameSize : Int! = GameCenterConnector.sharedInstance().getRemoteCount()
            capacityOfPlayerInGame = gameSize + 1
            NSLog("There are \(gameSize) players + one local player in the game")
            
            // Create a dictionary key is player id, object is player node and add node to screen
            var playerIds = GameCenterConnector.sharedInstance().getPlayerIds()
            var sortPlayerIds = playerIds.sorted(<)
            
            // find the ghost and set position
            if  ghostkey == GKLocalPlayer.localPlayer().playerID {
                // local player is ghost
                localPlayer = PlayerNode(playerTextureName: "ghost")
                localPlayer.xScale = 1.0
                localPlayer.yScale = 1.0
                localPlayer.position = CGPoint(x: self.size.width * 0.5, y: 100)
                localPlayer.playerRole = "Ghost"
                self.addChild(localPlayer)
                NSLog("local player is ghost")
        
                // set remote players as ghostbusters
                for var index = 0; index < gameSize; ++index{
                    var player_remote = PlayerNode(playerTextureName: "player")
                    player_remote.position = CGPoint(x: self.size.width * 0.5 - 50 + CGFloat((index+1))*20, y: self.size.height * 0.70)
                    player_remote.playerRole = "Ghostbuster"
                    self.remote_players[sortPlayerIds[index]] = player_remote
                    self.addChild(player_remote)
                }
            }else{
                // remote player is ghost find who is ghost exactly
                for var index = 0; index < gameSize; ++index{
                    if ghostkey == sortPlayerIds[index] {
                        // set ghost
                        var player_remote = PlayerNode(playerTextureName: "ghost")
                        player_remote.xScale = 1.0
                        player_remote.yScale = 1.0
                        player_remote.position = CGPoint(x: self.size.width * 0.5, y: 100)
                        player_remote.playerRole = "Ghost"
                        self.remote_players[sortPlayerIds[index]] = player_remote
                        self.addChild(player_remote)
                        //remove ghost from sort player id in order for consistent in the position
                        sortPlayerIds.removeAtIndex(index)
                        break
                    }
                }
                
                NSLog("remote player is ghost")

                
                // add local player and re-sort
                sortPlayerIds.insert(GKLocalPlayer.localPlayer().playerID, atIndex: 0)
                sortPlayerIds = sortPlayerIds.sorted(<)
                
                // set local player and other player
                for var index = 0; index < gameSize; ++index{
                    if  sortPlayerIds[index] == GKLocalPlayer.localPlayer().playerID {
                        localPlayer = PlayerNode(playerTextureName: "player")
                        localPlayer.playerRole = "Ghostbuster"
                        localPlayer.position = CGPoint(x: self.size.width * 0.5 - 50 + CGFloat((index+1))*20, y: self.size.height * 0.70)
                        self.addChild(localPlayer)
                    }else{
                        var player_remote = PlayerNode(playerTextureName: "player")
                        player_remote.position = CGPoint(x: self.size.width * 0.5 - 50 + CGFloat((index+1))*20, y: self.size.height * 0.70)
                        player_remote.playerRole = "Ghostbuster"
                        self.remote_players[sortPlayerIds[index]] = player_remote
                        self.addChild(player_remote)
                    }
                }
            }
        }
        
        
        //set pre game timer
        preGameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updatePreGameTimer"), userInfo: nil, repeats: true)
        //Add pre game count down label in the midlle
        preGameCountDown = SKLabelNode(text:"3")
        preGameCountDown!.xScale = 5.0
        preGameCountDown!.yScale = 5.0
        preGameCountDown!.position = CGPoint(x: size.width * 0.5, y: size.height * 0.4)
        addChild(preGameCountDown!)
        
    }
    
    func updatePreGameTimer(){
        let nf = NSNumberFormatter()
        nf.numberStyle = .DecimalStyle
        let number = nf.numberFromString(preGameCountDown!.text)
        let number2 = number!.integerValue - 1
        if  number2 <= 0 {
            // game begin
            // Create JoyStick Controller
            let joyStick = JoyStick(defatultArrowImage: "arrow", activeArrowImage: "arrowdown", target: localPlayer)
            joyStick.xScale = 0.5
            joyStick.yScale = 0.5
            joyStick.alpha = 0.5
            joyStick.position = CGPoint(x: 100, y: 100)
            self.addChild(joyStick)
            
            // add gesture recognizer controller
            let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeGesture:"))
            swipeRight.direction = .Right
            self.view!.addGestureRecognizer(swipeRight)
            let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeGesture:"))
            swipeLeft.direction = .Left
            self.view!.addGestureRecognizer(swipeLeft)
            let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeGesture:"))
            swipeUp.direction = .Up
            self.view!.addGestureRecognizer(swipeUp)
            let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeGesture:"))
            swipeDown.direction = .Down
            self.view!.addGestureRecognizer(swipeDown)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target:self, action: Selector("handleTapGesture:"))
            tap.cancelsTouchesInView = false
            self.view!.addGestureRecognizer(tap)
            
            
            //Add a button to end game
            let pauseButton = GGButton(defaultButtonImage: "pause", activeButtonImage: "pause", buttonAction:didTapOnPause)
            pauseButton.xScale = 1.0
            pauseButton.yScale = 1.0
            pauseButton.position = CGPoint(x: size.width * 0.85, y: size.height * 0.15 )
            self.addChild(pauseButton)

            
            // set up real timer and label
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
            // Add A Label to count down
            countDown = SKLabelNode(text:"60")
            countDown!.fontName = "Helvetica Neue"
            countDown!.xScale = 1.0
            countDown!.yScale = 1.0
            countDown!.position = CGPoint(x: size.width * 0.98, y: size.height * 0.83)
            addChild(countDown!)
            
            // remove old timer
            preGameCountDown!.removeFromParent()
            preGameTimer!.invalidate()
            
            isPreGame = false
        }
        preGameCountDown!.text = "\(number2)"
    }
    
    func updateTimer(){
        let nf = NSNumberFormatter()
        nf.numberStyle = .DecimalStyle
        let number = nf.numberFromString(countDown!.text)
        let number2 = number!.integerValue - 1
        if  number2 <= 0 {
            gameOver(false)
        }
        countDown!.text = "\(number2)"
    }
    
    func didTapOnPause() {
        let pauseGameAction = SKAction.runBlock{
            let reval = SKTransition.flipHorizontalWithDuration(0.5)
            self.view?.presentScene( GameScene(size: self.size), transition: reval)
        }
        //gameStarted = True
        self.runAction(pauseGameAction)
    }
    
    //LOCAL PLAYER MOVE
    func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
        var direction = gesture.direction
        switch (direction){
        case UISwipeGestureRecognizerDirection.Left:
            localPlayer.moving("LEFT")
            break
        case UISwipeGestureRecognizerDirection.Right:
            localPlayer.moving("RIGHT")
            break
        case UISwipeGestureRecognizerDirection.Up:
            localPlayer.moving("UP")
            break
        case UISwipeGestureRecognizerDirection.Down:
            localPlayer.moving("DOWN")
            break
        default:
            break;
        }
    }
    
    func handleTapGesture(gesture:UITapGestureRecognizer) {
        localPlayer.stopMoving()
    }
    
    // record localplayer position in case it hit the wall
    override func update(currentTime: CFTimeInterval) {
        localPlayer.previousPosition = localPlayer.position
    }
    
    // We need to test if the ghost is found by the ghostbuster
    // If not, check if the ghost hit any trap
    // at last, make sure local player doesn't pass the wall
    override func didEvaluateActions() {
        // get the ghost node and check if caught
        var ghost:PlayerNode?
        if  localPlayer.playerRole == "Ghost"{
            ghost = localPlayer

            // check if caught
            for (key, remotePlayer) in remote_players{
                if physicEngine!.isCollideWithGhost(remotePlayer.position, ghostPosition: ghost!.position){
                    gameOver(true)
                }
            }
            
            // check dumb ghostbuster
            if physicEngine!.isCollideWithGhost(CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.70), ghostPosition: ghost!.position){
                gameOver(true)
            }
            
        }else{
            var ghostKey:NSString?
            for (key, remotePlayer) in remote_players{
                if remotePlayer.playerRole == "Ghost" {
                    ghost = remotePlayer
                    ghostKey = key
                }
            }
            
            // check if caught by local player
            if physicEngine!.isCollideWithGhost(localPlayer.position, ghostPosition: ghost!.position){
                gameOver(true)
            }
            
            // check if caught by other remote players
            for (key, remotePlayer) in remote_players{
                if  key != ghostKey {
                    if physicEngine!.isCollideWithGhost(remotePlayer.position, ghostPosition: ghost!.position){
                        gameOver(true)
                    }
                }
            }
        }
        
        // check if ghost touch trp
        if  physicEngine!.isCollideWithTrap(ghost!.position) {
            // Change tile map to indicate ghost interect trap
            let map = tiledMap!
            var background = map.layerNamed("Background")
            background.setTileGid(73, atCoord: physicEngine!.tileCoordForPosition(ghost!.position), mapInfo: map)
            
            let dict = ["x" : physicEngine!.tileCoordForPosition(ghost!.position).x, "y": physicEngine!.tileCoordForPosition(ghost!.position).y]
            var trapTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("setTrapBackToNormal:"), userInfo: dict, repeats: false)
        }
        
        // check if local player hit the wall
        if physicEngine!.isCollideWithWall(localPlayer.position) {
            localPlayer.position = localPlayer.previousPosition!
        }
        
        if !isSinglePlayer{
            var localId = GameCenterConnector.sharedInstance().getLocalPlayerID()
            self.networkEngine!.sendMove(localPlayer.position, id: localId)
        }

    }
    
    func setTrapBackToNormal(timer: NSTimer){
        let map = tiledMap!
        var background = map.layerNamed("Background")
        let x = timer.userInfo!["x"] as NSNumber
        let y = timer.userInfo!["y"] as NSNumber
        let coord = CGPoint(x: CGFloat(x.floatValue), y: CGFloat(y.floatValue))
        background.setTileGid(3, atCoord: coord, mapInfo: map)
    }
    
    //MARK Multiplayer Protocol
    func matchEnded(){
        
    }
    
    // set current player index, such as P1
    func setCurrentPlayerIndex(index: Int){
        currentIndex = index
    }
    
    // THE INDEX IS THE PLAYERID
    func movePlayerAtIndex(position: CGPoint, id: String){
        NSLog("all remote playerid \(remote_players.keys)")
        remote_players[id]?.position = position
    }
    
    func gameOver(ghostBusterWon: Bool){
        let endGameAction = SKAction.runBlock{
            let reval = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size)
            gameOverScene.isGhostWon = !ghostBusterWon
            self.view?.presentScene( gameOverScene, transition: reval)
        }
        //gameStarted = True
        self.runAction(endGameAction)
    }
    
    func setPlayerAlias(playerAliases: NSArray){
        
    }
    
    //called in gamescen page
    //before navigating to play scene
    func setGhostKey(ghostkey: String){
        self.ghostkey = ghostkey
    }
}
