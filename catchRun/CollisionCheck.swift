//
//  CollisionCheck.swift
//  catchRun
//
//  Created by Li, Xiaoping on 12/24/14.
//  Copyright (c) 2014 LUSS. All rights reserved.
//

import Foundation
import SpriteKit

class CollisionCheck : NSObject{
    var tiledMap:JSTileMap
    
    init(tiledMap:JSTileMap){
        self.tiledMap = tiledMap
        super.init()
    }
    
    func isCollideWithWall(position:CGPoint) -> Bool{
        // wall's layer name is Meta
        let map = tiledMap
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
        let map = tiledMap
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
    
    func isCollideWithGhost(PlayerPosition:CGPoint, ghostPosition:CGPoint) -> Bool{
       return false
    }
    
    
    // function to change coordinates to tile coordinates
    // tile : (0, 0) ........ (16, 0)
    //          .    ........   .
    //          .    ........   .
    //        (0, 16) ......  (16, 16)
    //while spritekit origin is bottom left so we need to reverse y
    func tileCoordForPosition(position: CGPoint) -> CGPoint{
        var x = Int((position.x / (tiledMap.tileSize.width*1.9)))
        var y = Int((tiledMap.mapSize.height * tiledMap.tileSize.height*1.5 - position.y) / (tiledMap.tileSize.height*1.5))
        return CGPoint(x: x, y: y)
    }

}
