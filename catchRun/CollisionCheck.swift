//
//  CollisionCheck.swift
//  catchRun
//
//  Created by Li, Xiaoping on 12/24/14.
//  Copyright (c) 2014 LUSS. All rights reserved.
//

import Foundation
import SpriteKit

// collision check for different situation:
// 1. out of bound
// 2. collision with wall
// 3. collision with other player
class CollisionCheck : NSObject{
    
    // initialize the x and y boundary
    let mapXSize: CGFloat!
    let mapYSize: CGFloat!
    
    
    
    //check whether player has collision with walls
    func checkIsCollision(player: PlayerNode, tileMap: JSTileMap) -> Bool{
        var wall = tileMap.layerNamed("Meta")
        var tileGid = wall.tileGidAt(CGPoint(player.position.x, player.position.y))
        var properties:NSDictionary = tileMap.propertiesForGid(tileGid) as NSDictionary
        var collision: NSString = properties.valueForKey("Collidable") as NSString
        if collision.isEqualToString("True"){
            // collide should prevent user go in to the wall
            return true
        }
        return false
    }
    
    func checkIsTrap(player: PlayerNode, tileMap: JSTileMap) -> Bool{
        var trap = tileMap.layerNamed("trap")
        var tileGid = trap.tileGidAt(CGPoint(player.position.x, player.position.y))
        var properties:NSDictionary = tileMap.propertiesForGid(tileGid) as NSDictionary
        var collision: NSString = properties.valueForKey("Collidable") as NSString
        if collision.isEqualToString("True"){
            // collide should prevent user go in to the wall
            return true
        }
        return false
    }
    
    func checkIsOutOfBound(player: PlayerNode) -> Bool{
        //if it is out of bound, assume it is starting is at (0, 0), need to define a variable for its starting point
        if player.position.x < 0 {
            return true
        }
        if player.position.x > self.mapXSize{
            return true
        }
        if player.position.y < 0{
            return true
        }
        if player.position.y > self.mapYSize{
            return true
        }
        return false
    }
    
//    since the end
//    func checkIsWall(player: PlayerNode) -> Bool{
//        if isOccupiedByWall(player.position){
//            return false
//        }
//        return true
//    }
    
    // input the current location, judge whether it is a wall
    // need to fill later

    
    // if the location is occupied by other player
    func checkIsOtherPlayerInTheLoc(player1:PlayerNode, player2:PlayerNode) -> Bool{
        if player1.position != player2.position{
            return false
        }else{
            return true
        }
    }
    
}
