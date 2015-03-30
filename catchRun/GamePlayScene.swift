//
//  GameScene.swift
//  catchRun
//
//  Created by Ji Pei on 12/16/14.
//  Copyright (c) 2014 LUSS. All rights reserved.
//

import SpriteKit
import GameKit
//gameplayerscene need to implement MultiplayerProtocol.
// it contains 5 method. moveplayeratindex api helps one of the player in the game to get the information of another player's move information. Such as P1 get the info of P2's current position



class GamePlayScene: SKScene, GADInterstitialDelegate, MultiplayerProtocol {
    var tiledMap:JSTileMap?
    var player = PlayerNode(playerTextureName: "player")
    var playerWalkingFrames = NSArray()
    var isSinglePlayer = true
    
    // this is used to transfer moving data
    //var networkEngineDelegate: playerSceneDelegate?
    var networkEngine: Multiplayer!
    //------network layer var
    var currentIndex: Int! // which player

    //-----------------
    var capacityOfPlayerInGame: Int! = 2
    var remote_players = Dictionary<String, PlayerNode>()

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        tiledMap = JSTileMap(named:"map.tmx")
        let map = tiledMap!
        self.anchorPoint = CGPoint(x: 0, y: 0)
        map.xScale = 1.9
        map.yScale = 1.5
        map.position = CGPoint(x: 0, y: 0)
        self.addChild(map)
        

        // GET SIZE OF REMOTE PLAYER, BUILD ARRAY TO STORE
        
        var gameSize : Int! = GameCenterConnector.sharedInstance().getRemoteCount()
        NSLog("get size %d", gameSize)
        var playerIds = GameCenterConnector.sharedInstance().getPlayerIds()
        for var index = 0; index < gameSize; ++index{
            var player_remote = PlayerNode(playerTextureName: "player")
            player_remote.position = CGPoint(x: self.size.width * 0.5 - 50 + CGFloat((index+1))*20, y: self.size.height * 0.5 - 50)
            self.remote_players[playerIds[index]] = player_remote
            self.addChild(player_remote)
        }
//        currentIndex = -1
        
        //Create local player
        player.position = CGPoint(x: self.size.width * 0.5 - 50, y: self.size.height * 0.5 - 50)
        player.xScale = 0.8
        player.yScale = 0.8
        self.addChild(player)
        //virtual joystick
        let joyStick = JoyStick(defatultArrowImage: "arrow", activeArrowImage: "arrowdown", target: player)
        joyStick.xScale = 0.5
        joyStick.yScale = 0.5
        joyStick.alpha = 0.5
        joyStick.position = CGPoint(x: 100, y: 100)
        self.addChild(joyStick)
        
        //Add a button to end game
        let pauseButton = GGButton(defaultButtonImage: "pause", activeButtonImage: "pause", buttonAction:didTapOnPause)
        pauseButton.xScale = 1.0
        pauseButton.yScale = 1.0
        pauseButton.position = CGPoint(x: size.width * 0.85, y: size.height * 0.15 )
        self.addChild(pauseButton)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//        if (currentIndex == -1){
//            return
//        }
    }
    
    func didTapOnPause() {
        let pauseGameAction = SKAction.runBlock{
            let reval = SKTransition.flipHorizontalWithDuration(0.5)
            self.view?.presentScene( GameScene(size: self.size), transition: reval)
        }
        //gameStarted = True
        self.runAction(pauseGameAction)
    }
    
//    //LOCAL PLAYER MOVE
//    func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
//        var direction = gesture.direction
//        var localId = GameCenterConnector.sharedInstance().getLocalPlayerID()
//        NSLog("swipe for playerid %s", localId)
//        switch (direction){
//        case UISwipeGestureRecognizerDirection.Left:
//           
//            //var player: PlayerNode! = players[currentIndex]
//            player.moving("LEFT")
//            networkEngine.sendMove(player.position, id: localId)
//            break
//        case UISwipeGestureRecognizerDirection.Right:
//            
//            //var player: PlayerNode! = players[currentIndex]
//            player.moving("RIGHT")
//            networkEngine.sendMove(player.position, id: localId)
//            break
//        case UISwipeGestureRecognizerDirection.Up:
//            
//            //var player: PlayerNode! = players[currentIndex]
//            player.moving("UP")
//            networkEngine.sendMove(player.position, id: localId)
//            break
//        case UISwipeGestureRecognizerDirection.Down:
//            
//            //var player: PlayerNode! = players[currentIndex]
//            player.moving("DOWN")
//            networkEngine.sendMove(player.position, id: localId)
//            break
//        default:
//            break;
//        }
//    }
    
    
    func handleTapGesture(gesture:UITapGestureRecognizer) {
        player.stopMoving()
    }
    
    override func update(currentTime: CFTimeInterval) {
        var localId = GameCenterConnector.sharedInstance().getLocalPlayerID()
        if isCollideWithTrap(player.position) || isCollideWithWall(player.position) {
            if  isCollideWithWall(player.position) {
             //   print("collide with wall \n")
                player.position = player.previousPosition!
            }else{
             //   print("collide with trap \n")
                
                let map = tiledMap!
                var trap = map.layerNamed("Trap")
                
                
                trap.removeTileAtCoord(tileCoordForPosition(player.position))
                var background = map.layerNamed("Background")
                
                
                background.removeTileAtCoord(tileCoordForPosition(player.position))
                
            }
        }else{
          //  print("not collide \n")
        }

        if !isSinglePlayer{
            self.networkEngine!.sendMove(player.position, id: localId)
        }

    }
    
    // function to change coordinates to tile coordinates
    // tile : (0, 0) ........ (16, 0)
    //          .    ........   .
    //          .    ........   .
    //        (0, 16) ......  (16, 16)
    //while spritekit origin is bottom left so we need to reverse y
    func tileCoordForPosition(position: CGPoint) -> CGPoint{
        var x = Int((position.x / (tiledMap!.tileSize.width*1.9)))
        var y = Int((tiledMap!.mapSize.height * tiledMap!.tileSize.height*1.5 - position.y) / (tiledMap!.tileSize.height*1.5))
        return CGPoint(x: x, y: y)
    }
    
    //conform multiplayer protocol
    func matchEnded(){
        
    }
    
    // set current player index, such as P1
    func setCurrentPlayerIndex(index: Int){
        currentIndex = index
    }
    
    // THE INDEX IS THE PLAYERID
    func movePlayerAtIndex(position: CGPoint, id: String){
       // var player: PlayerNode! = players[index] as PlayerNode
       
        //var remote_p : PlayerNode! = remote_players[index]
        
        
        remote_players[id]?.position = position
        
        
//        for key in remote_players.keys {
//            var p = remote_players[key] as PlayerNode!
//            p.position = position
//        }
        //remote_p.position = position
    }
    
    // we can check game over by only one side
    // for example: P1 wins, we only check P1. then send game over info to P2
    func gameOver(leftWon: Bool){
        
    }
    
    func setPlayerAlias(playerAliases: NSArray){
        
    }
    
    func isCollideWithWall(position:CGPoint) -> Bool{
        // wall's layer name is Meta
        let map = tiledMap!
        var wall = map.layerNamed("Meta")
        
        // divide by the factor because of the scaling of the map
        var adjustPosition = CGPointMake(position.x/1.9, position.y/1.5)
        
        // get the point for record the point means which tell it is from top left
        var point = tileCoordForPosition(adjustPosition)
        
        // tileGid will give you a reference of this position
        var tileGid = wall.tileGidAt(adjustPosition)
        if  tileGid != 0{
            // check collide with wall
            var properties:NSDictionary = map.propertiesForGid(tileGid) as NSDictionary
            // if it is the wall dict, there is a key called Collidable and it will return "true"
            // if it is the trap dict, there is a key called trapCollidable and it will return true
            var collision: NSString = properties.valueForKey("Collidable") as NSString
            if collision == "True" {
                return  true
            }else{
                return  false
            }
        }else{
            return  false
        }
    }
    
    func isCollideWithTrap(position:CGPoint) -> Bool{
        // wall's layer name is Meta
        let map = tiledMap!
        var trap = map.layerNamed("Trap")
        
        // divide by the factor because of the scaling of the map
        var adjustPosition = CGPointMake(position.x/1.9, position.y/1.5)
        
        // get the point for record the point means which tell it is from top left
        var point = tileCoordForPosition(adjustPosition)
        
        // tileGid will give you a reference of this position
        var tileGid = trap.tileGidAt(adjustPosition)
        if  tileGid != 0{
            // check collide with wall
            var properties:NSDictionary = map.propertiesForGid(tileGid) as NSDictionary
            // if it is the trap dict, there is a key called trapCollidable and it will return true
            var collision: NSString = properties.valueForKey("trapCollidable") as NSString
            if collision == "true" {
                return  true
            }else{
                return  false
            }
        }else{
            return  false
        }
    }
}
