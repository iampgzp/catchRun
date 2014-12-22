//
//  GameScene.swift
//  catchRun
//
//  Created by Ji Pei on 12/16/14.
//  Copyright (c) 2014 LUSS. All rights reserved.
//

import SpriteKit

class GamePlayScene: SKScene, GADInterstitialDelegate {
    var tiledMap:JSTileMap?
    var player = PlayerNode()
    var playerWalkingFrames = NSArray()
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        tiledMap = JSTileMap(named:"map.tmx")
       
        let map = tiledMap!
        self.anchorPoint = CGPoint(x: 0, y: 0)
        map.position = CGPoint(x: 240, y: 150)
        self.addChild(map)
        var wall = map.layerNamed("Meta")
        
        
        // example for how to use tiledMap
        // point is to tell you which tile is it in
        // for example this tile is in (2, 11) which is a wall
        var point = tileCoordForPosition(CGPoint(x: 90.0, y: 70))
        // tileGid will give you a reference of this position
        var tileGid = wall.tileGidAt(CGPoint(x: 90.0, y: 70.0))
        // use this tilegid you can find the dictionary, if there is no dict it will crash so add some warper
        var properties:NSDictionary = map.propertiesForGid(tileGid) as NSDictionary
        // this is the actuall string
        // if it is the wall dict, there is a key called Collidable and it will return "true"
        // if it is the trap dict, there is a key called trapCollidable and it will return true
        var collision: NSString = properties.valueForKey("Collidable") as NSString
        
        if collision.isEqualToString("True"){
            // collide should prevent user go in to the wall
            println("collide!!!!!!!! at \(point)")
        }
        
        //Create player
        playerWalkingFrames = player.creatWalkingFrames()
        player = PlayerNode(texture: playerWalkingFrames[0] as SKTexture)
        player.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        player.xScale = 0.2
        player.yScale = 0.2
        self.addChild(player)
        
        //player moving by swipe
        var swipeGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
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
        self.view?.addGestureRecognizer(tapGesture)
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
//        var fullAd = GADInterstitial()
//        fullAd.adUnitID = "ca-app-pub-6314301496407347/6061124916"
//        fullAd.delegate = self
//        fullAd.loadRequest(request2)
//        
//        fullAd.presentFromRootViewController(self)
        
    }
    
    func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
        var direction = gesture.direction
        switch (direction){
        case UISwipeGestureRecognizerDirection.Left:
            player.moving("LEFT")
            player.walkingAnimation(playerWalkingFrames)
            break
        case UISwipeGestureRecognizerDirection.Right:
            player.moving("RIGHT")
            player.walkingAnimation(playerWalkingFrames)
            break
        case UISwipeGestureRecognizerDirection.Up:
            player.moving("UP")
            player.walkingAnimation(playerWalkingFrames)
            break
        case UISwipeGestureRecognizerDirection.Down:
            player.moving("DOWN")
            player.walkingAnimation(playerWalkingFrames)
            break
        default:
            break;
        }
    }
    
    func handleTapGesture(gesture:UITapGestureRecognizer) {
        player.stopMoving()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
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
}
