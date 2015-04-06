//
//  PlayerNode.swift
//  catchRun
//
//  Created by seehao on 14/12/22.
//  Copyright (c) 2014年 LUSS. All rights reserved.
//

import Foundation
import SpriteKit

let ghostSpeed : CGFloat = 1;
let ghostBusterSpeed : CGFloat = 2;

class PlayerNode: SKSpriteNode{
    var playerWalkingFrames : NSArray
    var previousPosition : CGPoint?
    var playerRole : NSString!
    // this is engine used for sending data to game center
    
    init(playerTextureName: NSString){
        var playerWalkingFramesTemp = NSMutableArray()
        let playerAnimatedAtlas:SKTextureAtlas = SKTextureAtlas(named: playerTextureName)
        var numImages = playerAnimatedAtlas.textureNames.count;
        for index in 1...numImages {
            var textureName = playerTextureName.stringByAppendingString(NSString(format: "%d", index))
            var temp:SKTexture = playerAnimatedAtlas.textureNamed(textureName)
            playerWalkingFramesTemp.addObject(temp)
        }
        playerWalkingFrames = playerWalkingFramesTemp
        super.init(texture: playerWalkingFrames[0] as SKTexture, color: UIColor.clearColor(), size: (playerWalkingFrames[0] as SKTexture).size())
    }
    
    func stopMoving(){
        self.removeActionForKey("walkingAnimation")
        self.removeActionForKey("movingUp")
        self.removeActionForKey("movingDown")
        self.removeActionForKey("movingRight")
        self.removeActionForKey("movingLeft")
    }
    
    func moving(Direction: String){
        previousPosition = position
        NSLog("moving to direction %s", Direction)
        var frame_4 = playerWalkingFrames.count / 4
        var speed : CGFloat = ghostBusterSpeed
        if playerRole == "Ghost"{
            speed = ghostSpeed
        }
        switch(Direction){
        case "LEFT":
            stopMoving()
            self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(playerWalkingFrames.subarrayWithRange(NSMakeRange(frame_4*2, frame_4)), timePerFrame: 0.1, resize: false, restore: true)), withKey: "walkingAnimation")
            self.runAction(SKAction.repeatActionForever(SKAction.moveByX(-100 * speed, y: 0, duration: 1)), withKey: "movingLeft")
            break
        case "RIGHT":
            stopMoving()
            self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(playerWalkingFrames.subarrayWithRange(NSMakeRange(frame_4*3, frame_4)), timePerFrame: 0.1, resize: false, restore: true)), withKey: "walkingAnimation")
            self.runAction(SKAction.repeatActionForever(SKAction.moveByX(100 * speed, y: 0, duration: 1)), withKey: "movingRight")
            break
        case "UP":
            stopMoving()
            self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(playerWalkingFrames.subarrayWithRange(NSMakeRange(0, frame_4)), timePerFrame: 0.1, resize: false, restore: true)), withKey: "walkingAnimation")
            self.runAction(SKAction.repeatActionForever(SKAction.moveByX(0, y: 100 * speed, duration: 1)), withKey: "movingUp")
            break
        case "DOWN":
            stopMoving()
            self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(playerWalkingFrames.subarrayWithRange(NSMakeRange(frame_4, frame_4)), timePerFrame: 0.1, resize: false, restore: true)), withKey: "walkingAnimation")
            self.runAction(SKAction.repeatActionForever(SKAction.moveByX(0, y: -100 * speed, duration: 1)), withKey: "movingDown")
            break
        default:
            break;
        }
    }
    
    //fill this part
    // this part will be used when moving remote-player object
    func moving(position: CGPoint){
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}