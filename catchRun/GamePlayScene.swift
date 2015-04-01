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
    var physicEngine:CollisionCheck?
    
    // network layer var
    var isSinglePlayer = true
    var networkEngine: Multiplayer!
    var currentIndex: Int! // which player
    var localPlayer = PlayerNode(playerTextureName: "player")
    var capacityOfPlayerInGame: Int! = 2
    var remote_players = Dictionary<String, PlayerNode>()
    
    override func didMoveToView(view: SKView) {
        // Create game map
        tiledMap = JSTileMap(named:"map.tmx")
        let map = tiledMap!
        self.anchorPoint = CGPoint(x: 0, y: 0)
        map.xScale = 1.9
        map.yScale = 1.5
        map.position = CGPoint(x: 0, y: 0)
        self.addChild(map)
        
        // Create local player
        localPlayer.position = CGPoint(x: self.size.width * 0.5, y: 50)
        localPlayer.xScale = 0.8
        localPlayer.yScale = 0.8
        // need to set player role according to networking
        localPlayer.playerRole = "Ghost"
        self.addChild(localPlayer)
        
        // If Mutiplayer, Get the number of Players
        if !isSinglePlayer {
            var gameSize : Int! = GameCenterConnector.sharedInstance().getRemoteCount()
            capacityOfPlayerInGame = gameSize + 1
            NSLog("There are %d players + one local player in the game", gameSize)
            
            // Create a dictionary key is player id, object is player node and add node to screen
            var playerIds = GameCenterConnector.sharedInstance().getPlayerIds()
            for var index = 0; index < gameSize; ++index{
                var player_remote = PlayerNode(playerTextureName: "player")
                player_remote.position = CGPoint(x: self.size.width * 0.5 - 50 + CGFloat((index+1))*20, y: self.size.height - 50)
                // need to set player role according to networking
                player_remote.playerRole = "Ghostbuster"
                self.remote_players[playerIds[index]] = player_remote
                self.addChild(player_remote)
            }
        }
        
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
        view.addGestureRecognizer(swipeRight)
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeGesture:"))
        swipeLeft.direction = .Left
        view.addGestureRecognizer(swipeLeft)
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeGesture:"))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeGesture:"))
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target:self, action: Selector("handleTapGesture:"))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // Create Physic Engine
        physicEngine = CollisionCheck(tiledMap:map)
        
        //Add a button to end game
        let pauseButton = GGButton(defaultButtonImage: "pause", activeButtonImage: "pause", buttonAction:didTapOnPause)
        pauseButton.xScale = 1.0
        pauseButton.yScale = 1.0
        pauseButton.position = CGPoint(x: size.width * 0.85, y: size.height * 0.15 )
        self.addChild(pauseButton)
        
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
    
    // We need to test if the ghost is found by the ghostbuster
    // If not, check if the ghost hit any trap
    // at last, make sure no one pass the wall
    override func update(currentTime: CFTimeInterval) {
        localPlayer.previousPosition = localPlayer.position
    }
    
    override func didEvaluateActions() {
        if physicEngine!.isCollideWithTrap(localPlayer.position) || physicEngine!.isCollideWithWall(localPlayer.position) {
            if  physicEngine!.isCollideWithWall(localPlayer.position) {
                localPlayer.position = localPlayer.previousPosition!
            }else{
                // Change tile map to indicate ghost interect trap
                let map = tiledMap!
                var trap = map.layerNamed("Trap")
                trap.removeTileAtCoord(physicEngine!.tileCoordForPosition(localPlayer.position))
                var background = map.layerNamed("Background")
                background.removeTileAtCoord(physicEngine!.tileCoordForPosition(localPlayer.position))
            }
        }else{
        }
        
        if !isSinglePlayer{
            var localId = GameCenterConnector.sharedInstance().getLocalPlayerID()
            self.networkEngine!.sendMove(localPlayer.position, id: localId)
        }
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
        remote_players[id]?.position = position
    }
    
    func gameOver(leftWon: Bool){
        
    }
    
    func setPlayerAlias(playerAliases: NSArray){
        
    }
}
