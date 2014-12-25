//
//  PlayerNode.swift
//  catchRun
//
//  Created by seehao on 14/12/22.
//  Copyright (c) 2014年 LUSS. All rights reserved.
//

import Foundation
import SpriteKit


class PlayerNode: SKSpriteNode{
    
    func stopMoving(){
        self.removeActionForKey("walkingAnimation")
        self.removeActionForKey("movingUp")
        self.removeActionForKey("movingDown")
        self.removeActionForKey("movingRight")
        self.removeActionForKey("movingLeft")
    }
    
    func moving(Direction: String){
        switch(Direction){
        case "LEFT":
            stopMoving()
            self.runAction(SKAction.repeatActionForever(SKAction.moveByX(-30, y: 0, duration: 1)), withKey: "movingLeft")
            break
        case "RIGHT":
            stopMoving()
            self.runAction(SKAction.repeatActionForever(SKAction.moveByX(30, y: 0, duration: 1)), withKey: "movingRight")
            break
        case "UP":
            stopMoving()
            self.runAction(SKAction.repeatActionForever(SKAction.moveByX(0, y: 30, duration: 1)), withKey: "movingUp")
            break
        case "DOWN":
            stopMoving()
            self.runAction(SKAction.repeatActionForever(SKAction.moveByX(0, y: -30, duration: 1)), withKey: "movingDown")
            break
        default:
            break;
        }
    }
    
    func creatWalkingFrames() -> (NSArray)  {
        var playerWalkingFrames = NSArray()
        var playerWalkingFramesTemp = NSMutableArray()
        let playerAnimatedAtlas:SKTextureAtlas = SKTextureAtlas(named: "BearImages")
        var numImages = playerAnimatedAtlas.textureNames.count;
        for index in 1...numImages {
            var textureName = NSString(format: "bear%d", index)
            var temp:SKTexture = playerAnimatedAtlas.textureNamed(textureName)
            playerWalkingFramesTemp.addObject(temp)
        }
        playerWalkingFrames = playerWalkingFramesTemp
        return (playerWalkingFrames)
    }
    
    func walkingAnimation (textureArray: NSArray) {
        self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textureArray, timePerFrame: 0.1, resize: false, restore: true)), withKey: "walkingAnimation")
    }
    
    // need to update player's location according to its move direction
    func getCurrentLoc() -> CGPoint{
        // apply its location here according to its move
        return CGPoint(x: 0,y: 0)
    }
    
}