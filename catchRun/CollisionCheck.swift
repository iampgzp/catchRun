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
    func checkIsCollision(player: PlayerNode) -> Bool{
        if !checkIsOutOfBound(player){
            return false
        }
        
        return true
    }
    
    func checkIsOutOfBound(player: PlayerNode) -> Bool{
        //if it is out of bound
        if player.getCurrentLoc().x < 0 {
            return false
        }
        if player.getCurrentLoc().x > self.mapXSize{
            return false
        }
        if (player.getCurrentLoc().y < 0){
            return false
        }
        if (player.getCurrentLoc().y > self.mapYSize){
            return false
        }
        return true
    }
    
    
    func checkIsWall(player: PlayerNode) -> Bool{
        if isOccupiedByWall(player.getCurrentLoc()){
            return false
        }
        return true
    }
    
    // input the current location, judge whether it is a wall
    // need to fill later
    func isOccupiedByWall(loc: CGPoint) -> Bool{
        
        return true
    }
    
    // if the location is occupied by other player
    func checkIsOtherPlayerInTheLoc(player1:PlayerNode, player2:PlayerNode) -> Bool{
        if player1.getCurrentLoc() != player2.getCurrentLoc(){
            return true
        }else{
            return false
        }
    }
    
}
