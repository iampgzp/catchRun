//
//  PlayerNode.swift
//  catchRun
//
//  Created by seehao on 14/12/22.
//  Copyright (c) 2014 LUSS. All rights reserved.
//

import Foundation
import SpriteKit

// macro define the speed
let ghostSpeed : CGFloat = 1;
let ghostBusterSpeed : CGFloat = 2;

// Using Enum to indicate direction
enum Direction:Int{
    case Up
    case Down
    case Left
    case Right
}

enum Role:Int{
    case ghost
    case ghostBuster
}

class PlayerNode: SKSpriteNode{
    var playerWalkingFrames : NSArray
    var playerRole : Role
    let frameCount : Int
    let movingSpeed: CGFloat
    var brain : ghostBusterBrain = ghostBusterBrain()
    
    // use for collistion engine to reset player position
    var previousPosition = CGPoint(x: 0, y: 0)
    var movingDirection = Direction.Up
    
    init(playerTextureName: NSString, playerRole: Role){
        NSLog("A \(playerRole) node is created")
        // load sktexture atlas and put all the texture into playerWalkingFrames to init
        var playerWalkingFramesTemp = NSMutableArray()
        let playerAnimatedAtlas:SKTextureAtlas = SKTextureAtlas(named: playerTextureName)
        let numImages = playerAnimatedAtlas.textureNames.count;
        for index in 1...numImages {
            var textureName = playerTextureName.stringByAppendingString(NSString(format: "%d", index))
            var temp:SKTexture = playerAnimatedAtlas.textureNamed(textureName)
            playerWalkingFramesTemp.addObject(temp)
        }
        playerWalkingFrames = playerWalkingFramesTemp
        
        // Get how many frame are there for each direction
        frameCount = playerWalkingFrames.count/4
        
        // get player role and set speed
        self.playerRole = playerRole
        
        // ghostbuster has faster speed
        if self.playerRole == Role.ghost{
            movingSpeed = ghostSpeed
        }else{
            movingSpeed = ghostBusterSpeed
        }
        
        
        // SKSpriteNode init
        super.init(texture: playerWalkingFrames[3] as SKTexture, color: UIColor.clearColor(), size: (playerWalkingFrames[0] as SKTexture).size())
        
        if self.playerRole == Role.ghost{
            xScale = 1.0
            yScale = 1.0
        }else{
            xScale = 0.5
            yScale = 0.5
        }
    }
    
    func moving(movingDirection: Direction){
        // move the node and start animation
        stopMoving()
        self.movingDirection = movingDirection
        switch(movingDirection){
        case Direction.Up:
            self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(playerWalkingFrames.subarrayWithRange(NSMakeRange(0, frameCount)), timePerFrame: 0.1, resize: false, restore: true)), withKey: "walkingAnimation")
            self.runAction(SKAction.repeatActionForever(SKAction.moveByX(0, y: 100 * speed, duration: 1)), withKey: "movingUp")
            break
        case Direction.Down:
            self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(playerWalkingFrames.subarrayWithRange(NSMakeRange(frameCount, frameCount)), timePerFrame: 0.1, resize: false, restore: true)), withKey: "walkingAnimation")
            self.runAction(SKAction.repeatActionForever(SKAction.moveByX(0, y: -100 * speed, duration: 1)), withKey: "movingDown")
            break
        case Direction.Left:
            self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(playerWalkingFrames.subarrayWithRange(NSMakeRange(frameCount*2, frameCount)), timePerFrame: 0.1, resize: false, restore: true)), withKey: "walkingAnimation")
            self.runAction(SKAction.repeatActionForever(SKAction.moveByX(-100 * speed, y: 0, duration: 1)), withKey: "movingLeft")
            break
        case Direction.Right:
            self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(playerWalkingFrames.subarrayWithRange(NSMakeRange(frameCount*3, frameCount)), timePerFrame: 0.1, resize: false, restore: true)), withKey: "walkingAnimation")
            self.runAction(SKAction.repeatActionForever(SKAction.moveByX(100 * speed, y: 0, duration: 1)), withKey: "movingRight")
            break
        default:
            break;
        }
    }
    
    func movingToPoint(destination: CGPoint){
        // this method is for moving remote players only, won't caculate short-path or obstacle
        
        // cancel any action right now
        stopMoving()
        
        // check which way player is moving for animation
        if  pow(destination.x - position.x, 2) < pow(destination.y - position.y, 2) {
            // node is moving horizontally
            if destination.y > position.y{
                // destination is to the up
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(playerWalkingFrames.subarrayWithRange(NSMakeRange(0, frameCount)), timePerFrame: 0.1, resize: false, restore: true)), withKey: "walkingAnimation")
            }else{
                // destination is to the down
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(playerWalkingFrames.subarrayWithRange(NSMakeRange(frameCount, frameCount)), timePerFrame: 0.1, resize: false, restore: true)), withKey: "walkingAnimation")
            }
        }else{
            // node is moving vertically
            if destination.x > position.x{
                // destination is to the left
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(playerWalkingFrames.subarrayWithRange(NSMakeRange(frameCount*2, frameCount)), timePerFrame: 0.1, resize: false, restore: true)), withKey: "walkingAnimation")
            }else{
                // destination is to the right
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(playerWalkingFrames.subarrayWithRange(NSMakeRange(frameCount*3, frameCount)), timePerFrame: 0.1, resize: false, restore: true)), withKey: "walkingAnimation")
            }
        }
        
        self.runAction(SKAction.repeatActionForever(SKAction.moveTo(destination, duration: 1)), withKey: "moving")
    }
    
    func movingByPath(path:Array<CGPoint>){
        var actionArray : Array<SKAction> = Array()
        for index in 1...path.count-1 {
            var previousPosition : CGPoint
            if index == 1 {
                previousPosition = position
            }else{
                previousPosition = path[index-1]
            }
            var destination :CGPoint = path[index]
            
            var animationAction : SKAction
            // check which way player is moving for animation
            if  pow(destination.x - previousPosition.x, 2) < pow(destination.y - previousPosition.y, 2) {
                // node is moving horizontally
                if destination.y > previousPosition.y{
                    // destination is to the up
                    animationAction = SKAction.repeatAction((SKAction.animateWithTextures(playerWalkingFrames.subarrayWithRange(NSMakeRange(0, frameCount)), timePerFrame: 0.1, resize: false, restore: true)), count: 1)
                }else{
                    // destination is to the down
                    
                    animationAction = SKAction.repeatAction((SKAction.animateWithTextures(playerWalkingFrames.subarrayWithRange(NSMakeRange(frameCount, frameCount)), timePerFrame: 0.1, resize: false, restore: true)), count: 1)
                }
            }else{
                // node is moving vertically
                if destination.x < previousPosition.x{
                    // destination is to the left
                    animationAction = SKAction.repeatAction((SKAction.animateWithTextures(playerWalkingFrames.subarrayWithRange(NSMakeRange(frameCount*2, frameCount)), timePerFrame: 0.1, resize: false, restore: true)), count: 1)
                }else{
                    // destination is to the right
                    
                    animationAction = SKAction.repeatAction((SKAction.animateWithTextures(playerWalkingFrames.subarrayWithRange(NSMakeRange(frameCount*3, frameCount)), timePerFrame: 0.1, resize: false, restore: true)), count: 1)
                }
            }
            
            let moveAction = SKAction.moveTo(destination, duration: 0.3)
            let groupActionArray = [moveAction, animationAction]
            let groupAction = SKAction.group(groupActionArray)
            actionArray.append(groupAction)
        }
        
        self.runAction(SKAction.sequence(actionArray))
    }
    
    func movingToPointWithShortestPath(destination: CGPoint){
        var path = brain.pathForMovingToPosition(position, destination: destination)
        movingByPath(path)
    }
    
    func stopMoving(){
        self.removeActionForKey("walkingAnimation")
        self.removeActionForKey("movingUp")
        self.removeActionForKey("movingDown")
        self.removeActionForKey("movingRight")
        self.removeActionForKey("movingLeft")
        self.removeActionForKey("moving")
    }
    
    func ChasingGhostAt(destination: CGPoint){
        // stop all animation re-cal and chase
        self.removeAllActions()
        self.movingToPointWithShortestPath(destination)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}