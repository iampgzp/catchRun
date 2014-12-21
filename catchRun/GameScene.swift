//
//  GameScene.swift
//  catchRun
//
//  Created by Ji Pei on 12/16/14.
//  Copyright (c) 2014 LUSS. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, GADInterstitialDelegate {
    var tiledMap:JSTileMap?
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(myLabel)

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
