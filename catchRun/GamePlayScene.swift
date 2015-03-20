//
//  GameScene.swift
//  catchRun
//
//  Created by Ji Pei on 12/16/14.
//  Copyright (c) 2014 LUSS. All rights reserved.
//

import SpriteKit

//gameplayerscene need to implement MultiplayerProtocol.
// it contains 5 method. moveplayeratindex api helps one of the player in the game to get the information of another player's move information. Such as P1 get the info of P2 moving to right.
class GamePlayScene: SKScene, GADInterstitialDelegate, MultiplayerProtocol {
    var tiledMap:JSTileMap?
    var player = PlayerNode(playerTextureName: "player")
    var playerWalkingFrames = NSArray()
    
    // this is used to transfer moving data
    var networkEngine: Multiplayer!
    
    //------network layer var
    var currentIndex: Int! // which player
    var players: Array<PlayerNode>!
    //-----------------
    var capacityOfPlayerInGame: Int! = 2
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        tiledMap = JSTileMap(named:"map.tmx")
       
        let map = tiledMap!
        self.anchorPoint = CGPoint(x: 0, y: 0)
        map.xScale = 1.9
        map.yScale = 1.5
        map.position = CGPoint(x: 0, y: 0)
        self.addChild(map)
        var wall = map.layerNamed("Meta")
        
        // example for how to use tiledMap
        // point is to tell you which tile is it in
        // for example this tile is in (2, 11) which is a wall
        var point = tileCoordForPosition(CGPoint(x: 90.0, y: 70))
        // tileGid will give you a reference of this position
        var tileGid = wall.tileGidAt(CGPoint(x: 90, y: 70))
        // use this tilegid you can find the dictionary, if there is no dict it will crash so add some warper
        var properties:NSDictionary = map.propertiesForGid(tileGid) as NSDictionary
        // this is the actuall string
        // if it is the wall dict, there is a key called Collidable and it will return "true"
        // if it is the trap dict, there is a key called trapCollidable and it will return true
        var collision: NSString = properties.valueForKey("Collidable") as NSString
        
        
        //-----------------------------------------------------------
        
        // to use the network engine, we need to initialize the players here
        // we can first set two player into players instance. And we can define
        // two enums for player type: police and thief
        
        //-----------------------------------------------------------
        // For test purpose, we initialize two player in the screen
        players = Array<PlayerNode>()
        var player1: PlayerNode! = PlayerNode(playerTextureName: "player")
        var player2: PlayerNode! = PlayerNode(playerTextureName: "player")
        
        player1.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        player2.position = CGPoint(x: self.size.width * 0.2, y: self.size.height * 0.2)
        // add into players
        players.append(player1)
        players.append(player2)
        currentIndex = -1
        
        //-------------------------------------------------------------

        if collision.isEqualToString("True"){
            // collide should prevent user go in to the wall
            println("collide!!!!!!!! at \(point)")
        }
        
        //Create player
        player.position = CGPoint(x: self.size.width * 0.5 - 50, y: self.size.height * 0.5 - 50)
        self.addChild(player)
        //virtual joystick
        let joyStick = JoyStick(defatultArrowImage: "arrow", activeArrowImage: "arrowdown", target: player)
        joyStick.xScale = 0.5
        joyStick.yScale = 0.5
        joyStick.alpha = 0.5
        joyStick.position = CGPoint(x: 100, y: 100)
        self.addChild(joyStick)
        //player moving by swipe
        /*var swipeGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        self.view?.addGestureRecognizer(swipeGesture)
        
        var swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        swipeLeftGesture.direction = UISwipeGestureRecognizerDirection.Left
        self.view?.addGestureRecognizer(swipeLeftGesture)
        
        var swipeUpGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        swipeUpGesture.direction = UISwipeGestureRecognizerDirection.Up
        self.view?.addGestureRecognizer(swipeUpGesture)
        
        var swipeDownGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        swipeDownGesture.direction = UISwipeGestureRecognizerDirection.Down
        self.view?.addGestureRecognizer(swipeDownGesture)
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        tapGesture.numberOfTapsRequired = 2
        self.view?.addGestureRecognizer(tapGesture)*/
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
//        var fullAd = GADInterstitial()
//        fullAd.adUnitID = "ca-app-pub-6314301496407347/6061124916"
//        fullAd.delegate = self
//        fullAd.loadRequest(request2)
//        
//        fullAd.presentFromRootViewController(self)
        if (currentIndex == -1){
            return
        }
       
        
        
    }
    
    
    // once we swipe
    // we need to send the move information to other players
    func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
        var direction = gesture.direction
        switch (direction){
        case UISwipeGestureRecognizerDirection.Left:
            players[currentIndex].moving("LEFT")
            networkEngine.sendMove("LEFT")
            // player.moving("LEFT")
            break
        case UISwipeGestureRecognizerDirection.Right:
            players[currentIndex].moving("RIGHT")
            networkEngine.sendMove("RIGHT")
            //player.moving("RIGHT")
            break
        case UISwipeGestureRecognizerDirection.Up:
            players[currentIndex].moving("UP")
            networkEngine.sendMove("UP")
            //player.moving("UP")
            break
        case UISwipeGestureRecognizerDirection.Down:
            players[currentIndex].moving("DOWN")
            networkEngine.sendMove("DOWN")
            //player.moving("DOWN")
            break
        default:
            break;
        }
    }
    
    func handleTapGesture(gesture:UITapGestureRecognizer) {
        player.stopMoving()
    }
    
    override func update(currentTime: CFTimeInterval) {
        // we need to check if collide here
        if isCollideWithTrap(player.position) || isCollideWithWall(player.position) {
            if  isCollideWithWall(player.position) {
                print("collide with wall \n")
            }else{
                print("collide with trap \n")
            }
        }else{
            print("not collide \n")
        }
    }
    
    // function to change coordinates to tile coordinates
    // tile : (0, 0) ........ (16, 0)
    //          .    ........   .
    //          .    ........   .
    //        (0, 16) ......  (16, 16)
    //while spritekit origin is bottom left so we need to reverse y
    func tileCoordForPosition(position: CGPoint) -> CGPoint{
        var x = Int((position.x / tiledMap!.tileSize.width))
        var y = Int((tiledMap!.mapSize.height * tiledMap!.tileSize.height - position.y) / tiledMap!.tileSize.height)
        return CGPoint(x: x, y: y)
    }
    
  //conform multiplayer protocol
    func matchEnded(){
        
    }
    
    // set current player index, such as P1
    func setCurrentPlayerIndex(index: Int){
        currentIndex = index
    }
    
    
    // move p1 or p2, to which direction
    func movePlayerAtIndex(index: Int, position: Point){
       // var player: PlayerNode! = players[index] as PlayerNode
        players[index].moving(direction)
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
